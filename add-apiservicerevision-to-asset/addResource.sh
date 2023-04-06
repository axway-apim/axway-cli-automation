#!/bin/sh
# $1 - Service Account client-id
# $2 - Service Account client-secret
# $3 - APIServiceRevision name
# $4 - Target Marketplace ID

# usage: ./addResource.sh client-id client-secret api-service-revision-name asset-logical-name

# Authenitcate as Service Account
axway auth login --client-id $1 --client-secret $2

# Get APIServiceRevisionName from event payload & generate details
axway central get apiservicerevision -q "name==$3" -o json > api-service-revision-created.json

# Generate details for environment where API Service was discovered
axway central get env $(jq -r '.[0].metadata.scope.name' api-service-revision-created.json) -o json > env.json

# Generate details for APIService
axway central get apiservice -q "name==$(jq -r '.[0].metadata.references[0].name' api-service-revision-created.json)" -o json > api-service-created.json

# Get details for "default" stage. Stage name can be replaced with appropriate value
axway central get stage -q "name==default" -o json > stage-details.json

# Add resource to the asset
echo "{\"name\" : \"$4\"}" > asset-name.json
jq --slurp -f asset-resource.jq env.json asset-name.json stage-details.json api-service-created.json api-service-revision-created.json > asset-resource.json
axway central apply -f asset-resource.json -o json -y > asset-resource-created.json