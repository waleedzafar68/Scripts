echo "$NEWRELIC_API_KEY"
curl -X POST https://api.newrelic.com/graphql \
     -H 'Content-Type: application/json' \
     -H "API-Key: ${NEWRELIC_API_KEY}" \
     -d '{ "query": "mutation { changeTrackingCreateDeployment(deployment: { version: \"'"${RELEASE_TAG}"'\" user: \"'"${USER}"'\" timestamp: '"$(($(date +%s) * 1000))"' entityGuid: \"'"${NEWRELIC_ENTITY_GUID}"'\" description: \"'"${REPO}"'-'"${REPO_OWNER}"' commit '"${SHA}"' has been deployed successfully to Dev\" deploymentType: BASIC deepLink: \"'"${URL}"'\" commit: \"'"${SHA}"'\" changelog: \"'"${MESSAGE}"'\" }) { changelog commit deepLink deploymentId deploymentType description entityGuid timestamp user version }}" }'
