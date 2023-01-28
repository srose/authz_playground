#!/usr/bin/env bash

BUNDLE_FOLDER=$1

lint_rego() {
    docker run --rm -v $PWD/bundles:/tmp/bundles:z openpolicyagent/opa:0.46.1-static check --strict /tmp/bundles/$BUNDLE_FOLDER
}
test_rego() {
    docker run --rm -v $PWD/bundles:/tmp/bundles:z openpolicyagent/opa:0.46.1-static test /tmp/bundles/$BUNDLE_FOLDER -v
}
update_opa_policy() {
    curl -s -o /dev/null -X PUT --data-binary @bundles/$BUNDLE_FOLDER/policy.rego  localhost:8181/v1/policies/account
}
update_opa_data() {
    curl -s -o /dev/null -X PUT --data-binary @bundles/$BUNDLE_FOLDER/data.json  localhost:8181/v1/data/account
}
publish_rego() {
  lint_rego && test_rego && update_opa_policy && update_opa_data && echo "$(date +"%m-%d-%Y %T") OPA updated."
}

echo "Watching for changes in OPA policy files"
inotifywait --monitor --event close_write --recursive $PWD/bundles | while read
do
  publish_rego
done
