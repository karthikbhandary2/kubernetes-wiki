{{/*
Expand the name of the chart.
*/}}
{{- define "wiki-chart.name" -}}
{{ .Chart.Name }}
{{- end }}

{{/*
Create a fully qualified name.
*/}}
{{- define "wiki-chart.fullname" -}}
{{- if .Release.Name }}
{{ printf "%s-%s" .Release.Name .Chart.Name }}
{{- else }}
{{ .Chart.Name }}
{{- end }}
{{- end }}

{{/*
Chart version and name combined
*/}}
{{- define "wiki-chart.chart" -}}
{{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
{{- end }}

{{/*
Standard chart labels
*/}}
{{- define "wiki-chart.labels" -}}
helm.sh/chart: {{ include "wiki-chart.chart" . }}
app.kubernetes.io/name: {{ include "wiki-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Return the name of the service account to use
*/}}
{{- define "wiki-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
  {{- if .Values.serviceAccount.name }}
{{ .Values.serviceAccount.name }}
  {{- else }}
{{ include "wiki-chart.fullname" . }}
  {{- end }}
{{- else }}
  {{- if .Values.serviceAccount.name }}
{{ .Values.serviceAccount.name }}
  {{- else }}
default
  {{- end }}
{{- end }}
{{- end }}
