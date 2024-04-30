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
{{- $releaseTrunc := default 20 ( int .service.releaseTrunc ) }}
{{- $prefixTrunc := default 40 ( int .service.prefixTrunc ) }}
{{- printf "%s-%s" ( ( printf "%s-%s" ( .root.Release.Name | trunc $releaseTrunc | trimSuffix "-" ) $name ) | trunc $prefixTrunc | trimSuffix "-" ) ( include "common.servicenamePostfix" . )  | trunc 63 | trimSuffix "-"  }}
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

{{- define "common.dictToList" -}}
{{ $keyName := (get . "keyName" | default "name")}}
{{- range $key, $value := .contents -}}
- {{ $keyName }}: {{ $key }}
{{- $value | toYaml | nindent 2 }}
{{ end -}}
{{- end -}}

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
