{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified controller name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block controller__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s-%s" | format(Release.Name,name,Values.controller.name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Construct the path for the publish-service.

By convention this will simply use the <namesapce>/<controller-name> to match the name of the
service generated.

Users can provide an override for an explicit service they want bound via `.Values.controller.publishService.pathOverride`

#}
{%- block controller__publishServicePath -%}
{%- set defServiceName = "%s/%s" | format(Release.Namespace,(self.controller__fullname() )) -%}
{%- set servicePath = Values.controller.publishService.pathOverride | default(defServiceName, true) %}
{{- print servicePath | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified default backend name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block defaultBackend__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s-%s" | format(Release.Name,name,Values.defaultBackend.name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}
