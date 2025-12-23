{{/*
Expand the name of the chart.
*/}}
{{- define "bitcoind.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "bitcoind.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s" $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "bitcoind.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "bitcoind.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: node
app.kubernetes.io/part-of: bitcoin
{{- end }}

{{/*
Selector labels
*/}}
{{- define "bitcoind.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bitcoind.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Network flag - returns the appropriate network flag for non-mainnet networks
*/}}
{{- define "bitcoind.networkFlag" -}}
{{- if eq .Values.bitcoin.network "testnet" -}}
- "-testnet"
{{- else if eq .Values.bitcoin.network "signet" -}}
- "-signet"
{{- else if eq .Values.bitcoin.network "regtest" -}}
- "-regtest"
{{- end -}}
{{- end }}
