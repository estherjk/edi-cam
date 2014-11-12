// Load the single view; AngularJS will handle view changes on the front-end
// NB: This needs to be the last route added
exports.serveIndex = function (app, staticFolder) {
  app.get('*', function (req, res) {
    res.sendFile('index.html', { root: staticFolder });
  });
};