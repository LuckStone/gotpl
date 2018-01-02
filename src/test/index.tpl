"{{ index .Values "etcd-operator" "cluster" "name" }}-client:2379"
{{- index .Values (printf "%sLoadBalancerIP" .Chart.Name) | default "" -}}
{{- $host := index .Values (printf "%sHost" .Chart.Name) | default "" -}}