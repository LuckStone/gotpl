{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block mongodb-replicaset__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block mongodb-replicaset__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create the name for the admin secret.
#}
{%- block mongodb-replicaset__adminSecret -%}
    {%- if Values.auth.existingAdminSecret -%}
        {{- Values.auth.existingAdminSecret -}}
    {%- else -%}
        {{- self.mongodb-replicaset__fullname() -}}-admin
    {%- endif -%}
{%- endblock -%}

{#
Create the name for the key secret.
#}
{%- block mongodb-replicaset__keySecret -%}
    {%- if Values.auth.existingKeySecret -%}
        {{- Values.auth.existingKeySecret -}}
    {%- else -%}
        {{- self.mongodb-replicaset__fullname() -}}-keyfile
    {%- endif -%}
{%- endblock -%}
