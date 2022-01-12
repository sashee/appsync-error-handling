resource "aws_appsync_function" "pipeline_append_multiple_1" {
  api_id                   = aws_appsync_graphql_api.appsync.id
  data_source              = aws_appsync_datasource.lambda.name
  name                     = "pipeline_append_multiple_1"
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
	$util.appendError($ctx.error.message, $ctx.error.type)
#end
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_function" "pipeline_append_multiple_2" {
  api_id                   = aws_appsync_graphql_api.appsync.id
  data_source              = aws_appsync_datasource.lambda.name
  name                     = "pipeline_append_multiple_2"
  request_mapping_template = <<EOF
{
	"version": "2018-05-29",
	"operation": "Invoke",
	"payload": {
		"returnError": "error2"
	}
}
EOF

  response_mapping_template = <<EOF
#if($ctx.error)
	$util.appendError($ctx.error.message, $ctx.error.type)
#end
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_function" "pipeline_append_multiple_3" {
  api_id                   = aws_appsync_graphql_api.appsync.id
  data_source              = aws_appsync_datasource.lambda.name
  name                     = "pipeline_append_multiple_3"
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
#if($ctx.error)
	$util.appendError($ctx.error.message, $ctx.error.type)
#end
$util.toJson($ctx.result)
EOF
}

resource "aws_appsync_resolver" "pipeline_append_multiple" {
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "pipeline_append_multiple"
request_template  = "{}"

response_template = <<EOF
$util.toJson($ctx.result)
EOF
  kind              = "PIPELINE"
  pipeline_config {
    functions = [
      aws_appsync_function.pipeline_append_multiple_1.function_id,
      aws_appsync_function.pipeline_append_multiple_2.function_id,
      aws_appsync_function.pipeline_append_multiple_3.function_id,
    ]
  }
}

