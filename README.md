# electron-release-manager
This handles auto-updates for in-app updates and also handles downloads from 
the main site. Releases are stored in s3 and can be accessed via the release
manager's UI.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)


### Quick Start

__Environment Variables__

- APP_NAME: Name of your Electron app
- BUCKET: Name of the s3 bucket you're storing your relases in
- AWS_ACCESS_KEY_ID: Your AWS access key
- AWS_SECRETACCESS_KEY_ID: Your AWS secret key

```bash
$ git clone git@github.com:yhat/electron-release-manager.git && cd electron-release-manager
$ export APP_NAME="...name of your electron app..."
$ export BUCKET="...name of the bucket you're storing releases..."
$ export AWS_ACCESS_KEY_ID="...your aws access key..."
$ export AWS_SECRET_ACCESS_KEY="...your aws secret key..."
$ coffee app.coffee
```


### Uploading to S3

#### Directory Structure
We use a simple directory structure for managing releases and versions in Rodeo.
In the s3 bucket, we create a directory for each release (i.e. `1.0.0`, `1.0.1`, etc.).
Within each directory we put our builds for each platform with the following format:

```
Rodeo-v${VERSION}-${ARCH}.${FILE_TYPE}
```

So a release looks like this:

```
s3cmd ls s3://rodeo-releases/1.2.1/*
2015-12-29 22:50  50273604   s3://rodeo-releases/1.2.1/Rodeo-v1.2.1-darwin_64.dmg
2015-12-29 22:51  50434981   s3://rodeo-releases/1.2.1/Rodeo-v1.2.1-darwin_64.zip
2016-01-13 22:29 720712573   s3://rodeo-releases/1.2.1/Rodeo-v1.2.1-linux_32.zip
2015-12-29 23:20 709662401   s3://rodeo-releases/1.2.1/Rodeo-v1.2.1-linux_64.zip
2015-12-29 22:57 175719662   s3://rodeo-releases/1.2.1/Rodeo-v1.2.1-windows_32.exe
2015-12-29 22:52 176098549   s3://rodeo-releases/1.2.1/Rodeo-v1.2.1-windows_32.zip
2015-12-29 23:11 359885017   s3://rodeo-releases/1.2.1/Rodeo-v1.2.1-windows_64.exe
2015-12-29 23:01 361052890   s3://rodeo-releases/1.2.1/Rodeo-v1.2.1-windows_64.zip
```

#### File Types
Users downloading your product for the first time will probably want the 
idiot-proof installers (`.dmg` for Mac, `.exe` for Windows). However, for 
auto-updates with Squirrel, you'll need to provide `.zip` files for each 
platform. In the example above, you can see that we have both `.dmg/.exe` 
and `.zip` files in the release directory for each platform.


#### Uploading Your Release
You can use any tool to upload your releases to your s3 bucket. We recommend 
[`s3cmd`](http://s3tools.org/s3cmd). It's simple, easy, and has been around a 
long time. Remember to upload each file corresponding to the directory structure
[outlined above](./#uploading-to-s3).


```bash
echo "uploading OSX"
VERSION="1.2.1"
if [ -f build/darwin/x64/Rodeo-darwin-x64/Rodeo.dmg ]; then
    s3cmd -P put build/darwin/x64/Rodeo-darwin-x64/Rodeo.dmg "s3://rodeo-releases/${VERSION}/Rodeo-v${VERSION}-darwin_64.dmg"
fi
if [ -f build/darwin/x64/Rodeo-darwin-x64/Rodeo.zip ]; then
    s3cmd -P put build/darwin/x64/Rodeo-darwin-x64/Rodeo.zip "s3://rodeo-releases/${VERSION}/Rodeo-v${VERSION}-darwin_64.zip"
fi

echo "uploading Windows 32-bit"
if [ -f build/win32/all/Rodeo-win32-ia32.zip ]; then
    s3cmd -P put build/win32/all/Rodeo-win32-ia32.zip "s3://rodeo-releases/${VERSION}/Rodeo-v${VERSION}-windows_32.zip"
fi

if [ -f build/win32/all/Rodeo-win32-ia32/Rodeo\ Setup.exe ]; then
    s3cmd -P put build/win32/all/Rodeo-win32-ia32/Rodeo\ Setup.exe "s3://rodeo-releases/${VERSION}/Rodeo-v${VERSION}-windows_32.exe"
fi
...
...
```

## Other Suggestions
- https://github.com/loopline-systems/electron-builder
- https://github.com/maxogden/electron-packager
