{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block kube2iam__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block kube2iam__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{%- if name!=Release.Name -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- else -%}
{{- "%s" | format(name) | trunc(63) | trimSuffix("-") -}}
{%- endif -%}
{%- endblock -%}
