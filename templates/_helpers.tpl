{{/*
Expand the name of the chart.
*/}}
{{- define "common.servicenamePostfix" -}}
{{- if .service.serviceName -}}
{{ printf .service.serviceName }}
{{- else if hasKey . "serviceName" -}}
{{ printf .serviceName }}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "common.name" -}}
{{- default .root.Chart.Name .service.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.fullname" -}}
{{- if and ( hasKey .service "fullnameOverride") (.service.fullnameOverride) }}
{{- printf "%s-%s" ( .service.fullnameOverride | trunc 30 | trimSuffix "-" ) ( include "common.servicenamePostfix" . ) | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .root.Chart.Name .service.nameOverride }}
{{- if contains $name .root.Release.Name }}
{{- printf "%s-%s" ( .root.Release.Name | trunc 40 | trimSuffix "-" ) ( include "common.servicenamePostfix" . )  | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" ( ( printf "%s-%s" ( .root.Release.Name | trunc 20 | trimSuffix "-" ) $name ) | trunc 40 | trimSuffix "-" ) ( include "common.servicenamePostfix" . )  | trunc 63 | trimSuffix "-"  }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common.chart" -}}
{{- .Chart.Name | replace "+" "_" | trunc 63 | trimSuffix "-" }}
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
{{- if hasKey .service "serviceName" }}
app.kubernetes.io/component: {{ printf "%s" .service.serviceName }}
{{- else if hasKey . "serviceName" }}
app.kubernetes.io/component: {{ printf "%s" .serviceName }}
{{- else }}
app.kubernetes.io/component: main
{{- end }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "common.serviceAccountName" -}}
{{- if .root.Values.serviceAccount.create }}
{{- default ( include "common.fullname" . ) .root.Values.serviceAccount.name }}
{{- else }}
{{- default "default" .root.Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "common.dictToList" -}}
{{ $keyName := (get . "keyName" | default "name")}}
{{- range $key, $value := .contents -}}
- {{ $keyName }}: {{ $key }}
{{- $value | toYaml | nindent 2 }}
{{ end -}}
{{- end -}}


{{- define "common.podConfig" -}}
{{- with .root.Values.global.image.pullSecrets -}}
imagePullSecrets:
{{- toYaml . | nindent 2 }}
{{ end -}}
serviceAccountName: {{ include "common.serviceAccountName" . }}
securityContext: {{- toYaml .root.Values.podSecurityContext | nindent 2 }}
{{- with .service.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
affinity:
  {{- if and (hasKey .service "affinity") (.service.affinity) -}}
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
  {{- else -}}
    {{ toYaml .root.Values.affinity | nindent 2 }}
  {{- end }}
{{- with .root.Values.tolerations }}
tolerations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{- define "common.oneEnv" -}}
{{- if eq ( default "value" .value.type ) "value" }}
- name: {{ .name | quote }}
  value: {{ .value.value | toYaml }}
{{- else }}
{{- if ne .value.type "none" }}
- name: {{ .name | quote }}
  valueFrom:
    {{ .value.type }}KeyRef:
      name: {{ default .value.name ( get .configMapNameOverride .value.name ) | quote }}
      key: {{ .value.key | quote }}
{{- end }}
{{- end }}
{{- end }}

{{- define "common.containerConfig" -}}
securityContext: {{- toYaml .root.Values.securityContext | nindent 2 }}
{{- if .container.image.sha }}
image: "{{ .container.image.repository }}@sha256:{{ .container.image.sha }}"
{{- else }}
image: "{{ .container.image.repository }}:{{ .container.image.tag }}"
{{- end }}
imagePullPolicy: {{ .root.Values.global.image.pullPolicy }}
{{- if not ( empty .container.env ) }}
env:
  {{- $configMapNameOverride := .root.Values.global.configMapNameOverride }}
  {{- range $name, $value := .container.env }}
    {{- $order := int ( default 0 $value.order ) -}}
    {{- if ( le $order 0 ) }}
      {{- include "common.oneEnv" ( dict "name" $name "value" $value "configMapNameOverride" $configMapNameOverride ) | indent 2 -}}
    {{- end }}
  {{- end }}
  {{- range $name, $value := .container.env }}
    {{- $order := int ( default 0 $value.order ) -}}
    {{- if ( gt $order 0 ) }}
      {{- include "common.oneEnv" ( dict "name" $name "value" $value "configMapNameOverride" $configMapNameOverride ) | indent 2 -}}
    {{- end }}
  {{- end }}
{{- end }}
terminationMessagePolicy: FallbackToLogsOnError
resources: {{- toYaml .container.resources | nindent 2 }}
{{- end }}

{{- define "common.metadata" -}}
labels: {{ include "common.labels" . | nindent 2 }}
{{- with .service.labels }}
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .service.annotations }}
annotations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{- define "common.podMetadata" -}}
labels: {{ include "common.selectorLabels" . | nindent 2 }}
{{- with .service.podLabels }}
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- with .service.podAnnotations }}
annotations:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}
