# Common functions

This offer all the function from a default Helm chart and in addition:
`common.podConfig`, `common.podConfig`

The signature of `common.name`, `common.fullname`, `common.labels`, `common.selectorLabels` and
`common.serviceAccountName` is changed to add the `serviceName`.

Then you can quickliy define a deployment like this:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "common.fullname" ( dict "root" . "service" .Values ) }}
  labels: {{ include "common.labels2" ( dict "root" . "service" .Values ) | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  strategy:
    type: RollingUpdate
  selector:
    matchLabels: {{- include "common.selectorLabels2" ( dict "root" . "service" .Values ) | nindent 6 }}
  template:
    metadata:
      labels: {{- include "common.selectorLabels2" ( dict "root" . "service" .Values ) | nindent 8 }}
    spec: {{- include "common.podConfig" ( dict "root" . "service" .Values ) | nindent 6 }}
      containers:
        - name: "main"
          {{- include "common.containerConfig" ( dict "root" . "container" .Values ) | nindent 10 }}
```

In general it do the same thing than the default Helm chart, the following chapter describe the specific things.

## Service name

A `serviceName` configuration to be able to add a service name (to be able to have more than one pod in a chart)

## Environment variables

In the container config you should define an `env` and `configMapNameOverride` dictionaries with, for the env:

The hey represent the environment variavle name, and the value is a dictionary with a `type` key.

It the type is `value` (default) you can specify the value of the environment variavle in `value`.

It the type is `none` the environament variable will be ignored.

If the type is `configMap` or `secret` you should have an `name` with the `ConfigMap` or `Secret` name,
and a `key` to know with key you want to get.

# Image name

In the container config you should define the image like this:

```yaml
image:
  repository: camptocamp/mapserver
  tag: latest
  sha:
  pullPolicy: IfNotPresent
```

The sha will be taken in priority of the tag

# Pod affinity

In the `podConfig` you can have an `affinitySelector` to be able to configure a `podAntiAffinity`.

Example:

```
common.podConfig" ( dict
  "root" .
  "service" .Values
  "affinitySelector" (dict
    "app.kubernetes.io/instance" .Release.Name
    "app.kubernetes.io/name" ( include "common.name" . )
    "service" "<servicename>"
  )
)
```
