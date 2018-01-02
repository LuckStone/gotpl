{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block ipfs__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block ipfs__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a name for the service to use.

We allow overrides for name of service, since this service provides an API that could be directly
called by end-users. For example, you could call it 'ipfs' and then all users running in a namespace
could just connect to it by specifying 'ipfs'.
#}
{%- block ipfs__servicename -%}
{%- if Values.service.nameOverride -%}
{{- Values.service.nameOverride -}}
{%- else -%}
{{- self.ipfs__fullname() }}
{%- endif -%}
{%- endblock -%}
