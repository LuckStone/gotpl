{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block orangehrm__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block orangehrm__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block orangehrm__mariadb__fullname -%}
{{- "%s-%s" | format(Release.Name,"mariadb") | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}
