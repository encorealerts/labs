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
  exec          = require('child_process').exec,
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

var connection = mysql.createConnection({ 
  host: config.db.host, 
  user: config.db.user, 
  password: config.db.pw, 
  database: config.db.database,
  supportBigNumbers: true });
connection.connect(function (error) {
  if (error) { throw error; }
  console.log('MySQL Connected');
});

function getTrainedAmount(callback) {
  exec("wc -l ./result.csv", function (error, stdout, stderr) {
    if (stderr) {
      return callback(0);
    }
    callback(parseInt(stdout.match(/^\d+/)[0]));
  });
}

app.get('/', function (req, res) {
  getTrainedAmount(function (count) {
    res.render('index', {count: count});
  });
});

var activitiesQuery = [];
activitiesQuery.push('SELECT r1.* ');
activitiesQuery.push(' FROM activities AS r1 JOIN');
activitiesQuery.push('    (SELECT ');
activitiesQuery.push('      (');
activitiesQuery.push('        (SELECT MIN(id) FROM activities) + ');
activitiesQuery.push('        RAND() *');
activitiesQuery.push('        (SELECT (SELECT MAX(id) FROM activities) - (SELECT MIN(id) FROM activities))');
activitiesQuery.push('      ) AS id)');
activitiesQuery.push('    AS r2');
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
    getTrainedAmount(function (count) {
      res.write(JSON.stringify({ count: count }));
      res.end();
    });
  });
});

app.listen(process.env.PORT || 3456);


