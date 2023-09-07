## Common functions

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
  {{- include "common.metadata" ( dict "root" . "service" .Values ) | nindent 2 }}
spec:
  replicas: {{ .Values.replicaCount }}
  strategy:
    type: RollingUpdate
  selector:
    matchLabels: {{- include "common.selectorLabels" ( dict "root" . "service" .Values ) | nindent 6 }}
  template:
    metadata: {{- include "common.podMetadata" ( dict "root" . "service" .Values ) | nindent 6 }}
    spec: {{- include "common.podConfig" ( dict "root" . "service" .Values ) | nindent 6 }}
      containers:
        - name: "main"
          {{- include "common.containerConfig" ( dict "root" . "container" .Values ) | nindent 10 }}
```

In general it do the same thing than the default Helm chart, the following chapter describe the specific things.

[Good example of using most of the functions](https://github.com/camptocamp/helm-custom-pod/blob/master/templates/deployment.yaml).

### Service name

### `common.servicenamePostfix`

Expand the name of the chart.

Parameters:

- `service`: the service object.
- `serviceName`: the service name default value (optional).

Used values:

- [`serviceName`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/serviceName) from the service object.

### `common.name`

Expand the name of the chart.

Parameters:

- `root`: the root object, should be `$`.
- `service`: the service object.

Used values:

- [`nameOverride`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/nameOverride) from the service object.

### `common.fullname`

Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.

Parameters:

- `root`: the root object, should be `$`.
- `service`: the service object.

Used values:

- [`fullnameOverride`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/fullnameOverride) from the service object.
- [`nameOverride`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/nameOverride) from the service object.
- [`releaseTrunc`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/releaseTrunc) from the service object.
- [`prefixTrunc`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/prefixTrunc) from the service object.

Used functions:

- `common.servicenamePostfix`

### `common.chart`

Create chart name and version as used by the chart label.

The root (`$`) should be directly passed as parameter.

### `common.labels`

Create the labels for the service.

Parameters:

- `root`: the root object, should be `$`.

Used values:

Used functions:

- `common.chart`
- `common.selectorLabels`

### `common.selectorLabels`

Create the selector labels for the service.

Parameters:

- `root`: the root object, should be `$`.
- `service`: the service object.
- `serviceName`: the service name default value (optional).

Used values:

- [`serviceName`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/serviceName) from the service object.

Used functions:

- `common.name`

### `common.serviceAccountName`

Create the name of the service account to use.

Parameters:

- `root`: the root object, should be `$`.

Used values:

- [`serviceAccount`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/serviceAccount) from the values root (`$.Values`).

### `common.dictToList`

Convert a dictionary to a list.

Used to pass a dictionary to Kubernetes but configure a dict in the values to ve able to override them.

Example, by default this:

```yaml
name_1:
  key: value
name_2:
  key: value
```

is transformed into this:

```yaml
- name: name_1
  key: value
- name: name_2
  key: value
```

Parameters:

- `keyName`: the name of the key to use in the list (default is 'name').

### `common.podConfig`

Create the pod configuration.

Parameters:

- `root`: the root object, should be `$`.
- `service`: the service object.
- `affinitySelector`: the affinity selector (optional).

Used values:

- [`image`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/globalImage) from the global values (`$.Values.global`).
- [`podSecurityContext`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/podSecurityContext) from the values root (`$.Values`).
- [`nodeSelector`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/nodeSelector) from the service object.
- [`affinity`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/affinity) from the service object.
- [`tolerations`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/tolerations) from the values root (`$.Values`).

Used Functions:

- `common.serviceAccountName`

### `common.oneEnv`

Create one environment variable.

Parameters:

- `root`: the root object, should be `$`.
- `name`: the name of the environment variable.
- `value`: the definition of the [environment variable](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/env).
- [`configMapNameOverride`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/configMapNameOverride): the name override of the ConfigMap to use.

Used functions:

- `common.fullname`

### `common.containerConfig`

Create the container configuration.

Parameters:

- `root`: the root object, should be `$`.
- `container`: the container definition.

Used values:

- [`securityContext`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/securityContext) from the values root (`$.Values`).
- [`image`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/image) from the container object.
- [`image`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/globalImage) from the global values (`$.Values.global`).
- [`env`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/env) from the container object.
- [`configMapNameOverride`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/configMapNameOverride) from the global values (`$.Values.global`).
- [`resources`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/resources) from the container object.

Used functions:

- `common.oneEnv`

### `common.metadata`

Create the metadata for the Kubernetes object.

Parameters:

- `service`: the service object.

Used values:

- [`labels`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/labels) from the service object.
- [`annotations`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/annotations) from the service object.

Used functions:

- `common.labels`

### `common.podMetadata`

Create the metadata for the Pod.

Parameters:

- `service`: the service object.

Used values:

- [`podLabels`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/podLabels) from the service object.
- [`podAnnotations`](https://github.com/camptocamp/helm-common/blob/master/values.md#definitions/podAnnotations) from the service object.

Used functions:

- `common.selectorLabels`

### Environment variables

In the container config you should define an `env` and `configMapNameOverride` dictionaries with, for the env:

The hey represent the environment variable name, and the value is a dictionary with a `type` key.

It the type is `value` (default) you can specify the value of the environment variable in `value`, example:

```yaml
env:
  VAR:
    type: value # default
    value: toto
```

If the type is `none` the environment variable will be ignored, example:

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

## Image name

In the container config you should define the image like this:

```yaml
image:
  repository: camptocamp/mapserver
  tag: latest
  sha:
  pullPolicy: IfNotPresent
```

The sha will be taken in priority of the tag

## Pod affinity

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

## Schema documentation

Documentation based on the schema defined in [values.md](./values.md).

## Pre commit hooks

[pre-commit](https://pre-commit.com/) hook used to generate and check your expected template.

### Adding to your `.pre-commit-config.yaml`

```yaml
ci:
  skip:
    - heml-template-gen

repos:
  - repo: https://github.com/camptocamp/helm-common
    rev: <version> # Use the ref you want to point at
    hooks:
      - id: helm-template-gen
        files: |-
          (?x)(
            ^templates/.*$
            |^values\.yaml$
            |^Chart\.yaml$
            |tests/values\.yaml$
          )
        args:
          - --values=tests/values.yaml
          - release-name
          - .
          - tests/expected.yaml
```

## Contributing

Install the pre-commit hooks:

```bash
pip install pre-commit
pip install -e .
pre-commit install --allow-missing-config
```
