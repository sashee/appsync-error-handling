provider "aws" {
}

resource "random_id" "id" {
  byte_length = 8
}

resource "aws_iam_role" "appsync" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "appsync.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "/tmp/${random_id.id.hex}-lambda.zip"
  source {
    content  = <<EOF
export const handler = async (event, context) => {
	const {returnValue, returnError} = event;

	console.log(JSON.stringify(event, undefined, 4));

	if (returnError !== undefined) {
		throw returnError;
	}else {
		return returnValue;
	}
};
EOF
    filename = "index.mjs"
  }
}

resource "aws_lambda_function" "function" {
  function_name = "function-${random_id.id.hex}"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  handler = "index.handler"
  runtime = "nodejs14.x"
  role    = aws_iam_role.lambda_exec.arn
}

resource "aws_cloudwatch_log_group" "loggroup" {
  name              = "/aws/lambda/${aws_lambda_function.function.function_name}"
  retention_in_days = 14
}

data "aws_iam_policy_document" "lambda_exec_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_exec_policy" {
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.lambda_exec_policy.json
}

resource "aws_iam_role" "lambda_exec" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
	{
	  "Action": "sts:AssumeRole",
	  "Principal": {
		"Service": "lambda.amazonaws.com"
	  },
	  "Effect": "Allow"
	}
  ]
}
EOF
}

# logs
data "aws_iam_policy_document" "appsync_push_logs" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_role" "appsync_logs" {
  assume_role_policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
		{
		"Effect": "Allow",
		"Principal": {
			"Service": "appsync.amazonaws.com"
		},
		"Action": "sts:AssumeRole"
		}
	]
}
POLICY
}

resource "aws_iam_role_policy" "appsync_logs" {
  role   = aws_iam_role.appsync_logs.id
  policy = data.aws_iam_policy_document.appsync_push_logs.json
}

resource "aws_cloudwatch_log_group" "appsync_loggroup" {
  name              = "/aws/appsync/apis/${aws_appsync_graphql_api.appsync.id}"
  retention_in_days = 14
}

data "aws_iam_policy_document" "appsync" {
  statement {
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
			aws_lambda_function.function.arn,
    ]
  }
}

resource "aws_iam_role_policy" "appsync" {
  role   = aws_iam_role.appsync.id
  policy = data.aws_iam_policy_document.appsync.json
}

resource "aws_appsync_graphql_api" "appsync" {
  name                = "appsync_test"
  schema              = file("schema.graphql")
  authentication_type = "AWS_IAM"
  log_config {
    cloudwatch_logs_role_arn = aws_iam_role.appsync_logs.arn
    field_log_level          = "ALL"
  }
}

resource "aws_appsync_datasource" "lambda" {
  api_id           = aws_appsync_graphql_api.appsync.id
  name             = "lambda"
  service_role_arn = aws_iam_role.appsync.arn
  type             = "AWS_LAMBDA"
	lambda_config {
		function_arn = aws_lambda_function.function.arn
	}
}

