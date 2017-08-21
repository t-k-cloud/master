var express = require('express');
var path = require('path');
var expAuth = require('../auth/express-auth.js');
var app = express();

expAuth.init(app, {
	keyName: 'tk-auth',
	loginRoute: 'login'
});

app.get('/login', function (req, res) {
	res.sendFile(path.resolve('./html/login.html'));
}).post('/login_auth', function (req, res) {
	expAuth.handleLoginReq(req, res);
}).get('/private_place', expAuth.middleware, function (req, res) {
	res.write('hello');
	res.end();
}).get('/public_place', function (req, res) {
	res.write('world');
	res.end();
});

app.use(express.static('.'));
app.listen(3000);
