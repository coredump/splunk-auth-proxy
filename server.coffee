connect    = require('connect')
googleAuth = require('connect-googleapps')
http       = require('http')
fs         = require('fs')
url        = require('url')

sslMiddleware = {
  key:  fs.readFileSync('./certs/privatekey.pem'),
  cert: fs.readFileSync('./certs/certificate.pem')
}

port = process.argv[2] || 4000

proxy = (req, res, next) ->
  req.headers['Remote-User'] = req.session.user.split('@')[0]
  proxy_req = http.request host: 'localhost', port: 8000, path: req.url, method: req.method, headers: req.headers, (proxy_res) ->
    proxy_res.on 'data', (chunk) -> res.write(chunk, 'binary')
    proxy_res.on 'end',   -> res.end()
    proxy_res.on 'close', -> res.end()

    res_headers = proxy_res.headers
    if res_headers.location?
      location = url.parse(res_headers.location)
      location.protocol = 'https:'
      location.host = req.headers.host
      location.port = port
      res_headers.location = url.format(location)

    res.writeHead(proxy_res.statusCode, res_headers)
  .on 'error', ->
    res.writeHead(503)
    res.end()

  req.on 'data', (chunk) -> proxy_req.write(chunk, 'binary')
  req.on 'end', -> proxy_req.end()


connect.createServer(
  sslMiddleware,
  connect.cookieParser(),
  connect.session(secret: 'TyAJkxqdVMWaVD2exh'),
  googleAuth('jadedpixel.com', secure: true),
  proxy
).listen(port)

console.log("Server started on https://0.0.0.0:#{port}/")
