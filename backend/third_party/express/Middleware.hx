package express;

import haxe.extern.EitherType;

typedef FMiddleware = Request -> Response -> Void;
typedef FMiddlewareNext = Request -> Response -> Next -> Void;

abstract Middleware(Dynamic)
  from FMiddleware to FMiddleware
  from FMiddlewareNext to FMiddlewareNext
{ }

typedef FErrorMiddleware = Error -> Request -> Response -> Void;
typedef FErrorMiddlewareNext = Error -> Request -> Response -> Next -> Void;

abstract ErrorMiddleware(Dynamic)
  from FErrorMiddleware to FErrorMiddleware
  from FErrorMiddlewareNext to FErrorMiddlewareNext
{ }

typedef EitherMiddleware = EitherType<Middleware, ErrorMiddleware>;
