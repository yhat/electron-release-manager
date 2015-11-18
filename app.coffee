fs = require("fs")
http = require("http")
path = require("path")
# express and middleware
express = require("express")
favicon = require("serve-favicon")
logger = require("morgan")
bodyParser = require("body-parser")
compression = require("compression")
less = require("less-middleware")
colors = require("colors")
_ = require("underscore")
semver = require("semver")


app = express()

# setup templating
app.set 'views', path.join(__dirname, '/views')
app.set 'view engine', 'html'    # use .html extension for templates
app.set 'layout', 'layout'       # use layout.html as the default layout
# define partials available to all pages
app.set 'partials',
  header: 'partials/header'
  footer: 'partials/footer'
  footer_scripts: 'partials/footer-scripts'

# app.enable 'view cache'
app.engine 'html', require('hogan-express')

# setup middleware
app.use(favicon(__dirname + '/public/favicon.ico'))

app.use logger("dev")

app.use compression()
app.use bodyParser.json({ limit: '50mb' })
app.use bodyParser.urlencoded({ extended: true })

app.use less(path.join(__dirname, "public"), {}, {}, { sourceMap: true, compress: true })
app.use express.static(path.join(__dirname, "/public"))


BASE_URL = "http://rodeo-releases.s3.amazonaws.com"
rodeoVersions = [
  {
    version: "1.1.3",
    pub_date: "2015-11-17T12:29:53+01:00",
    urls: {
      "linux-32"    : "linux-32.zip"
      "linux-64"    : "linux-64.zip"
      "darwin_x64"  : "#{BASE_URL}/1.1.3/Rodeo-v1.1.3-darwin_64.zip"
      "windows_x64" : "#{BASE_URL}/1.1.3/Rodeo-v1.1.3-windows_64.zip"
      "windows_ia32": "#{BASE_URL}/1.1.3/Rodeo-v1.1.3-windows_32.zip"
    }
  },
  {
    version: "1.1.2",
    pub_date: "2015-11-17T12:29:53+01:00",
    urls: {
      "linux-32"    : "linux-32.zip"
      "linux-64"    : "linux-64.zip"
      "darwin_x64"  : "#{BASE_URL}/1.1.2/Rodeo-v1.1.2-darwin_64.zip"
      "windows_x64" : "#{BASE_URL}/1.1.2/Rodeo-v1.1.2-windows_64.zip"
      "windows_ia32": "#{BASE_URL}/1.1.2/Rodeo-v1.1.2-windows_32.zip"
    }
  },
  {
    version: "1.1.1",
    pub_date: "2015-11-17T12:29:53+01:00",
    urls: {
      "linux-32"    : "linux-32.zip"
      "linux-64"    : "linux-64.zip"
      "darwin_x64"  : "#{BASE_URL}/1.1.1/Rodeo-v1.1.1-darwin_64.zip"
      "windows_x64" : "#{BASE_URL}/1.1.1/Rodeo-v1.1.1-windows_64.zip"
      "windows_ia32": "#{BASE_URL}/1.1.1/Rodeo-v1.1.1-windows_32.zip"
    }
  },
  {
    version: "1.1.0",
    pub_date: "2015-11-16T12:29:53+01:00",
    urls: {
      "linux-32"    : "linux-32.zip"
      "linux-64"    : "linux-64.zip"
      "darwin_x64"  : "#{BASE_URL}/1.1.0/Rodeo-v1.1.0-darwin_64.zip"
      "windows_x64" : "#{BASE_URL}/1.1.0/Rodeo-v1.1.0-windows_64.zip"
      "windows_ia32": "#{BASE_URL}/1.1.0/Rodeo-v1.1.0-windows_32.zip"
    }
  }
]

formatVersion = (v, platform) ->
  platform = platform.replace("win32", "windows")
  data = {
    version: v.version,
    url: v.urls[platform || "darwin_x64"],
    pub_date: v.pub_date
  }
  data

app.get "/", (req, res) ->
  if req.query.version
    if semver.lt(req.query.version, rodeoVersions[0].version)
      v = rodeoVersions[0]
      data = formatVersion v, req.query.platform
      res.json data
      return

  res.status(204)
  res.end()

app.get "/latest", (req, res) ->
  v = rodeoVersions[0]
  res.json formatVersion v, req.query.platform

# catch 404 and forward to error handler
app.use (req, res, next) ->
  err = new Error("Not Found")
  err.status = 404
  res.render "404", { title: "404 | Whoops" }

# development error handler
if app.get("env") is "development"
  app.use (err, req, res, next) ->
    console.log "[CRITICAL ERROR]: #{err}"
    res.status err.status || 500
    res.render "error", { message: err.message, error: err }

# production error handler
app.use (err, req, res, next) ->
  console.log "[CRITICAL ERROR]: #{err}"
  res.status err.status || 500
  res.render "error", { message: err.message, error: {} }

# start the server
port = port || parseInt(process.env.PORT, 10) or 3000
app.set "port", port
server = http.createServer(app)
# start listening and print out what port we're on for sanity's sake
server.listen port
console.error "Listening on port #{port}"
