{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block mailhog__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block mailhog__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create the name for the auth secret.
#}
{%- block mailhog__authFileSecret -%}
    {%- if Values.auth.existingKeySecret -%}
        {{- Values.auth.existingKeySecret -}}
    {%- else -%}
        {{- self.mailhog__fullname() -}}-auth
    {%- endif -%}
{%- endblock -%}

{#
Create the name for the tls secret.
#}
{%- block mailhog__tlsSecret -%}
    {%- if Values.ingress.tls.existingSecret -%}
        {{- Values.ingress.tls.existingSecret -}}
    {%- else -%}
        {{- self.mailhog__fullname() -}}-tls
    {%- endif -%}
{%- endblock -%}
