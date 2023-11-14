echo "$NEWRELIC_API_KEY"
curl -X POST https://api.newrelic.com/graphql -H 'Content-type: application/json' -H 'API-Key: ${NEWRELIC_API_KEY}' -d '{ "query":  "{ requestContext { userId apiKey } }" }'
