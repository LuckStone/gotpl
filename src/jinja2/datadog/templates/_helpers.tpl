{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block datadog__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block datadog__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified confd name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block datadog__confd__fullname -%}
{{- "%s-datadog-confd" | format(Release.Name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified autoconf name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block datadog__autoconf__fullname -%}
{{- "%s-datadog-autoconf" | format(Release.Name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified checksd name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block datadog__checksd__fullname -%}
{{- "%s-datadog-checksd" | format(Release.Name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}
