resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-bucket-name-terraform-example"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.example_bucket.id

  lambda_function {
    lambda_function_arn = data.aws_lambda_function.function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input-data/"
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_lambda_permission" "allow_bucket" {

  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "my-function-name"
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::my-bucket-name-terraform-example"
}

data "aws_lambda_function" "function" {
  function_name = "my-function-name"
}