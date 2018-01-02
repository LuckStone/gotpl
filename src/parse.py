# -*- coding: utf-8 -*-
# Copyright (c) 20016-2016 The Cloudsoar.
# See LICENSE for details.
'''
Created on 2017年10月30日

@author: Cloudsoar
'''

import base64
import json
import os
import re
import traceback

from jinja2.environment import Environment
from jinja2.loaders import DictLoader
import yaml

from src.helm import SeparatorTemplate, \
    keyword_replace, HelmTemplate
from src.util import RandomLowerStr


BASE_TEMPLATE_FILE_NAME = 'base.tpl'
CHILDREN_TEMPLATE_FILE_NAME = '_helpers.tpl'

TEMPLATE_FARMAT_CONTENT_BEGIN  = '''
{% extends "'''+ BASE_TEMPLATE_FILE_NAME +'''" %}
{% macro randAlphaNum(num) %}
{{ num | randAlphaNum() }}
{% endmacro %}

{% macro toYaml(data) %}
{{ data | toYaml}}
{% endmacro %}

{% macro replace(src, target, content) %}
{{ content | replace(src, target)}}
{% endmacro %}

{% macro length(content) %}
{{ content | length()}}
{% endmacro %}

{% macro sub(num1, num2) %}
{{ num1 | sub(num2)}}
{% endmacro %}

'''
TEMPLATE_FARMAT_CONTENT_END  = """
{{ super() }}
"""

'''
.Capabilities.APIVersions.Has
.Capabilities.KubeVersion.Minor
'''
CAPABILITIES18 = {
    "KubeVersion":{"Major":"1", 
                   "Minor":"8", 
                   "GitVersion":"v1.8.2", 
                   "GitCommit":"bdaeafa71f6c7c04636251031f93464384d54963", 
                   "GitTreeState":"clean", 
                   "BuildDate":"2017-10-24T19:48:57Z", 
                   "GoVersion":"go1.8.3", 
                   "Compiler":"gc", 
                   "Platform":"linux/amd64"
    },
    "APIVersions":(
        "apiextensions.k8s.io/v1beta1",
        "apiregistration.k8s.io/v1beta1",
        "apps/v1beta1",
        "apps/v1beta2",
        "authentication.k8s.io/v1",
        "authentication.k8s.io/v1beta1",
        "authorization.k8s.io/v1",
        "authorization.k8s.io/v1beta1",
        "autoscaling/v1",
        "autoscaling/v2beta1",
        "batch/v1",
        "batch/v1beta1",
        "batch/v2alpha1",
        "certificates.k8s.io/v1beta1",
        "extensions/v1beta1",
        "networking.k8s.io/v1",
        "policy/v1beta1",
        "rbac.authorization.k8s.io/v1",
        "rbac.authorization.k8s.io/v1beta1",
        "storage.k8s.io/v1",
        "storage.k8s.io/v1beta1",
        "v1",
    )
}


workroot = os.path.dirname(os.path.abspath(__file__))

class HelmParser(object):
    '''
    classdocs
    '''


    def __init__(self):
        '''
        Constructor
        '''
        self.lines = []
        self.range_matched = 0
        self.with_matched = 0
        self.range_sign = 0
        self.stack = []
    
    def load(self, file_path):
        with open(file_path, 'r') as f:
            for line in f:
                if line.find('{{') < 0:
                    self.lines.append(line)
                    continue
                
                line = self.process_sha256sum(line)
                line = self.process_with(line)
                line = self.process_range(line)
                line = self.process_if(line)
                line = self.process_end(line)
                self.lines.append(line)
                
        return "".join(self.lines)
    
    def process_with(self, content):
        """
        """
        def replace(match):
            tmpStr = match.group()
            tmpStr = keyword_replace(tmpStr)
            return tmpStr.replace(' .', ' item.')
        
        if self.with_matched <=0 :
            return self._process_with_begin(content)
        else:
            reObj = re.compile('[ ]+\.[\w]+[\.\w]+[ ]*')
            content = reObj.sub(replace, content)
            
            return content.replace("$", "").replace("{{ . }}", "{{ item }}").replace("{{ . |", "{{ item |")
    
    def _process_with_begin(self, content):
        """
        {{ with .Values.resizer }}
        """
        m = re.search(r'(.*){{[-]{0,1}[ ]*with[ ]+([\.\w]+)[ ]*[-]{0,1}}}(.*)', content)
        if not m:
            return content
        
        self.stack.append("endWith")
        self.with_matched += 1
        prefix = m.group(1)
        data = m.group(2)
        postfix = m.group(3)
        data = keyword_replace(data)

        return "%s{%s- set item = %s "%(prefix, "%", data) + "%}" + postfix.replace("$", "") + "\n"
    
    def process_range(self, content):
        """
        # range 不能嵌套
        {{- range .Values.autoscalingGroups }}
            - --nodes={{ .minSize }}:{{ .maxSize }}:{{ .name }}
        {{- end }}
        
        {{- range $key, $value := .Values.extraArgs }}
            - --{{ $key }}={{ $value }}
        {{- end }}
        """
        if self.range_matched <=0 :
            txt, processed = self._process_range_begin(content)
            if processed:
                return txt
            txt, processed = self._process_range_begin2(content)
            return txt if processed else self._process_range_begin3(content)
        
        def replace(match):
            tmpStr = match.group()
            tmpStr = keyword_replace(tmpStr)
            return tmpStr.replace(' .', ' item.')
        
        reObj = re.compile('{{[-]{0,1}[ ]+\.[\w]+[\.\w]+[ ]*[-]{0,1}}}')
        content = reObj.sub(replace, content)
        
        return content.replace("$", "").replace("{{ . }}", "{{ item }}").replace("{{ . |", "{{ item |")
            
    
    def _process_range_begin(self, content):
        """
        {{- range $key, $value := .Values.ingress.annotations }}
        """
        m = re.search(r'(.*){{[-]{0,1}[ ]*range[ ]+\$([\.\w]+)[ ]*,[ ]*\$([\.\w]+)[ ]*:=[ ]*([\.\w]+)[ ]*[-]{0,1}}}(.*)', content)
        if not m:
            return content, False
        
        self.stack.append(" endfor ")
        self.range_matched += 1
        prefix = m.group(1)
        key = m.group(2)
        value = m.group(3)
        data = m.group(4)
        postfix = m.group(5)
        data = keyword_replace(data)

        return "%s{%s- for %s, %s in %s.iteritems() "%(prefix, "%", key, value, data) + "%}" + postfix.replace("$", "") + "\n", True
    
    def _process_range_begin2(self, content):
        """
        {{- range .Values.autoscalingGroups }}
        """
        m = re.search(r'{{-[ ]+range[ ]+([\$\.\w]+)[ ]*}}', content)
        if not m:
            return content, False
        
        self.stack.append(" endfor ")
        self.range_matched += 1
        data = m.group(1)
        data = keyword_replace(data)
        data = data.replace('$', '')

        return content.find('{{') * " " + "{%-" + " for item in %s "%(data) + "%}\n", True
    
    def _process_range_begin3(self, content):
        """
        {{- range $key, $value := .Values.ingress.annotations }}
        """
        m = re.search(r'{{-[ ]+range[ ]+\$([\.\w]+)[ ]*:=[ ]*([\.\w]+)[ ]*}}', content)
        if not m:
            return content
        
        self.stack.append(" endfor ")
        self.range_matched += 1
        key = m.group(1)
        data = m.group(2)
        data = keyword_replace(data)

        return content.find('{{') * " " + "{%-" + " for %s in %s "%(key, data) + "%}\n"
    
    def process_if(self, content):
        m = re.search(r'{{[ ]*if[ ]+', content)
        if m:
            content = content.replace("{{ if", "{{- if")
         
        m = re.search(r'{{[ ]*else[ ]+', content)
        if m:
            content = content.replace("{{ else", "{{- else")
            
        m = re.search(r'{{[-]{0,1}[ ]*(else[ ]+if)[( ]+', content)
        if m:
            content = content.replace(m.group(1), "elif")
         
        m = re.search(r'({{[-]{0,1}[ ]*end[ ]*)[-]{0,1}}}', content)
        if m:
            content = content.replace(m.group(1), "{{- end ")
         
        return content
    
    def process_end(self, content):
        m = re.search(r'{{[-]{0,1}[ ]+define[ ]+', content)
        if m:
            self.stack.append(" endblock ")
            return content
        
        m = re.search(r'{{[-]{0,1}[ ]+if[ ]+', content)
        if m:
            self.stack.append(" endif ")
        
        m = re.search(r'{{[-]{0,1}[ ]+end[ ]+[-]{0,1}}}', content)
        if m:
            if self.stack:
                end = self.stack.pop()
                if end == " endfor ":
                    self.range_matched -= 1
                elif end == "endWith":
                    self.with_matched -= 1
                    return ""
                return content.replace(" end ", end)
            else:
                return content.replace(" end ", " endif ")
        
        return content
    
    def process_sha256sum(self, content):
        """
        include (print $.Template.BasePath "/hadoop-configmap.yaml") . | sha256sum
        """
        m = re.search(r'{{[ ]*include[ ]+[^\|]+\|[ ]+sha256sum[ ]*}}', content)
        if m:
            return content.replace(m.group(0), '""')
         
        return content
            
    def parse(self, file_path):
        txt = self.load(file_path)
        txt = txt.replace('{{/*', '{#').replace('*/}}', '#}').replace('{{- /*', '{#').replace('*/ -}}', '#}')
    
        tpl = HelmTemplate()
        return tpl.toString(txt)

def printf(value, str_format, *arg, **args):
    return str_format%(value, arg)

def quote(value):
    return '"%s"'%(value)

def trunc(value, length):
    return str(value)[0:length]

def b64enc(value):
    if isinstance(value, basestring):
        return base64.encodestring(value).strip()
    return value

def indent(value, num):
    value = num * " " + value.strip()
    arr = value.split('\n')
    return ("\n" + num * " ").join(arr)

def index(value, key):
    if isinstance(value, dict):
        return value.get(key, "")
    
    return ""

def length(value):
    if not value:
        return 0

    return len(value)

def sub(num1, num2):
    return num1 - num2

def rangein(value):
    try:
        value = int(value)
    except:
        return []
    return range(value)
    

def trimSuffix(value, keys):
    return value.rstrip(keys)

def trimPrefix(value, keys):
    return value.rstrip(keys)

def randAlphaNum(num):
    return RandomLowerStr(num)

def toYaml(data):
    if isinstance(data, dict) or isinstance(data, list):
        return yaml.safe_dump(data)
    
    return data

def toJson(data):
    if isinstance(data, dict) or isinstance(data, list):
        return json.dumps(data)
    
    return data

def typeOf(data):
    a = type(data)
    return a

def int64(value):
    try:
        return int(value)
    except:
        return 0

def Jinja2Render(chart, values, release, data):
    # template = {"parent.yaml":parent, "children.yaml":children}
    env = Environment(loader=DictLoader(data))
    env.filters['quote'] = quote
    env.filters['trimSuffix'] = trimSuffix
    env.filters['trimPrefix'] = trimPrefix
    env.filters['trunc'] = trunc
    env.filters['b64enc'] = b64enc
    env.filters['printf'] = printf
    env.filters['randAlphaNum'] = randAlphaNum
    env.filters['toYaml'] = toYaml
    env.filters['toJson'] = toJson
    env.filters['indent'] = indent
    env.filters['rangein'] = rangein
    env.filters['int64'] = int64
    env.filters['index'] = index
    env.filters['typeOf'] = typeOf
    env.filters['length'] = length
    env.filters['sub'] = sub
    
    template = env.get_template('_helpers.tpl')
    try:
        txt = template.render(Values=values, Release=release, Chart=chart, Capabilities=CAPABILITIES18)
        tpl = SeparatorTemplate()
        return tpl.toString(txt)
        
    except Exception,e:
        traceback.print_exc()
        return str(e)
    
def test(file_name):
    file_path = os.path.join(workroot, 'test', file_name)
    output_path = file_path.replace('.tpl', '.html')
    
    p = HelmParser()
    txt = p.parse(file_path)
        
    with open(output_path, 'w') as f:
        f.write(txt)


if __name__ == '__main__':
    try:
        #test("if.tpl")
        #test("range.tpl")
        #test("printf.tpl")
        test("index.tpl")
        #test("with.tpl")
        #test("wordpress.tpl")
    except Exception,e:
        traceback.print_exc()