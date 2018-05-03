package logger;

extern class Logger
{
  public static inline function info(msg:String):Void untyped global['winston_logger'].info(msg);
  public static inline function error(msg:String):Void untyped global['winston_logger'].error(msg);
}
