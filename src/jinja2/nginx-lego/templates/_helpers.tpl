{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block nginx-lego__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(24) -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block nginx-lego__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(24) -}}
{%- endblock -%}
