resource "aws_dynamodb_table" "my_app_table" {
  count = local.current.ddb

  name         = "${terraform.workspace}-table-${count.index}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "${terraform.workspace}-table-${count.index}"
    Environment = terraform.workspace
  }
}