package;

import express.Express;
import express.Request;
import express.Response;
import express.Next;

import express.IExpressRouteHandler;
import logger.Logger;

import google.GoogleAPIs;
import google.auth.OAuth2Client;

import mongodb.MongoDB;

import util.AsyncUtil;

class DebugRoutes
 implements IExpressRouteHandler
 implements IUseAwait
{
  private static inline var TEST_COLLECTION = 'test_collection';

  private var _mongodb:MongoDB;

  public function new(app:Express, db:MongoDB)
  {
    _mongodb = db;
  }

  @:get('/api/v1.0/test')
  private function test_route(request:Request,
                              response:Response,
                              next:Next)
  {
    trace('Hello trace!');
    Logger.info('Hello info!');
    Logger.error('Hello error!');
    response.json({status:'success'});
  }

  
  @:async
  @:get('/api/v1.0/test_mongo/:name')
  private function test_mongo(request:Request,
                              response:Response,
                              next:Next)
  {
    var name:String = request.params.name;

    var collection = _mongodb.collection(TEST_COLLECTION);
    var err, doc = @await collection.findOne({ name:name });
    if (err!=null) {
      wmroute_error(response, 'Mongodb error');
    }
    if (doc==null) {
      Logger.info('No doc found with name: $name -- creating one...');
      doc = { name:name, age:Math.floor( 18+Math.random()*40 ), inserted:Date.now().getTime() };
      var err, result = @await collection.insert(doc);
      if (err!=null) {
        wmroute_error(response, 'Mongodb error writing');
      }
    }

    response.json({status:'success', now:Date.now().getTime(), doc:doc });
  }

  @:get('/api/v1.0/get_items')
  private function get_items(request:Request,
                             response:Response,
                             next:Next)
  {
    response.json([ { name:'foo_a' }, { name:'foo_b' }, { name:'foo_c' } ]);

  }

}
