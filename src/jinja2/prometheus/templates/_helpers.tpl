{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block prometheus__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block prometheus__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a fully qualified alertmanager name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block prometheus__alertmanager__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s-%s" | format(Release.Name,name,Values.alertmanager.name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a fully qualified kube-state-metrics name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block prometheus__kubeStateMetrics__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s-%s" | format(Release.Name,name,Values.kubeStateMetrics.name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a fully qualified node-exporter name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block prometheus__nodeExporter__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s-%s" | format(Release.Name,name,Values.nodeExporter.name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a fully qualified Prometheus server name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block prometheus__server__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s-%s" | format(Release.Name,name,Values.server.name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a fully qualified pushgateway name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block prometheus__pushgateway__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s-%s" | format(Release.Name,name,Values.pushgateway.name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Return the appropriate apiVersion for networkpolicy.
#}
{%- block prometheus__networkPolicy__apiVersion -%}
{%- if (Capabilities.KubeVersion.Minor>="4") and (Capabilities.KubeVersion.Minor<="6") -%}
{{- "extensions/v1beta1" -}}
{%- elif Capabilities.KubeVersion.Minor>="7" -%}
{{- "networking.k8s.io/v1" -}}
{%- endif -%}
{%- endblock -%}
