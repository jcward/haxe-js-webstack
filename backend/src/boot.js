// bootstrap.js

var fs = require('fs');
var path = require('path');

// Express Server
var express = require('express');
var app = express();

// Detect nodejs run in debug mode
var debug = process.execArgv.join(' ').indexOf('--inspect')>=0;
console.log('Debug mode: '+debug);

// TODO: from config.yaml
var api_base_url = '/api/v1.0';
var port = 8000;

// Helpers
function is_dir(path) {
  try {
    stat = fs.statSync(path);
    return stat.isDirectory();
  } catch(e) {
    return false;
  }
}

function is_file(path) {
  try {
    stat = fs.statSync(path);
    return stat.isFile();
  } catch(e) {
    return false;
  }
}

YAML = require('yamljs');
var config = YAML.load(__dirname + "/config.yaml");
config.debug = debug;

/////////// Winston (logging) ////////////////////////////////////////////////////////////
//
var winston = require('winston')
winston.default.transports.console.colorize = true;
winston.default.transports.console.level = 'debug';
// use for express
var express_winston = require('express-winston');
var console_logger = new winston.transports.Console({
  level: 'info',
  colorize: true,
})
if(is_dir(path.dirname(config.logfile))) {
   var file_logger =  new winston.transports.File({
    level: 'info',
    filename: config.logfile,
    handleExceptions: true,
    json: false,
    maxsize: 5242880, //5MB
    maxFiles: 5,
    colorize: false
   });
}
var logger_conf = {  transports: [ console_logger ] };
if(file_logger) logger_conf.transports.push(file_logger);
var wlogger = new winston.Logger(logger_conf);
wlogger.info('Hello Winston');
global['winston_logger'] = wlogger;
//
/////////// Winston (logging) ////////////////////////////////////////////////////////////

exports['app_config'] = config;

//
/////////// Configuration ////////////////////////////////////////////////////////////


// cli port number: --port 5300
var port_override = process.argv.indexOf('--port');
if (port_override>=0) {
  port_override = parseInt(process.argv[port_override+1]);
  if (port_override>1024) {
    wlogger.info('-- overriding express port (config has '+config.express_port+') with command line: '+port_override);
    config.express_port = port_override;
  }
}

// - - - Setup express app - - -
app.set('port', config.express_port);
app.set('version', config.version);
var http = require("http")
http.globalAgent.maxSockets = Infinity;
var server = http.createServer(app).listen(app.get('port'), function() {
  wlogger.info("Express server listening on port " + app.get('port'));
});

// Cookie parser (required for parsing auth cookies)
var cookieParser = require('cookie-parser');
app.use(cookieParser());

// Body parser (required for parsing JSON post bodies)
var bodyParser = require("body-parser");
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

// Serve the public directory as / with no caching
var public_dir = path.join(__dirname, 'public');
wlogger.info('Serving: '+public_dir);
app.use(express.static(public_dir));

// Serve the static directory as /s with long-term caching
// app.use('/s', express.static(path.join(__dirname, 'static')));

var hxapp = require('./hxapp.js');
var requirements = {};
requirements.sqldb = 'tbd';
function on_requirement_ready() {
  // Load the Haxe code with the app and database
  if (requirements.mongodb &&
      requirements.sqldb) {
    console.log('Launching HaxeMain.init');

    // Setup Haxe app, registers routes...
    hxapp.Main.init(app,
                    config,
                    requirements.mongodb,
                    requirements.sqldb);

    // Serve everything else to the webapp index.html
    app.get('*', function(req, res){
      fs.readFile('public/index.html', 'utf8', function (err,data) {
        if (data) res.send(data);
        if (err) res.send(err);
      });
    });

  }
}

// - - - - - - - - - - - - - - - - - - - -
// - - - Optional mongodb connection - - -
// - - - - - - - - - - - - - - - - - - - -
if (config.mongo) {
  const MongoClient = require('mongodb').MongoClient;
  if(Array.isArray(config.mongo.host)) {
    hosts = [];
    config.mongo.host.forEach(function(h) {
      hosts.push(h + ':' + config.mongo.port);
    });
    var mongo_url = 'mongodb://' + hosts.join(',') + '/'+config.mongo.dbname+'?replicaSet=wootmath';
  } else {
    var mongo_url = 'mongodb://' + config.mongo.host + ':' + config.mongo.port;
  }
  MongoClient.connect(mongo_url, function(err, client) {
    if (err!=null) {
      wlogger.error("Failed connecting to mongodb at "+mongo_url);
      requirements.mongodb = 'none';
      on_requirement_ready();
    } else {
      wlogger.info("Successfully connected to mongodb at "+mongo_url);

      const db = client.db(config.mongo.dbname);
      requirements.mongodb = db;

      // Expose for JS usage
      app.mongodb = db;

      on_requirement_ready();
    }
  });
 } else { // no mongodb in the config
  requirements.mongodb = 'none';
  on_requirement_ready();
}
// - - - - - - - - - - - - - - - - - - - -

// debug routes
if (debug) {
  app.get(api_base_url+'/alive', function(req, res, next) {
    var rval = {status:'alive', version:req.app.get('version'), port:req.app.get('port')}
    wlogger.debug(rval);
    res.json(rval)
  });

  app.get('/log', function(req, res, next) {
    fs.readFile('local.log', 'utf8', function (err,data) {
      if (data) res.send("<body><pre>"+data+"</pre></body>");
      if (err) res.send(err);
    });
  });

 }

module.exports = app;

wlogger.info('Boot successful! '+new Date()+'\n'+JSON.stringify(config, null, "  "));

// TODO: to let it crash? or not? That is the question...
// TODO: log+monitor these
var uncaught_cnt = 0;
process.on('uncaughtException', function (err) {
  console.log('------------ Uncaught exception ------------');
  console.log(err);
  wlogger.error('------------ Uncaught exception ------------');
  wlogger.error(err);
  uncaught_cnt++;
  if (uncaught_cnt>100 || (""+err).indexOf('MongoNetworkError')>=0) {
    // At some point, we assume we have a problem / memory leak,
    // so die and let upstart restart us.
    process.exit(1);
  }
})
