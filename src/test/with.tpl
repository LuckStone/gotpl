        {{ with .Values.resizer }}
        image: "{{ .image.repository }}:{{ .image.tag }}"
        imagePullPolicy: {{ .image.pullPolicy }}
        resources:
{{ toYaml .resources | indent 12 }}
        env:
          - name: MY_POD_NAME
            valueFrom:
              fieldRef:
                fieldPath: metadata.name
          - name: MY_POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
        {{- end }}