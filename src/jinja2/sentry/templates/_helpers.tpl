{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block postgresql__fullname -%}
{{- "%s-%s" | format(Release.Name,"postgresql") | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}
{%- block redis__fullname -%}
{{- "%s-%s" | format(Release.Name,"redis") | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}
{%- block smtp__fullname -%}
{{- "%s-%s" | format(Release.Name,"smtp") | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}
