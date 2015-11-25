AWS = require('aws-sdk')
semver = require("semver")
# looks for AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY
BASE_URL = "http://rodeo-releases.s3.amazonaws.com"

generateVersion = (version) ->
  {
    version: version,
    urls: {
      "linux_32"    : "#{BASE_URL}/#{version}/Rodeo-v#{version}-linux_32.zip"
      "linux_64"    : "#{BASE_URL}/#{version}/Rodeo-v#{version}-linux_64.zip"
      "darwin_x64"  : "#{BASE_URL}/#{version}/Rodeo-v#{version}-darwin_64.zip"
      "windows_x64" : "#{BASE_URL}/#{version}/Rodeo-v#{version}-windows_64.zip"
      "windows_ia32": "#{BASE_URL}/#{version}/Rodeo-v#{version}-windows_32.zip"
    }
  }



module.exports = (fn) ->

  s3 = new AWS.S3()

  bucketParams = {
    Bucket: "rodeo-releases"
    MaxKeys: 10000
  }

  BASE_URL = "http://rodeo-releases.s3.amazonaws.com"
  s3.listObjects bucketParams, (err, data) ->
    if err
      console.log err
      return fn err, null

    versions = []
    data.Contents.map (obj) ->
      v = obj.Key.split('/')[0]
      if v not in versions
        if semver.valid(v)
          versions.push v

    versions = versions.sort(semver.rcompare)
    versions = versions.map generateVersion
    fn err, versions
