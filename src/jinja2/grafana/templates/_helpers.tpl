{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block grafana__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block grafana__fullname -%}
{%- set name = Values.nameOverride | default("grafana", true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a fully qualified server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block grafana__server__fullname -%}
{{- "%s-%s" | format(Release.Name,"grafana") | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}
