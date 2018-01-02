#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 20016-2016 The Cloudsoar.
# See LICENSE for details.

import json
import re

from src.util import RandomStr


TEMPLATE_SEPARATOR = "#---"

def keyword_replace(txt):
    return txt.replace('.Chart.', 'Chart.').replace('.Release.', 'Release.').replace('.Values.', 'Values.').replace('.Values ', 'Values ').replace('.Capabilities.', 'Capabilities.')

class Template(object):
    def __init__(self, regStr, pre=0, end=0):
        self.index_pre = pre
        self.index_end = end
        self.functions = []
            
        self.reObj = re.compile(regStr)
    
    def replace(self, match):
        pass
        
    def toString(self, tpl_txt):
        return self.reObj.sub(self.replace, tpl_txt)
            
    def toJson(self):
        txt = self.toString()
        return json.loads(txt)
        
    def format(self,txt):
        return keyword_replace(txt)

class functionTemplate(Template):
    """
    self.xxxx.xxx() -->  | self.xxxx.xxx()
    """
    
    def __init__(self):
        self._store = []
        self.key = RandomStr(8)
        Template.__init__(self, '[\.\w]+\([^)]*\)')
        
    def replace(self, match):
        tmpStr = match.group()
        index = len(self._store)
        self._store.append(tmpStr)
        return '@@%s-%s@@'%(self.key, index)
    
    def restore(self, content):
        length = len(self._store)
        for i in range(length):
            content = content.replace('@@%s-%s@@'%(self.key, i), self._store[i])
        return content

    
class filterTemplate(Template):
    """
    | trunc 63 -->  | trunc(63)
    """
    def __init__(self):
        Template.__init__(self, '\|[^\|]+')
        
    def replace(self, match):
        tmpStr = match.group()
        return self.format_filter(tmpStr[1:])
    
    def format_filter(self, content):
        if content.find('(') >= 0: # or content.find('default(') >= 0 or content.find('format(') >= 0 :
            return "|" + content
            
        arr = content.strip().split(' ')
        return "| %s(%s) "%(arr[0], ",".join(arr[1:]))



    
class SetTemplate(Template):
    """
    {{- $name := default .Chart.Name .Values.nameOverride -}}    {% with foo = 42 %}
    """
    def __init__(self):
        Template.__init__(self, '[ \$]+([\w]+)[ ]*:=')
        
    def replace(self, match):
        tmpStr = match.group()
        return self.format(tmpStr)
    
    def format(self, content):
        """
        {{- $name := default Chart.Name Values.nameOverride -}}
        """
        m = re.search(r'[\$]{0,1}([\w]+)[ ]*:=', content)
        if not m:
            return content
        
        txt = m.group(1)
        return " set " + txt.replace(".", "__")  +" ="
    
class ValueTemplate(Template):
    """
    $name -> name
    """
    def __init__(self):
        Template.__init__(self, '[ ]*\$([\.\w]+)[ ]+')
        
    def replace(self, match):
        tmpStr = match.group()
        return self.format(tmpStr)
    
    def format(self, content):
        return content.replace("$", "")
    
   
class MatchException(Exception):

    """
    Generic Etcd Exception.
    """
    def __init__(self, message="None", payload=None):
        super(MatchException, self).__init__(message)
        self.payload = payload
        
        
class HelmTemplate(Template):
    """
    {{- define "name" -}}
    {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
    {{- end -}}
    
    {% block title %}Index{% endblock %}
    
    {{- $name := default .Chart.Name .Values.nameOverride -}}    {% with foo = 42 %}
    """
    def __init__(self):
        Template.__init__(self, '{{[^}]+}}')
        
    def replace(self, match):
        tmpStr = match.group()
        formater = Formater()
        return formater.format(tmpStr)
        
    
class Formater(object):
    def __init__(self):
        self.out_put = True
        self.index_pre = 2
        self.index_end = 2
        self.prifix = ''
        self.postfix = ''
        
        
    def format(self, tmpStr):
        if tmpStr[2] == "-":
            self.prifix = "-"
            self.index_pre = 3
            
        if tmpStr[-3] == "-":
            self.postfix = "-"
            self.index_end = 3
        
        try:
            content = keyword_replace(tmpStr[self.index_pre:-self.index_end])
            content = self.format_ctrl_key(content)
            content = self.format_template(content)
            content = self.format_block(content)
            content = self.format_set(content)
            content = self.format_include(content)
            content = self.format_default(content)
            content = self.format_printf(content)
            content = self.format_print(content)
            content = self.format_rand(content)
            content = self.format_len(content)
            content = self.format_typeOf(content)
            content = self.format_trimPrefix(content)
            content = self.format_toYaml(content)
            content = self.format_toJson(content)
            content = self.format_replace(content)
            content = self.format_filter(content)
            fun = functionTemplate()
            content = fun.toString(content)
            content = self.format_if(content)
            content = self.format_index(content)
            content = fun.restore(content)
        except MatchException:
            return self._output(self.content)
        
        return self._output(content)
        
    
    def _output(self, content):
        if self.out_put:
            return "{{%s %s %s}}"%(self.prifix, content.strip(), self.postfix)
        else:
            return "{%s%s %s %s%s}"%("%", self.prifix, content.strip(), self.postfix, "%")   
        
    def format_ctrl_key(self, content):
        key = content.strip()
        if key in ['else', 'endif', 'endblock', 'endfor']:
            self.out_put = False
            self.content = key
            raise MatchException("matched")
        
        return content

    
    def format_block(self, content):
        m = re.search(r'[ ]+define[ ]+"(.+)"[ ]+', content)
        if m:
            self.out_put = False
            txt = m.group(1)
            self.content = "block " + txt.replace(".", "__")
            raise MatchException("matched")

        return content

    def format_default(self,content):
        """
        default Chart.Name Values.nameOverride -->  Chart.Name | default('Values.nameOverride')
        """
        m = re.search(r'[ ]+default[ ]+([\/\"\.\w]+)[ ]+([\.\w]+)[ ]*', content)
        if m:
            a = m.group(1)
            b = m.group(2)
            return content.replace(m.group(0), " %s | default(%s, true) "%(b, a))
        
        return content
    
    def format_set(self, content):
        if content.find('=') > 0:
            self.out_put = False
            tpl = SetTemplate()
            content = tpl.toString(content)
        
        tpl = ValueTemplate()
        return tpl.toString(content)
        
        
    def format_include(self, content):
        """
        (include "magento.randomPassword" .) -->  (self.magento__randomPassword())
        """
        m = re.search(r'[( ]+include[ ]+"(.+)"[ ]+.[ )]+', content)
        if m:
            full = m.group(0).strip()
            txt = m.group(1)
            if full[0] == '(':
                new_txt = " (self." + txt.replace(".", "__")  +"()) "
            else:
                new_txt = " self." + txt.replace(".", "__")  +"() "
            
            return content.replace(full, new_txt)
        
        return content
        
    def format_if(self, content):
        """
         if (eq "-" .Values.persistence.storageClass)   -->   if ("-" == Values.persistence.storageClass) 
         if and (.Values.tolerations) (ge .Capabilities.KubeVersion.Minor "6")
         if and (.Values.tolerations) (le .Capabilities.KubeVersion.Minor "5")
         
        """
        def replace(symbol):
            symbol = symbol.strip()
            if symbol == "eq":
                return "=="
            if symbol == "ge":
                return ">="
            if symbol == "gt":
                return ">"
            if symbol == "le":
                return "<="
            if symbol == "ne":
                return "!="
            if symbol == "contains":
                return "=="
    
            return " %s "%(symbol)
        
        
        def process(txt):
            items = []
            from_index = 0
            stack = 0
            index = 0
            
            # 剥离外层括号
            if txt and txt[0] == '(':
                wrap = True
                txt = txt[1:-1]
            else:
                wrap = False
            
            for key in txt:
                if key == '(':
                    if stack == 0:
                        arr = txt[from_index:index].strip().split(' ')
                        items.extend(arr)
                        from_index = index
                        
                    stack += 1
                elif key == ')':
                    if stack == 1:
                        items.append(txt[from_index:index+1].strip())
                        from_index = index+1
                    
                    stack -= 1
                    
                index += 1
                
            
            
            if from_index < len(txt):
                arr = txt[from_index:].strip().split(' ')
                if "|" in arr:
                    items.append(txt[from_index:])
                else:
                    items.extend(arr)
                
            if len(items) == 1:
                return "(%s)"%(txt) if wrap else txt
                
            tmp = []
            for item in items:
                item = item.strip()
                if item == "":
                    continue
                
                tmp.append(process(item))
            
            if len(tmp) == 0:
                return ' '
            
            sign = replace(tmp.pop(0))
            if len(tmp) == 1:
                result = "%s %s"%(sign, tmp[0])
            else:
                result = sign.join(tmp)
                
            if wrap:
                return "(" +result + ")"
            else:
                return result
        
        m = re.search(r'(.*)[ ]+if[ ]+(.*)$', content)
        if m:
            self.out_put = False
            prifix = m.group(1)
            txt = m.group(2).strip()
            return prifix + "if " +  process(txt)
        
        m = re.search(r'(.*)[ ]+elif[ ]+(.*)$', content)
        if m:
            self.out_put = False
            prifix = m.group(1)
            txt = m.group(2).strip()
            return prifix + "elif " +  process(txt)
        
        return content
    
    def format_rand(self, content):
        """
        randAlphaNum 10 -->  randAlphaNum(10)
        """
        m = re.search(r'[ ]+randAlphaNum[ ]+([\"\.\w]+)[ ]*', content)
        if m:
            a = m.group(1)
            return content.replace(m.group(0), " randAlphaNum(%s) "%(a))
    
        return content
    
    def format_len(self, content):
        """
        len 10 -->  length(10)
        """
        m = re.search(r'([\( ]+)len[ ]+([\"\.\w]+)([ \)]+)', content)
        if m:
            prefix = m.group(1)
            a = m.group(2)
            postfix = m.group(3)
            return content.replace(m.group(0), "%slength(%s)%s"%(prefix, a, postfix))
    
        return content
    
    def format_typeOf(self, content):
        """
        typeOf 10 -->  typeOf(10)
        """
        m = re.search(r'([\( ]+)typeOf[ ]+([^ \)\|]+)([ \)]+)', content)
        if m:
            prefix = m.group(1)
            a = m.group(2)
            postfix = m.group(3)
            return content.replace(m.group(0), "%stypeOf(%s)%s"%(prefix, a, postfix))
    
        return content
    
    
    
    
    def format_trimPrefix(self, content):
        """
        trimPrefix ":" $value.service_address -->  trimPrefix(":", $value.service_address)
        """
        m = re.search(r'^[ ]+trimPrefix[ ]+([\"\.\w]+)[ ]+([\"\.\w]+)[ ]*', content)
        if m:
            a = m.group(1)
            b = m.group(2)
            return content.replace(m.group(0), " trimPrefix(%s, %s) "%(a, b))
    
        return content
    
    
    def format_toYaml(self, content):
        """
        toYaml Values.resources -->  toYaml(Values.resources)
        """
        m = re.search(r'[ ]+toYaml[ ]+([\"\.\w]+)[ ]*', content)
        if m:
            a = m.group(1)
            return content.replace(m.group(0), " toYaml(%s) "%(a))
    
        return content
    
    def format_toJson(self, content):
        """
        toYaml Values.resources -->  toYaml(Values.resources)
        """
        m = re.search(r'[ ]+toJson[ ]+([\"\.\w]+)[ ]*', content)
        if m:
            a = m.group(1)
            return content.replace(m.group(0), " toJson(%s) "%(a))
    
        return content
    
    
    
    def format_replace(self, content):
        """
        replace "+" "_" .Chart.Version -->  replace("+","_",.Chart.Version)
        """
        m = re.search(r'[ ]+replace[ ]+([_\+\"\.\w]+)[ ]+([_\+\"\.\w]+)[ ]+([\"\.\w]+)[ ]*', content)
        if m:
            a = m.group(1)
            b = m.group(2)
            c = m.group(3)
            return content.replace(m.group(0), " replace(%s, %s, %s) "%(a, b, c))
    
        return content
    
    
    def format_printf(self, content):
        """
        {{- printf "%s-%s" Release.Name $name | trunc 63 | trimSuffix "-" -}} -->  "%s-%s" | format(Release.Name $name)
        | printf "%s-%s" .Chart.Name
        """
        m = re.search(r'\|[ ]+printf[ ]+"([^"]+)"[ ]+([^|)]+)', content)
        if m:
            if content.find('=', 0, content.find('printf')) >= 0 :
                self.out_put = False
                
            matched = m.group(0)
            a = m.group(1)
            b = m.group(2)
    
            arr = [key for key in b.strip().split(' ') if key.strip()!='']
            return content.replace(matched, '| printf("%s", %s) '%(a, ",".join(arr)))
        
        
        m = re.search(r'([( ]+)printf[ ]+"([^"]+)"[ ]+([^|)]+)', content)
        if m:
            if content.find('=', 0, content.find('printf')) >= 0 :
                self.out_put = False
                
            matched = m.group(0)
            prefix = m.group(1)
            a = m.group(2)
            b = m.group(3)
    
            arr = [key for key in b.strip().split(' ') if key.strip()!='']
            return content.replace(matched, '%s"%s" | format(%s) '%(prefix, a, ",".join(arr)))
    
        return content
    
    def format_print(self, content):
        """
        {{- print "networking.k8s.io/v1" -}} -->  {{- "networking.k8s.io/v1" -}}
        """
        m = re.search(r'([( ]+)print[ ]+"([^"]+)"', content)
        if m:
            matched = m.group(0)
            prefix = m.group(1)
            txt = m.group(2)
            return content.replace(matched, '%s"%s"'%(prefix, txt))
    
        return content
    
    def format_index(self, content):
        """
        "{{ index .Values "etcd-operator" "cluster" "name" }}-client:2379"
        {{- index .Values (printf "%sLoadBalancerIP" .Chart.Name) | default "" -}}
        {{- $host := index .Values (printf "%sHost" .Chart.Name) | default "" -}}
        """
        m = re.search(r'([( ]+)index[ ]+([^ ]+)[ ]+([^\|\}]+)', content)
        if m:
            matched = m.group(0)
            prefix = m.group(1)
            data = keyword_replace(m.group(2))
            txt = keyword_replace(m.group(3))
            arr = ["index(%s)"%(key) for key in txt.strip().split(' ') if key.strip()!='']
            return content.replace(matched, '%s %s | %s'%(prefix, data, " | ".join(arr)))
    
        return content
    
    def format_filter(self, content):
        tpl = filterTemplate()
        return tpl.toString(content)
    
    
    def format_template(self, content):
        """
        {{ template "fullname" . }}
        """
        m = re.search(r'^[ ]+template[ ]+"(.+)"[ ]+.[ ]+$', content)
        if m:
            txt = m.group(1)
            self.content = "self." + txt.replace(".", "__")  +"()"
            raise MatchException("matched")
         
        return content
      
    



class SeparatorTemplate(Template):
    """
    ###---###---  -> \n---\n
    ###---  -> \n---\n
    """
    def __init__(self):
        Template.__init__(self, "(%s)+"%(TEMPLATE_SEPARATOR))
        
    def replace(self, match):
        return '\n\n---\n\n'


  

