# HTTP Proxy

**A proxy server. WIP**

## Dependencies
To run or build the code you must first run `mix deps.get`

## Running
`mix run --no-halt` will run the code.

The server can be accessed at `http://localhost:8080`

## Building
To create a release use:

`mix release`

To create a production release use:

`MIX_ENV=prod mix release`

You'll then be able to package up the release folder or run the executable `rel/proxy/bin/proxy`
