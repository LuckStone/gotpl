{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(24) -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(24) -}}
{%- endblock -%}

{%- block toYaml -%}
  {%- for key, value in ..iteritems() %}
    {%- map := kindIs "map" value -%}
    {%- if map %}
{{ key }}:
  {{- include "toYaml" value | indent(2) }}
    {%- else %}
{{ key }}: {{ value }}
    {%- endif %}
  {%- endfor -%}
{%- endblock -%}
