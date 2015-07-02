global.rootRequire = function(name) {
  return require(__dirname + '/' + name);
};

global.__ROOT_PATH = __dirname;
global.__ENVIRONMENT = process.env.ENV || 'development';

var 
  express       = require('express'),
  engine        = require('ejs-locals'),
  compress      = require('compression'),
  cookieParser  = require('cookie-parser'),
  bodyParser    = require('body-parser'),
  path          = require('path'),
  mime          = require('mime'),
  fs            = require('fs'),
  app           = express(),
  oneYear       = 31556908800,
  walk          = rootRequire('others/walk'),
  mysql         = require('mysql'),
  config        = rootRequire(global.__ENVIRONMENT);

app.engine('ejs', engine);
app.set('views', __dirname + '/views');
app.set('view engine', 'ejs');

app.use(compress());
app.use(express.static(__dirname + '/public', {
  maxAge: __ENVIRONMENT == 'production' ? oneYear : -1
}));

app.use(cookieParser());
app.use(bodyParser.urlencoded({extended:true}));
app.use(bodyParser.json());

var connection = mysql.createConnection({ host: config.db.host, user: config.db.user, password: config.db.pw, database: config.db.database });
connection.connect(function (error) {
  if (error) { throw error; }
  console.log('MySQL Connected');
});

app.get('/', function (req, res) {
  res.render('index');
});

var activitiesQuery = [];
activitiesQuery.push('SELECT r1.*');
activitiesQuery.push(' FROM activities AS r1 JOIN');
activitiesQuery.push('      (SELECT (RAND() *');
activitiesQuery.push('                    (SELECT MAX(id)');
activitiesQuery.push('                       FROM activities)) AS id)');
activitiesQuery.push('       AS r2');
activitiesQuery.push('WHERE r1.id >= r2.id');
activitiesQuery.push('    AND r1.verb = \'post\'');
activitiesQuery.push('    AND r1.source = \'twitter\'');
activitiesQuery.push('ORDER BY r1.id ASC');
activitiesQuery.push('LIMIT 100; ');

app.get('/alerts', function (req, res) {
  var limit = parseInt(req.query.limit) || 10;
  connection.query(activitiesQuery.join('\r').replace(':limit', limit), function (err, activities) {
    if (err) throw err;
    res.json({activities: activities});
  });
});

app.post('/save', function (req, res) {
  var action = req.body.action, nativeId = req.body.nativeId, 
    row = nativeId + ',' + action + '\n';
  fs.appendFile('result.csv', row, function (err) {
    res.writeHead(201);
    res.end();
  });
});

app.listen(process.env.PORT || 3456);


