resource "aws_iam_role" "go_lambda_role" {
  name = "go_lambda_role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "sts:AssumeRole"
        ],
        "Principal" : {
          "Service" : [
            "lambda.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "../src/test_lambda.zip"
  function_name = "test_lambda"
  role          = aws_iam_role.go_lambda_role.arn
  handler       = "main.handler"
  runtime       = "provided.al2"
  memory_size   = 1024
  timeout       = 300
}
