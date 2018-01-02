{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block gitlab-ee__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block gitlab-ee__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block gitlab-ee__postgresql__fullname -%}
{{- "%s-%s" | format(Release.Name,"postgresql") | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified redis name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block gitlab-ee__redis__fullname -%}
{{- "%s-%s" | format(Release.Name,"redis") | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}
