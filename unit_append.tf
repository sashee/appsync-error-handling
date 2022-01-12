resource "aws_appsync_resolver" "unit_append" {
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "unit_append"
  data_source = aws_appsync_datasource.lambda.name
	request_template = <<EOF
$util.appendError("error appended in the request template")
{
	"version": "2018-05-29",
	"operation": "Invoke",
	"payload": {
		"returnValue": "val1"
	}
}
EOF
  response_template = <<EOF
$util.appendError("error appended in the response")
$util.toJson($ctx.result)
EOF
}

