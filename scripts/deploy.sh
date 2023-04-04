#!/bin/bash
# $1 - Service Account client-id
# $2 - Service Account client-secret
# $3 - APIServiceRevision name
# $4 - Target Marketplace ID

# Authenitcate as Service Account
axway auth login --client-id $1 --client-secret $2

# Get APIServiceRevisionName from event payload & generate details
axway central get apiservicerevision -q "name==$3" -o json > api-service-revision-created.json

# Generate details for environment where API Service was discovered
axway central get env $(jq -r '.[0].metadata.scope.name' api-service-revision-created.json) -o json > env.json

# Generated details for APIService
axway central get apiservice -q "name==$(jq -r '.[0].metadata.references[0].name' api-service-revision-created.json)" -o json > api-service-created.json


# Create an asset based on the API Name
jq --slurp -f asset-template.jq api-service-revision-created.json api-service-created.json > asset.json
axway central create -f asset.json -o json -y > asset-created.json

# Get details for "defaul" stage. Stage name can be replaced with appropriate value
axway central get stage -q "name==default" -o json > stage-details.json

# Add resource to the asset
jq --slurp -f asset-resource.jq env.json asset-created.json stage-details.json api-service-created.json api-service-revision-created.json > asset-resource.json
axway central create -f asset-resource.json -o json -y > asset-resource-created.json

# Activate asset
axway central get asset $(jq -r '.[0].name' asset-created.json) -o json | jq '.state = "active"' > asset-changed.json
axway central apply -f asset-changed.json -o json > asset-changed-apply.json

# Create release tag
jq --slurp -f asset-release-tag.jq asset-created.json > asset-release-tag.json
axway central create -f asset-release-tag.json -o json -y > asset-release-tag-created.json

# Create a product
jq --slurp -f product.jq api-service-created.json asset-created.json > product.json
axway central create -f product.json -y -o json > product-created.json

# Add default overview artice to product scope
export docTitle='Overview'
export docContent='# Overview<br>Lorem ipsum dolor sit amet, consectetur adipiscing elit'
jq -f article.jq product-created.json > article.json
axway central create -f article.json -y -o json > article-created.json

# Assemble articles into a document based on product scope
# Find all articles available in product scope
axway central get resources -s $(jq -r '.[0].name' product-created.json) -o json > available-articles.json

# Create a document based on all available articles
jq --slurp -f document.jq product-created.json available-articles.json > document.json
axway central create -f document.json -o json -y > document-created.json

# Mark product as ready to be published in Marketplace
axway central get product $(jq -r '.[0].name' product-created.json) -o json  | jq '.state = "active"' > product-updated.json
axway central apply -f product-updated.json -o json > product-updated-apply.json

# Create a release tag
jq -f product-release-tag.jq product-created.json > product-release-tag.json
axway central create -f product-release-tag.json -o json -y > product-release-tag-created.json

# Create a plan
jq -f product-plan.jq product-created.json > product-plan.json
axway central create -f product-plan.json -o json -y > product-plan-created.json

# Create product plan quota
jq --slurp -f product-plan-quota.jq product-plan-created.json asset-created.json api-service-created.json > product-plan-quota.json
axway central create -f product-plan-quota.json -o json -y > product-plan-quota-created.json

# Activate the product plan
axway central get productplans $(jq -r '.[0].name' product-plan-created.json) -o json | jq '.state = "active"' > product-plan-updated.json
axway central apply -f product-plan-updated.json -o json > product-plan-updated-apply.json

# Publish to Marketplace
echo "{\"name\" : \"$4\"}" > marketplace.json
jq --slurp -f publish-product.jq marketplace.json product-created.json  > publish-product.json
axway central create -f publish-product.json -o json -y > publish-product-created.json