{{/*
Expand the name of the chart.
*/}}
{{- define "common.servicenamePostfix" -}}
{{- if .service.serviceName -}}
{{ printf "-%s" .service.serviceName | trunc 10 }}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "common.name" -}}
{{- default .root.Chart.Name .root.Values.nameOverride | trunc 53 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.fullname" -}}
{{- if .root.Values.fullnameOverride }}
{{- .root.Values.fullnameOverride | trunc 53 | trimSuffix "-" }}{{ include "common.servicenamePostfix" . }}
{{- else }}
{{- $name := default .root.Chart.Name .root.Values.nameOverride }}
{{- if contains $name .root.Release.Name }}
{{- .root.Release.Name | trunc 63 | trimSuffix "-" }}{{ include "common.servicenamePostfix" . }}
{{- else }}
{{- printf "%s-%s" .root.Release.Name $name | trunc 53 | trimSuffix "-" }}{{ include "common.servicenamePostfix" . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Common labels
*/}}
{{- define "common.labels" -}}
helm.sh/chart: {{ include "common.chart" .root }}
{{- if .root.Chart.AppVersion }}
app.kubernetes.io/version: {{ .root.Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
{{ include "common.selectorLabels" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "common.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.name" . }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- if .service.serviceName }}
app.kubernetes.io/component: {{ .service.serviceName }}
{{- else }}
app.kubernetes.io/component: main
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "common.serviceAccountName" -}}
{{- if .root.Values.serviceAccount.create }}
{{- default (include "common.fullname" .) .root.Values.serviceAccount.name }}
{{- else }}
{{- default "default" .root.Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "common.podConfig" }}
{{- with .root.Values.imagePullSecrets }}
imagePullSecrets:
{{- toYaml . | nindent 2 }}
{{- end }}
serviceAccountName: {{ template "common.serviceAccountName" . }}
securityContext: {{- toYaml .root.Values.securityContext | nindent 2 }}
{{- with .service.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
affinity:
  {{- if .service.affinity }}
    {{ toYaml .service.affinity | nindent 2 }}
  {{- else if .affinitySelector }}
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        {{- range $key, $value := .affinitySelector }}
        - key: {{ $key }}
          operator: In
          values:
          - {{ $value }}
        {{- end }}
      topologyKey: "kubernetes.io/hostname"
  {{- else }}
    {{ toYaml .root.Values.affinity | nindent 2 }}
  {{- end }}
{{- with .root.Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{- define "common.containerConfig" -}}
securityContext: {{- toYaml .root.Values.securityContext | nindent 2 }}
{{- if .container.image.sha }}
image: "{{ .container.image.repository }}@sha256:{{ .container.image.sha }}"
{{- else }}
image: "{{ .container.image.repository }}:{{ .container.image.tag }}"
{{- end }}
imagePullPolicy: {{ .root.Values.image.pullPolicy }}
{{- if not ( empty .container.env ) }}
env:
  {{- $configMapNameOverride := .root.Values.configMapNameOverride }}
  {{- range $name, $value := .container.env }}
    {{- if eq ( default "value" $value.type ) "value" }}
    - name: {{ $name | quote }}
      value: {{ $value.value | quote }}
    {{- else }}
    {{- if ne $value.type "none" }}
    - name: {{ $name | quote }}
      valueFrom:
        {{ $value.type }}KeyRef:
          name: {{ default $value.name ( get $configMapNameOverride $value.name ) | quote }}
          key: {{ $value.key | quote }}
    {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
terminationMessagePolicy: FallbackToLogsOnError
resources: {{- toYaml .container.resources | nindent 2 }}
{{- end }}
