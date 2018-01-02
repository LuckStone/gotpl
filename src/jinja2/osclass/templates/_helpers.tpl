{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block osclass__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block osclass__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block osclass__mariadb__fullname -%}
{{- "%s-%s" | format(Release.Name,"mariadb") | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Get the user defined LoadBalancerIP for this release.
Note, returns 127.0.0.1 if using ClusterIP.
#}
{%- block osclass__serviceIP -%}
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
{%- block osclass__host -%}
{%- set host =  Values | index(("%sHost")| format(Chart.Name) ) | default("") -%}
{{- default  (self.osclass__serviceIP())  host -}}
{%- endblock -%}
