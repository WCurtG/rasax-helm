#!/bin/bash
set -euxo pipefail

helm --namespace my-namespace upgrade --values values.yml my-release rasa-x/rasa-x