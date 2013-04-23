path = require 'path'

splash = (req, res, next) ->
  isStatic = req.url.split('/')[1] is 'static'
  unless req.query?.play? or req.getModel().get('_userId') or isStatic
    res.redirect('/static/front')
  else
    next()

view = (req, res, next) ->
  model = req.getModel()
  ## Set _mobileDevice to true or false so view can exclude portions from mobile device
  model.set '_mobileDevice', /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(req.header 'User-Agent')
  model.set '_nodeEnv', model.flags.nodeEnv
  next()

#CORS middleware
allowCrossDomain = (req, res, next) ->
  res.header "Access-Control-Allow-Origin", (req.headers.origin || "*")
  res.header "Access-Control-Allow-Methods", "OPTIONS,GET,POST,PUT,HEAD,DELETE"
  res.header "Access-Control-Allow-Headers", "Content-Type,X-Requested-With,x-api-user,x-api-key"

  # wtf is this for?
  if req.method is 'OPTIONS'
    res.send(200);
  else
    next()

ONE_YEAR = 1000 * 60 * 60 * 24 * 365
root = path.dirname path.dirname __dirname
publicPath = path.join root, 'public'

gzip = (req, res, next) ->
  console.log req.get 'Content-Encoding'
  return next() if req.accepts 'application/json'
  console.log 'gzipping'
  gzippo.staticGzip(publicPath, maxAge: ONE_YEAR)(req, res, next)

module.exports = { splash, view, allowCrossDomain, gzip }