{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block cluster-autoscaler__name -%}
{{- default ("%s-%s" | format(Values.cloudProvider,Chart.Name) ) Values.nameOverride | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block cluster-autoscaler__fullname -%}
{%- set name = default ("%s-%s" | format(Values.cloudProvider,Chart.Name) ) Values.nameOverride -%}
{%- if name!=Release.Name -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- else -%}
{{- "%s" | format(name) | trunc(63) | trimSuffix("-") -}}
{%- endif -%}
{%- endblock -%}
