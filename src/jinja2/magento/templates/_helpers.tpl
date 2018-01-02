{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block magento__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block magento__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a random alphanumeric password string.
We append a random number to the string to avoid password validation errors
#}
{%- block magento__randomPassword -%}
{{- randAlphaNum(9) -}}{{- randNumeric 1 -}}
{%- endblock -%}

{#
Get the user defined password or use a random string
#}
{%- block magento__password -%}
{%- set password =  Values | index(("%sPassword")| format(Chart.Name) ) -%}
{{- default  (self.magento__randomPassword())  password -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block magento__mariadb__fullname -%}
{{- "%s-%s" | format(Release.Name,"mariadb") | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Get the user defined LoadBalancerIP for this release.
Note, returns 127.0.0.1 if using ClusterIP.
#}
{%- block magento__serviceIP -%}
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
{%- block magento__host -%}
{%- set host =  Values | index(("%sHost")| format(Chart.Name) ) | default("") -%}
{{- default  (self.magento__serviceIP())  host -}}
{%- endblock -%}
