package google.auth;

typedef OAuthError = { code:Int, message:String };
typedef OAuthTokens = { access_token:String, refresh_token:String };

// https://github.com/google/google-api-nodejs-client
@:native('(require("googleapis").auth.OAuth2)')
extern class OAuth2Client
{
  public function new(client_id:String, client_secret:String, redirecT_uri:String);

  public function getToken(auth_code:String, callback:OAuthError->OAuthTokens->Void):Void;

  // This is how you set credentials (aka tokens), though docs seems to suggest a
  // setCredentials function, it is not there...
  public var credentials(null,default):OAuthTokens;
}
