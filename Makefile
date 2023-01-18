HELM ?= helm

gen-expected:
	${HELM} dependency update tests/chart
	${HELM} template --namespace=default relase-long-name-release-long-name-release tests/chart > tests/expected.yaml || \
		${HELM} template --debug --namespace=default relase-long-name-release-long-name-release tests/chart
	sed -i 's/[[:blank:]]\+$$//g' tests/expected.yaml
	${HELM} template --namespace=default relase-long-name-release-long-name-release tests/chart --values=tests/service_account.yaml > tests/expected_service_account.yaml || \
		${HELM} template --debug --namespace=default relase-long-name-release-long-name-release tests/chart  --values=tests/service_account.yaml
	sed -i 's/[[:blank:]]\+$$//g' tests/expected_service_account.yaml
