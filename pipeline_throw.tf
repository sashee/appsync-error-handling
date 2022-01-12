resource "aws_appsync_function" "pipeline_throw_1" {
  api_id                   = aws_appsync_graphql_api.appsync.id
  data_source              = aws_appsync_datasource.lambda.name
  name                     = "pipeline_throw_1"
  request_mapping_template = <<EOF
{
	"version": "2018-05-29",
	"operation": "Invoke",
	"payload": {
		"returnError": "error1"
	}
}
EOF

  response_mapping_template = <<EOF
#if($ctx.error)
	$util.error($ctx.error.message, $ctx.error.type)
#end
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_function" "pipeline_throw_2" {
  api_id                   = aws_appsync_graphql_api.appsync.id
  data_source              = aws_appsync_datasource.lambda.name
  name                     = "pipeline_throw_2"
  request_mapping_template = <<EOF
{
	"version": "2018-05-29",
	"operation": "Invoke",
	"payload": {
		"returnValue": "val1"
	}
}
EOF

  response_mapping_template = <<EOF
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_resolver" "pipeline_throw" {
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "pipeline_throw"
request_template  = "{}"

response_template = <<EOF
$util.toJson($ctx.result)
EOF
  kind              = "PIPELINE"
  pipeline_config {
    functions = [
      aws_appsync_function.pipeline_throw_1.function_id,
      aws_appsync_function.pipeline_throw_2.function_id,
    ]
  }
}

