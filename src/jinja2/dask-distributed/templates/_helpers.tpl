{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block dask-distributed__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(24) -}}
{%- endblock -%}

{#
Create fully qualified names.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block dask-distributed__scheduler-fullname -%}
{%- set name = Values.scheduler.name | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(24) -}}
{%- endblock -%}

{%- block dask-distributed__webui-fullname -%}
{%- set name = Values.webUI.name | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(24) -}}
{%- endblock -%}

{%- block dask-distributed__worker-fullname -%}
{%- set name = Values.worker.name | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(24) -}}
{%- endblock -%}

{%- block dask-distributed__jupyter-fullname -%}
{%- set name = Values.jupyter.name | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(24) -}}
{%- endblock -%}
