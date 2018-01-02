{# vim: set filetype=mustache: #}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block fullname -%}
{{- "%s-%s" | format(Release.Name,Chart.Name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}
