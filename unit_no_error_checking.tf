resource "aws_appsync_resolver" "unit_no_error_checking" {
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "unit_no_error_checking"
  data_source = aws_appsync_datasource.lambda.name
	request_template = <<EOF
{
	"version": "2018-05-29",
	"operation": "Invoke",
	"payload": {
		"returnError": "error1"
	}
}
EOF
  response_template = <<EOF
$util.toJson($ctx.result)
EOF
}

