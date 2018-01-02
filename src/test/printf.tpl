{{- printf "%s-%s" Release.Name $name | trunc 63 | trimSuffix "-" -}}

{{- if ne ( printf "%s" .Values.minecraftServer.eula ) "FALSE" }}
apiVersion: extensions/v1beta1
{{- end -}}

{{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}