{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block artifactory__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Expand the name artifactory service.
#}
{%- block artifactory__artifactory__name -%}
{{- Values.nameOverride | default(Values.artifactory.name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Expand the name database service.
#}
{%- block artifactory__database__name -%}
{{- Values.nameOverride | default(Values.database.name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Expand the name nginx service.
#}
{%- block artifactory__nginx__name -%}
{{- Values.nameOverride | default(Values.nginx.name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}


{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block artifactory__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified application name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block artifactory__artifactory__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s-%s" | format(Release.Name,name,Values.artifactory.name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified database name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block artifactory__database__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s-%s" | format(Release.Name,name,Values.database.name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified nginx name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block artifactory__nginx__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s-%s" | format(Release.Name,name,Values.nginx.name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}