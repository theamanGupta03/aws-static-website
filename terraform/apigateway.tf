# ─────────────────────────────────────────────
# API GATEWAY  –  HTTP API (v2, cheaper + faster
# than REST API for simple use cases)
# ─────────────────────────────────────────────

resource "aws_apigatewayv2_api" "website" {
  name          = "${var.project_name}-api"
  protocol_type = "HTTP"
  description   = "API for ${var.project_name} static website"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "OPTIONS"]
    allow_headers = ["Content-Type", "Authorization"]
    max_age       = 300
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# Auto-deploy stage (deploys every change immediately)
resource "aws_apigatewayv2_stage" "website" {
  api_id      = aws_apigatewayv2_api.website.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
    })
  }
}

# CloudWatch log group for API Gateway access logs
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/apigateway/${var.project_name}"
  retention_in_days = 7
}

# ─────────────────────────────────────────────
# LAMBDA FUNCTION  –  handles /api/hello
# ─────────────────────────────────────────────

# IAM role for Lambda
resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Zip the Lambda source code automatically
data "archive_file" "lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"

  source {
    content  = <<-EOF
      exports.handler = async (event) => {
        return {
          statusCode: 200,
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            message: "Hello from Lambda!",
            path: event.rawPath,
            timestamp: new Date().toISOString()
          })
        };
      };
    EOF
    filename = "index.js"
  }
}

resource "aws_lambda_function" "hello" {
  function_name    = "${var.project_name}-hello"
  role             = aws_iam_role.lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.lambda.output_path
  source_code_hash = data.archive_file.lambda.output_base64sha256

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.website.execution_arn}/*/*"
}

# ─────────────────────────────────────────────
# API GATEWAY INTEGRATION + ROUTES
# ─────────────────────────────────────────────

resource "aws_apigatewayv2_integration" "lambda_hello" {
  api_id             = aws_apigatewayv2_api.website.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.hello.invoke_arn
  integration_method = "POST"
}

# GET /api/hello
resource "aws_apigatewayv2_route" "hello" {
  api_id    = aws_apigatewayv2_api.website.id
  route_key = "GET /api/hello"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_hello.id}"
}

# POST /api/contact  (demo — same Lambda, add your own logic)
resource "aws_apigatewayv2_route" "contact" {
  api_id    = aws_apigatewayv2_api.website.id
  route_key = "POST /api/contact"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_hello.id}"
}