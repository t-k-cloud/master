/*
 * exec
 */
var execSync = require('child_process').execSync;

/*
 * jobd
 */
var jobsldr = require('../jobd/src/jobsldr.js');
var jobdhdlr = require('../jobd/src/jobd-handler.js');

/* arguments parsing */
var args = process.argv;

if (3 != args.length) {
	console.log('bad args.');
	process.exit(1);
}

var user = args[2];
var workdir = '/home/' + user;
var jobsdir = workdir + '/jobs';

/* root/jobsdir tester */
try {
	execSync('touch /root/test');
	execSync('test -d ' + jobsdir);
} catch (e) {
	console.log(e.message);
	process.exit(2);
}

/* load jobs/configs */
var jobs = {};
try {
	jobs = jobsldr.load(jobsdir);
} catch (e) {
	console.log(e.message);
	process.exit(3);
}

console.log('environment variables:');
console.log(jobs.env);

process.stdin.on('error', function (e) {
	console.log('main process stdin error: ' + e.message);
});

/*
 * express
 */
var express = require('express');
var bodyParser = require('body-parser');
var path = require('path');
var app = express();

app.use(express.static('.'));
app.use(bodyParser.json());

const port = 3002;
app.listen(port);
console.log('listening on port ' + port);

/*
 * auth
 */
var expAuth = require('../auth/express-auth.js');

expAuth.init(app, {
	keyName: 'tk-auth',
	loginRoute: '/login'
});

/*
 * routing
 */
app.get('/', function (req, res) {
	res.sendFile(path.resolve('./html/index.html'));

}).get('/jobd/deps', function (req, res) {
	jobdhdlr.handle_deps(req, res, jobs.depGraph);

}).get('/jobd/graph', function (req, res) {
	res.sendFile(path.resolve('./html/graph.html'));

}).get('/jobd/reload', expAuth.middleware, function (req, res) {
	jobs = jobdhdlr.handle_reload(res, jobsldr, jobsdir, jobs);

}).get('/login', function (req, res) {
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
