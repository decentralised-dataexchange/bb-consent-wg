#!/bin/bash

set -e

echo "Consent BB development script"
echo ""
echo "This runs a developer-version of what happens in the Circle CI configuration."

if [ "$1" == "build-openapi-assets" ]
then

  echo "Building openapi.yaml and mock application"
  ./api/govstack_csv_to_openapi.py \
    "api/GovStack Consent BB API endpoints - endpoints.csv" \
    "api/GovStack Consent BB API endpoints - schema.csv" \
    > "api/consent-openapi.yaml"

  ./api/govstack_csv_to_openapi.py \
    "api/GovStack Consent BB API endpoints - endpoints.csv" \
    "api/GovStack Consent BB API endpoints - schema.csv" \
    --django-api > "examples/mock/djangoapp/consentbb/app/api_autogenerated.py"

  ./api/govstack_csv_to_openapi.py \
    "api/GovStack Consent BB API endpoints - endpoints.csv" \
    "api/GovStack Consent BB API endpoints - schema.csv" \
    --django-models > "examples/mock/djangoapp/consentbb/app/models.py"

  ./api/govstack_csv_to_openapi.py \
    "api/GovStack Consent BB API endpoints - endpoints.csv" \
    "api/GovStack Consent BB API endpoints - schema.csv" \
    --django-ninja-schemas > "examples/mock/djangoapp/consentbb/app/schemas.py"

  ./api/govstack_csv_to_openapi.py \
    "api/GovStack Consent BB API endpoints - endpoints.csv" \
    "api/GovStack Consent BB API endpoints - schema.csv" \
    --django-admin > "examples/mock/djangoapp/consentbb/app/admin.py"

  exit

fi

if [ "$1" == "build" ]
then
  cd ./test/gherkin/
  docker build . -t test:latest
  cd -
  cd ./examples/mock/
  docker-compose build
  cd -
  exit
fi

cd ./examples/mock/

if [ "$1" == "test" ]
then
  docker-compose up -d
else

  echo ""
  echo "Running the consent BB mocking application."
  echo ""
  echo "By default, you can reach it on:"
  echo "http://localhost:8080"
  echo "https://localhost:8888 (HTTPS)"
  echo "http://localhost:8000 (Django mock application direct access)"

  docker-compose up --build
fi
cd -

if [ "$1" == "test" ]
then
  echo "Running test suites..."
  echo ""
  cd ./test/gherkin
  ./test_entrypoint.sh
  cd -

  cd ./examples/mock/

  docker-compose stop

  cd -
fi

