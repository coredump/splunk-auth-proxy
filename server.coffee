connect    = require('connect')
googleAuth = require('connect-googleapps')
http       = require('http')
https      = require('https')
fs         = require('fs')
url        = require('url')

proxy = (req, res, next) ->
  req.headers['Remote-User'] = req.session.user.split('@')[0]
  proxy_req = http.request host: exports.config.splunk.hostname, port: exports.config.splunk.port, path: req.url, method: req.method, headers: req.headers, (proxy_res) ->
    proxy_res.on 'data', (chunk) -> res.write(chunk, 'binary')
    proxy_res.on 'end', -> res.end()
    proxy_res.on 'close', -> res.end()

    res_headers = proxy_res.headers
    if res_headers.location?
      location = url.parse(res_headers.location)
      location.protocol = 'https:'
      location.host = req.headers.host
      location.port = exports.config.web.port
      res_headers.location = url.format(location)

    res.writeHead(proxy_res.statusCode, res_headers)
  .on 'error', ->
    res.writeHead(503)
    res.end()

  req.on 'data', (chunk) -> proxy_req.write(chunk, 'binary')
  req.on 'end', -> proxy_req.end()

apiAuth = (apiConfig, googleAuthInstance) ->
  connectAuth = connect.basicAuth(apiConfig.username, apiConfig.password)
  return (req, res, next) ->
    if apiConfig.enabled && req.headers.authorization?
      connectAuth req, res, ->
        if req.user
          req.authorized = true
          req.session.authenticated = true
          req.session.user = apiConfig.splunkEmail
        next()
    else
      googleAuthInstance(req, res, next)

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

  try
    exports.config = JSON.parse configFile
  catch e
    console.log("Couldn't parse config file. Please verify the format.")
    throw e
    return

  console.log("Parsed config file")

  sslMiddleware = {
    key:  fs.readFileSync(exports.config.ssl.key),
    cert: fs.readFileSync(exports.config.ssl.cert)
  }

  auth = apiAuth(exports.config.api, googleAuth(exports.config.google.domain, secure: true))

  app = connect()
    .use(connect.cookieParser())
    .use(connect.session(secret: exports.config.google.secret))
    .use(auth)
    .use(proxy)

  https.createServer(
    sslMiddleware,
    app
  ).listen(exports.config.web.port)
  console.log("Server started on https://0.0.0.0:#{exports.config.web.port}/")

main()
