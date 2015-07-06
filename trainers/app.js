global.rootRequire = function(name) {
  return require(__dirname + '/' + name);
};

global.__ROOT_PATH = __dirname;
global.__ENVIRONMENT = process.env.ENV || 'development';

rootRequire('others/prototypeExtends');

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
  config        = rootRequire(global.__ENVIRONMENT),
  queries       = rootRequire('others/queries'),
  files         = {
    TWITTER_ACTOR: 'twitter-actor.csv',
    INSTAGRAM: 'instagram.csv'
  };

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

function getTrainedAmount(file, callback) {
  var base = file.replace(/.\d+$/,''), r;
  exec("wc -l ./" + base + '*', function (error, stdout, stderr) {
    if (stderr) { return callback(0); }
    r = stdout.split('\n').filter(function (v) { return !!v });
    callback(parseInt(r[r.length - 1].match(/\d+/)[0]));
  });
}

function getFileName(source) {
  var d = new Date(), datespan = d.getFullYear() + d.getMonth().toString().padLeft(2, '0') + d.getDate().toString().padLeft(2, '0');
  return files[source === 'instagram' ? 'INSTAGRAM' : 'TWITTER_ACTOR'] + '.' + datespan;
}

app.get('/', function (req, res) {
  res.redirect('/trainers');
});

app.get('/trainers', function (req, res) {
  res.render('index', {title: null});
});

app.get('/trainers/twitter-actor-classification', function (req, res) {
  getTrainedAmount(files.TWITTER_ACTOR, function (count) {
    res.render('twitter_actor_classification', {title: 'Twitter Actor Classification', count: count});
  });
});

app.get('/trainers/instagram-spam', function (req, res) {
  getTrainedAmount(files.INSTAGRAM, function (count) {
    res.render('instagram_spam', {title: 'Instagram Spam', count: count});
  });
});

app.get('/trainers/activities', function (req, res) {
  var limit = parseInt(req.query.limit) || 10, source = req.query.source;
  connection.query(queries.getActivities(source, limit), function (err, activities) {
    if (err) throw err;
    res.json({activities: activities});
  });
});

app.post('/trainers/save', function (req, res) {
  var action = req.body.action, nativeId = req.body.nativeId, 
    row = nativeId + ',' + action + '\n',
    file = getFileName(req.body.source);
  fs.appendFile(file, row, function (err) {
    res.writeHead(201);
    getTrainedAmount(file, function (count) {
      res.write(JSON.stringify({ count: count }));
      res.end();
    });
  });
});

app.listen(process.env.PORT || 3456);


