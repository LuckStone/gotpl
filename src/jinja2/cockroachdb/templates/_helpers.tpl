{#
Return the appropriate apiVersion for networkpolicy.
#}
{%- block cockroachdb__networkPolicy__apiVersion -%}
{%- if (Capabilities.KubeVersion.Minor>="4") and (Capabilities.KubeVersion.Minor<="6") -%}
{{- "extensions/v1beta1" -}}
{%- elif Capabilities.KubeVersion.Minor>="7" -%}
{{- "networking.k8s.io/v1" -}}
{%- endif -%}
{%- endblock -%}
