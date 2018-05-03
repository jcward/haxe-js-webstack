package express;

typedef FNext = Void -> Void;
typedef FNextRoute = String -> Void;
typedef FNextError = Error -> Void;

abstract Next(Dynamic)
  from FNext to FNext
  from FNextRoute to FNextRoute
  from FNextError to FNextError
{
  public inline function call()
    untyped this();

  public inline function error(err : js.Error)
    untyped this(err);

  public inline function route()
    untyped this("route");
}
