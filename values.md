# HELM common

## Properties

- **`global`** _(object)_: Can contain additional properties.
- **`nameOverride`**: Refer to _[#/definitions/nameOverride](#definitions/nameOverride)_.
- **`fullnameOverride`**: Refer to _[#/definitions/fullnameOverride](#definitions/fullnameOverride)_.
- **`releaseTrunc`**: Refer to _[#/definitions/releaseTrunc](#definitions/releaseTrunc)_.
- **`prefixTrunc`**: Refer to _[#/definitions/prefixTrunc](#definitions/prefixTrunc)_.
- **`labels`**: Refer to _[#/definitions/labels](#definitions/labels)_.
- **`annotations`**: Refer to _[#/definitions/annotations](#definitions/annotations)_.
- **`serviceName`**: Refer to _[#/definitions/serviceName](#definitions/serviceName)_.

## Definitions

- <a id="definitions/nameOverride"></a>**`nameOverride`** _(string)_: [helm-common] Override the name.
- <a id="definitions/fullnameOverride"></a>**`fullnameOverride`** _(string)_: [helm-common] Override the fullname.
- <a id="definitions/releaseTrunc"></a>**`releaseTrunc`** _(integer)_: [helm-common] The release trunk length. Default: `20`.
- <a id="definitions/prefixTrunc"></a>**`prefixTrunc`** _(integer)_: [helm-common] The prefix trunk length (release and chart name). Default: `40`.
- <a id="definitions/labels"></a>**`labels`** _(object)_: [helm-common] Labels. Can contain additional properties.
  - **Additional properties** _(string)_
- <a id="definitions/annotations"></a>**`annotations`** _(object)_: [helm-common] Annotations. Can contain additional properties.
  - **Additional properties** _(string)_
- <a id="definitions/serviceName"></a>**`serviceName`** _(string)_: [helm-common] The name of the service (not Kubernetes service), this will postfix the name.
