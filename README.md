# Websockets stuff

This is a websockets project written in Terraform and Python.
Your websocket client can connect, subscribe to a topic and receive messages sent to that topic.

## Installation

1. Clone the repository
2. Run `terraform init`
3. Run `terraform apply`

## Usage

To connect use the command `wscat -c wss://<YOUR_API_GW_INVOKE_URL>`

e.g. `wscat -c wss://abc123.execute-api.eu-west-1.amazonaws.com/dev`

Once connected, press enter and the default response will give instructions on usage.

TODO
- [x] Authorization: query string
- [x] Authorization: x-api-key header
- [ ] Storage: change dynamoDB to cache e.g. elastic cache
