# electron-release-manager
This handles auto-updates for in-app updates and also handles downloads from 
the main site.

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)


### Quick Start

__Environment Variables__

- APP_NAME: ...
- BUCKET: ...
- AWS_ACCESS_KEY_ID: ...
- AWS_SECRETACCESS_KEY_ID: ...

```bash
$ git clone git@github.com:yhat/electron-release-manager.git && cd electron-release-manager
$ export APP_NAME="...name of your electron app..."
$ export BUCKET="...name of the bucket you're storing releases..."
$ export AWS_ACCESS_KEY_ID="...your aws access key..."
$ export AWS_SECRET_ACCESS_KEY="...your aws secret key..."
$ coffee app.coffee
```
