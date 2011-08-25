connect    = require('connect')
googleAuth = require('connect-googleapps')
http       = require('http')
fs         = require('fs')
url        = require('url')


proxy = (req, res, next) ->
  req.headers['Remote-User'] = req.session.user.split('@')[0]
  proxy_req = http.request host: exports.splunkHost, port: exports.splunkPort, path: req.url, method: req.method, headers: req.headers, (proxy_res) ->
    proxy_res.on 'data', (chunk) -> res.write(chunk, 'binary')
    proxy_res.on 'end', -> res.end()
    proxy_res.on 'close', -> res.end()

    res_headers = proxy_res.headers
    if res_headers.location?
      location = url.parse(res_headers.location)
      location.protocol = 'https:'
      location.host = req.headers.host
      location.port = exports.port
      res_headers.location = url.format(location)

    res.writeHead(proxy_res.statusCode, res_headers)
  .on 'error', ->
    res.writeHead(503)
    res.end()

  req.on 'data', (chunk) -> proxy_req.write(chunk, 'binary')
  req.on 'end', -> proxy_req.end()

main = ->
        console.log("starting splunk-auth-proxy")
        if process.argv.length != 3
                console.log("Usage: splunk-auth-proxy <config.json>")
                return

        try
                configFile = fs.readFileSync(process.argv[2], 'utf-8')
        catch e
                console.log("Unable to read config file")
                throw e
                return

        console.log("Read config file")

        try
                config = JSON.parse configFile
        catch e
                console.log("Couldn't parse config file. Please verify the format.")
                throw e
                return


        console.log("Parsed config file")

        #configure glabal variables (needed by proxy function)
        exports.port = config.web.port
        exports.splunkPort = config.splunk.port
        exports.splunkHost = config.splunk.hostname

        sslMiddleware = {
                key:  fs.readFileSync(config.ssl.key),
                cert: fs.readFileSync(config.ssl.cert)
        }

        connect.createServer(
          sslMiddleware,
          connect.cookieParser(),
          connect.session(secret: config.google.secret),
          googleAuth(config.google.domain, secure: true),
          proxy
        ).listen(exports.port)
        console.log("Server started on https://0.0.0.0:#{exports.port}/")


main()

