#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 20016-2016 The Cloudsoar.
# See LICENSE for details.
'''
Created on 2017年10月30日

@author: Cloudsoar
'''
#import re
#from src.util import RandomStr

import os
import re
import traceback

import yaml

from src.const import APP_LIST
from src.helm import TEMPLATE_SEPARATOR
from src.parse import Jinja2Render, CHILDREN_TEMPLATE_FILE_NAME, \
    BASE_TEMPLATE_FILE_NAME, \
    TEMPLATE_FARMAT_CONTENT_BEGIN, TEMPLATE_FARMAT_CONTENT_END


workroot = os.path.dirname(os.path.abspath(__file__))


def load_template(folder):
    dirs = os.listdir(folder)
    data = {}
    
    # load yaml file
    for filename in dirs:
        if not (filename.endswith('.yaml') or filename.endswith('.yml')):
            continue
        file_path = os.path.join(folder, filename)
        if not os.path.isfile(file_path):
            continue
        
        kind = filename
        with open(file_path, 'r') as f:
            code = f.read()
            m = re.search(r'kind:[ ]+([\w]+)', code)
            if m:
                kind = m.group(1).strip() + filename
        
        data[kind] = code
            
    keys = data.keys()
    keys.sort()
    
    front = []
    behind = []
    for key in keys:
        if key.find('Deployment') == 0:
            behind.append(key)
        elif key.find('Pod') == 0:
            behind.insert(0, key)
        else:
            front.append(key)
            
    front.extend(behind)
    
    arr = []
    for key in front:
        arr.append(data[key])
    
    return TEMPLATE_SEPARATOR.join(arr)


def render(app_name):
    app_folder = os.path.join(workroot, 'jinja2', app_name)
    tpl_file_folder = os.path.join(app_folder, 'templates')
    helper_file_path = os.path.join(tpl_file_folder, '_helpers.tpl')
    chart_file_path = os.path.join(app_folder, 'Chart.yaml')
    value_file_path = os.path.join(app_folder, 'values.yaml')
    
    template_output_path = os.path.join(app_folder, app_name + ".template")
    parent = load_template(tpl_file_folder)
    with open(template_output_path, 'w') as f:
        f.write(parent)
    
    if os.path.isfile(helper_file_path):
        with open(helper_file_path, 'r') as f:
            helpers = f.read()
    else:
        helpers = ""
        
    with  open(chart_file_path, 'r') as f:
        cfg = yaml.load(f)
    
    
    with  open(value_file_path, 'r') as f:
        values = yaml.load(f)
    
    chart = {'Version': cfg.get('version', '-'), 'Name': cfg.get('name', '-')}
    template = {
                BASE_TEMPLATE_FILE_NAME:parent, 
                CHILDREN_TEMPLATE_FILE_NAME: TEMPLATE_FARMAT_CONTENT_BEGIN + helpers + TEMPLATE_FARMAT_CONTENT_END
            }
    release = {'IsInstall': True, 'Namespace': u'dev', 'Name': u'test', 'Service': cfg.get('name', '-')}
    html = Jinja2Render(chart, values, release, template)
    
    output_file_path = os.path.join(app_folder, app_name + ".yaml")
    with open(output_file_path, 'w') as f:
        f.write(html)



def render_all():
    workdir = os.path.join(workroot, 'jinja2')
    dirs = os.listdir(workdir)
    
    # load yaml file
    for folder in dirs:
        folder_path = os.path.join(workdir, folder)
        if os.path.isdir(folder_path):
            try:
                render(folder)
            except Exception:
                traceback.print_exc()
            

if __name__ == '__main__':
    try:
        if len(APP_LIST) == 0:
            render_all()
        else:
            for app in APP_LIST:
                render(app)
    except Exception,e:
        traceback.print_exc()