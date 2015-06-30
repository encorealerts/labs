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

var queryArr = [];
queryArr.push('SELECT *');
queryArr.push('FROM activities, (');
queryArr.push('    SELECT id AS sid');
queryArr.push('    FROM activities AS acs');
queryArr.push('    ORDER BY RAND( )');
queryArr.push('    LIMIT :limit');
queryArr.push(' ) tmp');
queryArr.push('WHERE activities.id = tmp.sid');
queryArr.push('  AND activities.in_reply_to_native_id is NULL;');

app.get('/alerts', function (req, res) {
  var limit = (parseInt(req.query.limit || 10) * 1.1).toFixed(0), 
    query = queryArr.join('\r').replace(':limit', limit);
  connection.query(query, function (err, rows, fields) {
    if (err) throw err;
    res.json({activities: rows})
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


