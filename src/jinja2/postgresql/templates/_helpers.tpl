{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block postgresql__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block postgresql__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Return the appropriate apiVersion for networkpolicy.
#}
{%- block postgresql__networkPolicy__apiVersion -%}
{%- if (Capabilities.KubeVersion.Minor>="4") and (Capabilities.KubeVersion.Minor<="6") -%}
"extensions/v1beta1"
{%- elif Capabilities.KubeVersion.Minor>="7" -%}
"networking.k8s.io/v1"
{%- endif -%}
{%- endblock -%}
