{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block acs-engine-autoscaler__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block acs-engine-autoscaler__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Credit: @technosophos
https://github.com/technosophos/common-chart/
labels.standard prints the standard Helm labels.
The standard labels are frequently used in metadata.
#}
{%- block acs-engine-autoscaler__labels__standard -%}
app: {{ self.acs-engine-autoscaler__name() }}
heritage: {{ Release.Service | quote() }}
release: {{ Release.Name | quote() }}
chart: {{ self.acs-engine-autoscaler__chartref() }}
{%- endblock -%}

{#
Credit: @technosophos
https://github.com/technosophos/common-chart/
chartref prints a chart name and version.
It does minimal escaping for use in Kubernetes labels.
Example output:
  zookeeper-1.2.3
  wordpress-3.2.1_20170219
#}
{%- block acs-engine-autoscaler__chartref -%}
  {{- replace("+", "_", Chart.Version) | printf("%s-%s", Chart.Name) -}}
{%- endblock -%}