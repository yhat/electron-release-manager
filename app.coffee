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
rodeoVersions = require("./rodeo-versions")


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


platformMap = {
  "darwin_x64": "darwin_x64"
  "darwin": "darwin_x64"
  "osx": "darwin_x64"
  "windows_64": "windows_x64"
  "windows_32": "windows_ia32"
  "linux_64": "linux-64"
  "linux_32": "linux-32"
}

formatVersion = (v, platform) ->
  platform = platform || "darwin_x64"
  platform = platform.replace("win32", "windows")
  platform = platformMap[platform]

  data = {
    version: v.version,
    url: v.urls[platform],
    pub_date: v.pub_date
  }
  data

app.get "/", (req, res) ->
  if req.query.version
    rodeoVersions (err, versions) ->
      if err
        res.status(500)
        res.send "Could not lookup latest version"
        return

      latest = versions[0]
      if ! semver.valid(req.query.version)
        res.status(400)
        cleanVersion = semver.clean(req.query.version)
        suggestion = ""
        if cleanVersion
          suggestion = "Did you mean '#{cleanVersion}'?"
        res.send "Invalid version: #{req.query.version}." + suggestion
      else if semver.lt(req.query.version, latest.version)
        data = formatVersion latest, req.query.platform
        res.json data
      else
        res.status(204)
        res.end()
  else
    res.status(204)
    res.end()

app.get "/latest", (req, res) ->
  rodeoVersions (err, versions) ->
    if err
      res.status(500)
      res.send("Could not grab latest version")
      return

    latest = versions[0]
    data = formatVersion latest, req.query.platform
    res.redirect data.url

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
