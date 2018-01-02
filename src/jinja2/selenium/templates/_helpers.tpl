{# vim: set filetype=mustache: #}
{#
Expand the name of the chart.
#}
{%- block selenium__name -%}
{{- Values.nameOverride | default(Chart.Name, true) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block selenium__fullname -%}
{%- set name = Values.nameOverride | default(Chart.Name, true) -%}
{{- "%s-%s" | format(Release.Name,name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name, for hub.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block selenium__hub__fullname -%}
{{- "%s-selenium-hub" | format(Release.Name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name, for chrome.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block selenium__chrome__fullname -%}
{{- "%s-selenium-chrome" | format(Release.Name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name, for chromeDebug.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block selenium__chromeDebug__fullname -%}
{{- "%s-selenium-chrome-debug" | format(Release.Name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name, for firefox.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block selenium__firefox__fullname -%}
{{- "%s-selenium-firefox" | format(Release.Name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

{#
Create a default fully qualified app name, for firefoxDebug.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
#}
{%- block selenium__firefoxDebug__fullname -%}
{{- "%s-selenium-firefox-debug" | format(Release.Name) | trunc(63) | trimSuffix("-") -}}
{%- endblock -%}

