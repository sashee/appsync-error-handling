resource "aws_appsync_resolver" "unit_req_error" {
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "unit_req_error"
  data_source = aws_appsync_datasource.lambda.name
	request_template = <<EOF
$util.error("Error from request template")
EOF
  response_template = <<EOF
$util.toJson($ctx.result)
EOF
}

