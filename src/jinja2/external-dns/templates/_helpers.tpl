{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block external-dns__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block external-dns__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{%- if name!=Release.Name -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- else -%}
{{- "%s" | format(name) | trunc(63) | trimSuffix("-") -}}
{%- endif -%}
{%- endblock -%}

{# Generate basic labels #}
{%- block external-dns__labels %}
app: {{ self.external-dns__name() }}
heritage: {{ Release.Service }}
release: {{ Release.Name }}
{%- if Values.podLabels %}
{{ toYaml(Values.podLabels) }}
{%- endif %}
{%- endblock %}
