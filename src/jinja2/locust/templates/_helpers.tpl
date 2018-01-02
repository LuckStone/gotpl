{# vim: set filetype=mustache: #}
{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block locust__fullname -%}
{{- "%s-%s" | format(Release.Name,"locust") | trunc(63) -}}
{%- endblock -%}

{%- block locust__master-svc -%}
{{- "%s-%s" | format(Release.Name,"master-svc") | trunc(63) -}}
{%- endblock -%}

{%- block locust__master -%}
{{- "%s-%s" | format(Release.Name,"master") | trunc(63) -}}
{%- endblock -%}

{%- block locust__worker -%}
{{- "%s-%s" | format(Release.Name,"worker") | trunc(63) -}}
{%- endblock -%}

{#
Create fully qualified configmap name.
#}
{%- block locust__worker-configmap -%}
{{- "%s-%s" | format(Release.Name,"worker") -}}
{%- endblock -%}
