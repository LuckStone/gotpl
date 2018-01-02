serviceAccountName: {{ if .Values.rbac.create }}{{ template "fullname" . }}{{ else }}"{{ .Values.rbac.serviceAccountName }}"{{ end }}


{{ if $middleware.path }}path {{ $middleware.path }}{{ end }}

{{- if and .Values.persistence.enabled .Values.persistence.drupal.hostPath (not .Values.persistence.drupal.existingClaim) -}}
apiVersion: gggggggggggg
{% endif -%}


{{- if and (and .Values.coscale.appId .Values.coscale.accessToken) .Values.coscale.templateId -}}
apiVersion: aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
{{- end }}

{{ if (and (eq .Values.Master.ServiceType "NodePort") (not (empty .Values.Master.NodePort))) }}
nodePort: {{.Values.Master.NodePort}}
{{ end }}


spec:
  type: {{ .Values.single.service.type }}
  ports:
  {{- range $key, $value := .Values.single.config.inputs }}
    {{- if eq $key "http_listener" }}
  - port: {{ trimPrefix ":" $value.service_address | int64 }}
    targetPort: {{ trimPrefix ":" $value.service_address | int64 }}
    name: "http-listener"
    {{- end }}
    {{- if eq $key "statsd" }}
  - port: {{ trimPrefix ":" $value.service_address | int64 }}
    targetPort: {{ trimPrefix ":" $value.service_address | int64 }}
    name: "statsd"
    {{- end }}
    {{- if eq $key "tcp-listener" }}
  - port: {{ trimPrefix ":" $value.service_address | int64 }}
    targetPort: {{ trimPrefix ":" $value.service_address | int64 }}
    name: "tcp_listener"
    {{- end }}
    {{- if eq $key "udp-listener" }}
  - port: {{ trimPrefix ":" $value.service_address | int64 }}
    targetPort: {{ trimPrefix ":" $value.service_address | int64 }}
    name: "udp_listener"
    {{- end }}
    {{- if eq $key "webhooks" }}
  - port: {{ trimPrefix ":" $value.service_address | int64 }}
    targetPort: {{ trimPrefix ":" $value.service_address | int64 }}
    name: "webhooks"
    {{- end }}
  {{- end }}

compress = {{ .Values.gzip.enabled }}
  {{- if and .Values.ssl.enabled .Values.ssl.enforced }}
  [entryPoints.http.redirect]
    entryPoint = "https"
  {{- end }}

env:
- name: ALLOW_EMPTY_PASSWORD
{{- if .Values.allowEmptyPassword }}
  value: "yes"
{{- else }}
  value: "no"
{{- end }}

[kubernetes]
{{- if .Values.kubernetes}}
  {{- if .Values.kubernetes.namespaces }}
namespaces = [
    {{- range $idx, $element := .Values.kubernetes.namespaces }}
        {{- if $idx }}, {{ end }}
        {{- $element | quote }}
    {{- end -}}
    ]
  {{- end}}
  {{- if .Values.kubernetes.labelSelector }}
labelselector = {{ .Values.kubernetes.labelSelector | quote }}
  {{- end}}
{{- end}}

{{- define "cockroachdb.networkPolicy.apiVersion" -}}
{{- if and (ge .Capabilities.KubeVersion.Minor "4") (le .Capabilities.KubeVersion.Minor "6") -}}
{{- print "extensions/v1beta1" -}}
{{- else if ge .Capabilities.KubeVersion.Minor "7" -}}
{{- print "networking.k8s.io/v1" -}}
{{- end -}}
{{- end -}}