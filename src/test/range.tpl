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



command:
  - ./cluster-autoscaler
  - --cloud-provider=aws
{{- range .Values.autoscalingGroups }}
  - --nodes={{ .minSize }}:{{ .maxSize }}:{{ .name }}
{{- end }}
  - --scale-down-delay={{ .Values.scaleDownDelay }}
  - --skip-nodes-with-local-storage={{ .Values.skipNodes.withLocalStorage }}
  - --skip-nodes-with-system-pods={{ .Values.skipNodes.withSystemPods }}
  - --v=4
{{- range $key, $value := .Values.extraArgs }}
  - --{{ $key }}={{ $value }}
{{- end }}

{{- range $nodeCount }}
- http://{{ template "minio.fullname" . }}-{{ . }}.{{ template "minio.fullname" . }}.{{ .Release.Namespace }}.svc.cluster.local{{ .Values.mountPath }}
{{- end }}