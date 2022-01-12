resource "aws_appsync_function" "pipeline_cleanup_handling_1" {
  api_id                   = aws_appsync_graphql_api.appsync.id
  data_source              = aws_appsync_datasource.lambda.name
  name                     = "pipeline_cleanup_handling_1"
  request_mapping_template = <<EOF
{
	"version": "2018-05-29",
	"operation": "Invoke",
	"payload": {
		"returnValue": "resource1"
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

resource "aws_appsync_function" "pipeline_cleanup_handling_2" {
  api_id                   = aws_appsync_graphql_api.appsync.id
  data_source              = aws_appsync_datasource.lambda.name
  name                     = "pipeline_cleanup_handling_2"
  request_mapping_template = <<EOF
{
	"version": "2018-05-29",
	"operation": "Invoke",
	"payload": {
		#if($ctx.args.failing)
			"returnError": "error2"
		#else
			"returnValue": "op2"
		#end
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

resource "aws_appsync_function" "pipeline_cleanup_handling_3" {
  api_id                   = aws_appsync_graphql_api.appsync.id
  data_source              = aws_appsync_datasource.lambda.name
  name                     = "pipeline_cleanup_handling_3"
  request_mapping_template = <<EOF
#if($ctx.outErrors.size() > 0)
{
	"version": "2018-05-29",
	"operation": "Invoke",
	"payload": {
		"returnValue": "cleanup resource1"
	}
}
#else
	#return($ctx.prev.result)
#end
EOF

  response_mapping_template = <<EOF
$util.error($ctx.outErrors[0].message, $ctx.outErrors[0].type)
EOF
}

resource "aws_appsync_function" "pipeline_cleanup_handling_4" {
  api_id                   = aws_appsync_graphql_api.appsync.id
  data_source              = aws_appsync_datasource.lambda.name
  name                     = "pipeline_cleanup_handling_4"
  request_mapping_template = <<EOF
{
	"version": "2018-05-29",
	"operation": "Invoke",
	"payload": {
		"returnValue": "op3"
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

resource "aws_appsync_resolver" "pipeline_cleanup_handling" {
  api_id      = aws_appsync_graphql_api.appsync.id
  type        = "Query"
  field       = "pipeline_cleanup_handling"
request_template  = "{}"

response_template = <<EOF
$util.toJson($ctx.result)
EOF
  kind              = "PIPELINE"
  pipeline_config {
    functions = [
      aws_appsync_function.pipeline_cleanup_handling_1.function_id,
      aws_appsync_function.pipeline_cleanup_handling_2.function_id,
      aws_appsync_function.pipeline_cleanup_handling_3.function_id,
      aws_appsync_function.pipeline_cleanup_handling_4.function_id,
    ]
  }
}

