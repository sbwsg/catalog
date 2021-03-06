#!/bin/bash

# Copyright 2019 The Tekton Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

source $(dirname $0)/../vendor/github.com/tektoncd/plumbing/scripts/e2e-tests.sh

# Setup a test cluster.
[[ -z ${LOCAL_CI_RUN} ]] && initialize $@

# Install the latest Tekton CRDs.
kubectl apply --filename https://storage.googleapis.com/tekton-releases/latest/release.yaml

# Allow ignoring some tests, space separated, should be the basename of the test
# i.e: kn-deployer
IGNORES=${IGNORES:-}

set -ex
set -o pipefail
# Validate that all the Task CRDs in this repo are valid by creating them in a NS.
readonly ns="task-ns"
kubectl create ns "${ns}" || true
for f in $(find ${REPO_ROOT_DIR} -maxdepth 2 -name '*.yaml'); do
    skipit=
    for ignore in ${IGNORES};do
        [[ ${ignore} == $(basename $(echo ${f%.yaml})) ]] && skipit=True
    done
    [[ -n ${skipit} ]] && break
    echo "Checking ${f}"
    kubectl -n ${ns} apply -f <(sed "s/namespace:.*/namespace: task-ns/" "${f}")
done

success
