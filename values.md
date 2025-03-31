# HELM common

## Properties

- <a id="properties/global"></a>**`global`** _(object)_: Can contain additional properties.
- <a id="properties/nameOverride"></a>**`nameOverride`**: Refer to _[#/definitions/nameOverride](#definitions/nameOverride)_.
- <a id="properties/fullnameOverride"></a>**`fullnameOverride`**: Refer to _[#/definitions/fullnameOverride](#definitions/fullnameOverride)_.
- <a id="properties/releaseTrunc"></a>**`releaseTrunc`**: Refer to _[#/definitions/releaseTrunc](#definitions/releaseTrunc)_.
- <a id="properties/prefixTrunc"></a>**`prefixTrunc`**: Refer to _[#/definitions/prefixTrunc](#definitions/prefixTrunc)_.
- <a id="properties/labels"></a>**`labels`**: Refer to _[#/definitions/labels](#definitions/labels)_.
- <a id="properties/annotations"></a>**`annotations`**: Refer to _[#/definitions/annotations](#definitions/annotations)_.
- <a id="properties/serviceName"></a>**`serviceName`**: Refer to _[#/definitions/serviceName](#definitions/serviceName)_.

## Definitions

- <a id="definitions/nameOverride"></a>**`nameOverride`** _(string)_: [helm-common] Override the name (can be in the service or values).
- <a id="definitions/fullnameOverride"></a>**`fullnameOverride`** _(string)_: [helm-common] Override the fullname (can be in the service or values).
- <a id="definitions/releaseNameOverride"></a>**`releaseNameOverride`** _(string)_: [helm-common] Override the the release name (can be in the service, values or global).
- <a id="definitions/releaseTrunc"></a>**`releaseTrunc`** _(integer)_: [helm-common] The release name trunk length (can be in the service, values or global). Default: `20`.
- <a id="definitions/nameTrunc"></a>**`nameTrunc`** _(integer)_: [helm-common] The chart name trunk length (can be in the service, values or global). Default: `63`.
- <a id="definitions/prefixTrunc"></a>**`prefixTrunc`** _(integer)_: [helm-common] The prefix trunk length (release and chart name) (can be in the service, values or global). Default: `40`.
- <a id="definitions/labels"></a>**`labels`** _(object)_: [helm-common] Labels. Can contain additional properties.
  - <a id="definitions/labels/additionalProperties"></a>**Additional properties** _(string)_
- <a id="definitions/annotations"></a>**`annotations`** _(object)_: [helm-common] Annotations. Can contain additional properties.
  - <a id="definitions/annotations/additionalProperties"></a>**Additional properties** _(string)_
- <a id="definitions/serviceName"></a>**`serviceName`** _(string)_: [helm-common] The name of the service (not Kubernetes service), this will postfix the name.
