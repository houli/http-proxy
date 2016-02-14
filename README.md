# HTTP Proxy

**A proxy server. WIP**

## Dependencies
To run or build the code you must first run
```bash
$ mix deps.get
```

## Running
```bash
$ mix run --no-halt
```
will start the proxy server.

The server can be accessed at `localhost:8080`

## Building
To create a release use:

```bash
$ mix release
```

To create a production release use:

```bash
$ MIX_ENV=prod mix release
```

You'll then be able to package up the release folder or run the executable `rel/proxy/bin/proxy`

## Blocking Hosts
You can dynamically block particular hosts using the console.
First create a release as described above.
Then start up the proxy. If you want it to run in the background use
```bash
$ rel/proxy/bin/proxy start
```
If you want to see the logs use the following instead:
```bash
$ rel/proxy/bin/proxy foreground
```
You can then start up a management console with
```bash
$ rel/proxy/bin/proxy remote_console
```
In the console you can call functions such as

`Proxy.BlockList.block "google.com"`

`Proxy.BlockList.unblock "google.com"`

`Proxy.BlockList.unblock_all`

To save typing fully qualified function names enter `import Proxy.BlockList`.

Now you can use `block` `unblock` `unblock_all` etc. without typing the module name.

All future requests to hosts specified will be blocked
