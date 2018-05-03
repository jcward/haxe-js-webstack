package;

import logger.Logger;
import express.Express;
import mongodb.MongoDB;

typedef AppConfig = {
  version:String,   // "local",
  express_port:Int, // 8000,
  logfile:String,   // "./local.log",
  debug:Bool        // true
}

typedef TODOSQLDB = Dynamic;

@:expose("Main")
class Main
{
  public static function init(app:Express,
                              app_config:AppConfig,
                              db:MongoDB,
                              sql:TODOSQLDB)
  {
    // Instantiate IExpressRoutes here:
    if (app_config.debug) {
      Logger.info('DebugRoutes enabled!');
      new DebugRoutes(app, db);
    }
  }

  public static function main() { }
}
