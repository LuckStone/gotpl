{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "mariadb.fullname" -}}
{{- printf "%s-%s" .Release.Name "mariadb" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- if .Values.ingress.enabled -}}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
 name: {{ template "fullname" . }}
 labels:
    app: {{ template "fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
 annotations:
   {{- range $key, $value := .Values.ingress.annotations }}
     {{ $key }}: {{ $value | quote }}
   {{- end }}
spec:
  rules:
    - host: {{ .Values.ingress.hostname }}
      http:
        paths:
          - path: /
            backend:
              serviceName: {{ template "fullname" . }}
              servicePort: 80
{{- if .Values.ingress.tls }}
  tls:
{{ toYaml .Values.ingress.tls | indent 4 }}
{{- end -}}
{{- end -}}


{{- if .Values.persistence.enabled -}}
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{ template "fullname" . }}
  labels:
    app: {{ template "fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
spec:
  accessModes:
    - {{ .Values.persistence.accessMode | quote }}
  resources:
    requests:
      storage: {{ .Values.persistence.size | quote }}
{{- if .Values.persistence.storageClass }}
{{- if (eq "-" .Values.persistence.storageClass) }}
  storageClassName: ""
{{- else }}
  storageClassName: "{{ .Values.persistence.storageClass }}"
{{- end }}
{{- end }}
{{- end -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ template "fullname" . }}
  labels:
    app: {{ template "fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
type: Opaque
data:
  {{ if .Values.wordpressPassword }}
  wordpress-password: {{ default "" .Values.wordpressPassword | b64enc | quote }}
  {{ else }}
  wordpress-password: {{ randAlphaNum 10 | b64enc | quote }}
  {{ end }}
  smtp-password: {{ default "" .Values.smtpPassword | b64enc | quote }}
apiVersion: v1
kind: Service
metadata:
  name: {{ template "fullname" . }}
  labels:
    app: {{ template "fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
spec:
  type: {{ .Values.serviceType }}
  ports:
  - name: http
    port: 80
    targetPort: http
  - name: https
    port: 443
    targetPort: https
  selector:
    app: {{ template "fullname" . }}

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: {{ template "fullname" . }}
  labels:
    app: {{ template "fullname" . }}
    chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
    release: "{{ .Release.Name }}"
    heritage: "{{ .Release.Service }}"
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: {{ template "fullname" . }}
    spec:
      containers:
      - name: {{ template "fullname" . }}
        image: "{{ .Values.image }}"
        imagePullPolicy: {{ default "" .Values.imagePullPolicy | quote }}
        env:
        - name: ALLOW_EMPTY_PASSWORD
        {{- if .Values.allowEmptyPassword }}
          value: "yes"
        {{- else }}
          value: "no"
        {{- end }}
        - name: MARIADB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ template "mariadb.fullname" . }}
              key: mariadb-root-password
        - name: MARIADB_HOST
          value: {{ template "mariadb.fullname" . }}
        - name: MARIADB_PORT_NUMBER
          value: "3306"
        - name: WORDPRESS_DATABASE_NAME
          value: {{ default "" .Values.mariadb.mariadbDatabase | quote }}
        - name: WORDPRESS_DATABASE_USER
          value: {{ default "" .Values.mariadb.mariadbUser | quote }}
        - name: WORDPRESS_DATABASE_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ template "mariadb.fullname" . }}
              key: mariadb-password
        - name: WORDPRESS_USERNAME
          value: {{ default "" .Values.wordpressUsername | quote }}
        - name: WORDPRESS_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ template "fullname" . }}
              key: wordpress-password
        - name: WORDPRESS_EMAIL
          value: {{ default "" .Values.wordpressEmail | quote }}
        - name: WORDPRESS_FIRST_NAME
          value: {{ default "" .Values.wordpressFirstName | quote }}
        - name: WORDPRESS_LAST_NAME
          value: {{ default "" .Values.wordpressLastName | quote }}
        - name: WORDPRESS_BLOG_NAME
          value: {{ default "" .Values.wordpressBlogName | quote }}
        - name: SMTP_HOST
          value: {{ default "" .Values.smtpHost | quote }}
        - name: SMTP_PORT
          value: {{ default "" .Values.smtpPort | quote }}
        - name: SMTP_USER
          value: {{ default "" .Values.smtpUser | quote }}
        - name: SMTP_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ template "fullname" . }}
              key: smtp-password
        - name: SMTP_USERNAME
          value: {{ default "" .Values.smtpUsername | quote }}
        - name: SMTP_PROTOCOL
          value: {{ default "" .Values.smtpProtocol | quote }}
        ports:
        - name: http
          containerPort: 80
        - name: https
          containerPort: 443
        livenessProbe:
          httpGet:
            path: /wp-login.php
          {{- if not .Values.healthcheckHttps }}
            port: http
          {{- else }}
            port: https
            scheme: HTTPS
          {{- end }}
          initialDelaySeconds: 120
          timeoutSeconds: 5
          failureThreshold: 6
        readinessProbe:
          httpGet:
            path: /wp-login.php
          {{- if not .Values.healthcheckHttps }}
            port: http
          {{- else }}
            port: https
            scheme: HTTPS
          {{- end }}
          initialDelaySeconds: 30
          timeoutSeconds: 3
          periodSeconds: 5
        volumeMounts:
        - mountPath: /bitnami/apache
          name: wordpress-data
          subPath: apache
        - mountPath: /bitnami/wordpress
          name: wordpress-data
          subPath: wordpress
        - mountPath: /bitnami/php
          name: wordpress-data
          subPath: php
        resources:
{{ toYaml .Values.resources | indent 10 }}
      volumes:
      - name: wordpress-data
      {{- if .Values.persistence.enabled }}
        persistentVolumeClaim:
          claimName: {{ template "fullname" . }}
      {{- else }}
        emptyDir: {}
      {{ end }}
    {{- if .Values.nodeSelector }}
      nodeSelector:
{{ toYaml .Values.nodeSelector | indent 8 }}
      {{- end -}}
