resource "aws_dynamodb_table" "api_gw_connection_ids" {
  name         = "ConnectionIds"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "ConnectionId"

  attribute {
    name = "ConnectionId"
    type = "S"
  }

  tags = {
    Name = "api_gw_websocket_connection_ids"
  }
}