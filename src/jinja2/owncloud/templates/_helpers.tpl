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
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block mariadb__fullname -%}
{{- "%s-%s" | format(Release.Name,"mariadb") | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Get the user defined LoadBalancerIP for this release.
Note, returns 127.0.0.1 if using ClusterIP.
#}
{%- block serviceIP -%}
{%- if Values.serviceType=="ClusterIP" -%}
127.0.0.1
{%- else -%}
{{- Values | index(("%sLoadBalancerIP")| format(Chart.Name) ) | default("") -}}
{%- endif -%}
{%- endblock -%}

{#
Gets the host to be used for this application.
If not using ClusterIP, or if a host or LoadBalancerIP is not defined, the value will be empty.
#}
{%- block host -%}
{%- set host =  Values | index(("%sHost")| format(Chart.Name) ) | default("") -%}
{{- default  (self.serviceIP())  host -}}
{%- endblock -%}
