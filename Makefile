HELM ?= helm

gen-expected:
	${HELM} dependency update tests/chart
	${HELM} template --namespace=default test tests/chart > tests/expected.yaml || \
		${HELM} template --debug --namespace=default test tests/chart
	sed -i 's/[[:blank:]]\+$$//g' tests/expected.yaml
