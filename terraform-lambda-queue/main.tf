data "aws_iam_policy_document" "queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:*:*:my-event-notification-queue"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.example_bucket.arn]
    }
  }
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "my-bucket-name-terraform-example"
}

resource "aws_sqs_queue" "queue" {
  name   = "my-event-notification-queue"
  policy = data.aws_iam_policy_document.queue.json
}


resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.example_bucket.id

  queue {
    queue_arn     = aws_sqs_queue.queue.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "input-data/"
    filter_suffix = ".csv"
  }
}