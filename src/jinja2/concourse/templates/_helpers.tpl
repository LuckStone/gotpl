{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block concourse__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified concourse name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block concourse__concourse__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{%- block concourse__web__fullname -%}
{%- set name = Values.web.nameOverride | default("web", true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{%- block concourse__worker__fullname -%}
{%- set name = Values.worker.nameOverride | default("worker", true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified postgresql name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block concourse__postgresql__fullname -%}
{%- set name = Values.postgresql.nameOverride | default("postgresql", true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(24) | trimSuffix("-") -}}
{%- endblock -%}
