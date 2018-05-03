package express;

#if !macro
@:autoBuild(express.IExpressRouteHandlerUtil.build())
interface IExpressRouteHandler { }
#end

#if macro
import haxe.macro.Expr;
import haxe.macro.*;
using haxe.macro.ExprTools;
#end

class IExpressRouteHandlerUtil
{
  // Parse metatags and setup constructor
  public static function build()
  {
#if macro
    var fields = haxe.macro.Context.getBuildFields();

    var attach:Array<Expr> = [];

    for (field in fields) {
      switch (field.kind) {
        case FFun(f):
          var has_async = false;
          for (meta in field.meta) if (meta.name==':async') has_async = true;

          for (meta in field.meta) {

            if (meta.name==':get') {
              // Push attach statement
              if (has_async) {
                attach.push( macro
                             app.get($e{ meta.params[0] }, function(req,res,nex) {
                                 $i{ field.name }(req,res,nex,function() { });
                             })
                );
              } else {
                attach.push( macro app.get($e{ meta.params[0] }, $i{ field.name }) );
              }
            }

            if (meta.name==':post') {
              // Push attach statement
              if (has_async) {
                attach.push( macro
                             app.post($e{ meta.params[0] }, function(req,res,nex) {
                                 $i{ field.name }(req,res,nex,function() { });
                             })
                );
              } else {
                attach.push( macro app.post($e{ meta.params[0] }, $i{ field.name }) );
              }
            }

          }

        default:
      }
    }

    //for (e in attach) logger.Logger.info(e.toString());

    var constructor_found = false;
    for (field in fields) {
      if (field.name=='new') {
        // logger.Logger.info(field);
        constructor_found = true;
        switch (field.kind) {
          case FFun(f):
            attach.unshift(f.expr);
            f.expr = { expr:EBlock(attach), pos:f.expr.pos } ;
            //logger.Logger.info(f.expr.toString());
          default:
        }
      }
    }

    // Inject constructor if not found
    if (!constructor_found) {
      fields.push({
        name: "new",
        access: [APublic],
        kind: FieldType.FFun({
          expr: { expr:EBlock(attach), pos:Context.currentPos() },
          ret: (macro:Void),
          args:[
            { meta:[], name:'app', type:TPath({ name:'Express', pack:['express'], params:[] })},
            { meta:[], name:'db', type:TPath({ name:'MongoDB', pack:['mongodb'], params:[] })}
          ]
        }),
        pos: Context.currentPos(),
      });
    }

    // Response error handler
    fields.push({
      name: "wmroute_error",
      access: [APrivate],
      kind: FieldType.FFun({
        expr: macro {
                logger.Logger.error('wmroute_error: message:$$msg');
                if(e!=null) logger.Logger.error('wmroute_error: error:$$e');
                response.status(500);
                response.setHeader('Content-Type', 'application/json'); // response is JSON
                response.json({status:'error', msg:msg});
                // Allow MongoNetworkError to crash the app
                if ((''+e).indexOf('MongoNetworkError')>=0) throw e;
              },
        ret: (macro:Void),
        args:[
          { meta:[], name:'response', type:TPath({ name:'Response', pack:['express'], params:[] })},
          { meta:[], name:'msg', type:TPath({ name:'String', pack:[], params:[] })},
          { meta:[], name:'e', opt:true, type:TPath({ name:'Dynamic', pack:[], params:[] })}
        ]
      }),
      pos: Context.currentPos(),
    });

    return fields;
#end
  }
}
