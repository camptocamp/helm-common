# Common functions

This offer all the function from a default Helm chart and in addition:
`common.podConfig`, `common.containerConfig`

The signature of `common.name`, `common.fullname`, `common.labels`, `common.selectorLabels` and
`common.serviceAccountName` is changed to add the `serviceName`.

Then you can quickly define a deployment like this:

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

The hey represent the environment variable name, and the value is a dictionary with a `type` key.

It the type is `value` (default) you can specify the value of the environment variable in `value`, example:

```yaml
env:
  VAR:
    type: value # default
    value: toto
```

It the type is `none` the environment variable will be ignored, example:

```yaml
env:
  VAR:
    type: none
```

If the type is `configMap` or `secret` you should have an `name` with the `ConfigMap` or `Secret` name,
and a `key` to know with key you want to get, example:

```yaml
env:
  VAR:
    type: configMap # or secret
    name: configmap-name
    key: key-in-configmap
```

We also have an attribute `order` to be able to use the `$(env)` syntax, example:

```yaml
env:
  AA_VAR:
    value: aa$(ZZ_VAR)aa
    order: 1
  ZZ_VAR:
    value: zz
```

Currently we put at first the `order` <= `0` and at last the `order` > `0`, default is `0` (first).

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
    "app.kubernetes.io/component" "<servicename>"
  )
)
```
