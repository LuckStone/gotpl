{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{% block kubernetes-dashboard__name %}{{ default "kubernetes-dashboard" Values.nameOverride | trunc(63) }}{{- end }}

{#
Create a default fully qualified app name.

We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
#}
{% block kubernetes-dashboard__fullname %}
{%- set name = default "kubernetes-dashboard" Values.nameOverride -%}
{{ "%s-%s" | format(Release.Name,name) | trunc(63) -}}
{%- endblock %}
