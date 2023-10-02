resource "aws_s3_object" "clearml_config" {
  bucket = var.clearml_config_bucket_name # Replace with the name of your existing bucket
  key    = "clearml.conf"
  source = "../clearml.conf"
  etag = filemd5("../clearml.conf")
}
