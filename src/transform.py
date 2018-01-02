#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Copyright (c) 20016-2016 The Cloudsoar.
# See LICENSE for details.
'''
Created on 2017年10月30日

@author: Cloudsoar
'''

import os
import traceback

from src.const import APP_LIST
from src.parse import  HelmParser


workroot = os.path.dirname(os.path.abspath(__file__))


def transform_all():
    workdir = os.path.join(workroot, 'helm')
    dirs = os.listdir(workdir)
    
    # load yaml file
    for folder in dirs:
        folder_path = os.path.join(workdir, folder)
        if os.path.isdir(folder_path):
            try:
                transform(folder)
            except Exception:
                traceback.print_exc()

def transform(app_name):
    app_folder = os.path.join(workroot, 'helm', app_name, 'templates')
    output_folder = os.path.join(workroot, 'jinja2', app_name, 'templates')
    dirs = os.listdir(app_folder)
    for filename in dirs:
        if not (filename.endswith('.yaml') or filename.endswith('.yml') or filename.endswith('.tpl')):
            continue
        
        file_path = os.path.join(app_folder, filename)
        if not os.path.isfile(file_path):
            continue

        parser = HelmParser()
        try:
            txt = parser.parse(file_path)
        except Exception:
            traceback.print_exc()
        else:
            out_put_path = os.path.join(output_folder, filename)
            with open(out_put_path, 'w') as f:
                f.write(txt)


if __name__ == '__main__':
    try:
        if len(APP_LIST) == 0:
            transform_all()
        else:
            for app in APP_LIST:
                transform(app)
    except Exception,e:
        traceback.print_exc()