{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block kube-state-metrics__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
#}
{{ define "kube-state-metrics.fullname" }}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{ printf "%s-%s" Release.Name name | trunc(63) | trimSuffix("-") -}}
{%- endif %}
