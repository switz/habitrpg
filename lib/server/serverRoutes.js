// Generated by CoffeeScript 1.3.3
var scoring;

scoring = require('../app/scoring');

module.exports = function(expressApp) {
  expressApp.get('/:uid/up/:score?', function(req, res) {
    var model, score;
    score = parseInt(req.params.score) || 1;
    console.log({
      score: score
    });
    model = req.getModel();
    model.fetch("users." + req.params.uid, function(err, user) {
      if (err || !user.get()) {
        return;
      }
      return scoring.score({
        user: user,
        direction: 'up'
      });
    });
    return res.send(200);
  });
  expressApp.get('/:uid/down/:score?', function(req, res) {
    var model, score;
    score = parseInt(req.params.score) || 1;
    console.log({
      score: score
    });
    model = req.getModel();
    model.fetch("users." + req.params.uid, function(err, user) {
      if (err || !user.get()) {
        return;
      }
      return scoring.score({
        user: user,
        direction: 'down'
      });
    });
    return res.send(200);
  });
  expressApp.get('/privacy', function(req, res) {
    var staticPages;
    staticPages = derby.createStatic(root);
    return staticPages.render('privacy', res);
  });
  expressApp.get('/terms', function(req, res) {
    var staticPages;
    staticPages = derby.createStatic(root);
    return staticPages.render('terms', res);
  });
  expressApp.all('*', function(req) {
    throw "404: " + req.url;
  });
  return expressApp.post('/', function(req) {
    return require('../app/reroll').stripeResponse(req);
  });
};