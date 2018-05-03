package google;

typedef ExternTODO = Dynamic;

extern class GoogleAPIs
{
  public function urlshortener(version:String):ExternTODO;
  public var auth:{ OAuth2Client:Class<google.auth.OAuth2Client> };
}

typedef GAPISecrets = {
  web:{
    client_id:String,             // "...-....apps.googleusercontent.com",
    project_id:String,            // "...",
    auth_uri:String,              // "https://accounts.google.com/o/oauth2/auth",
    token_uri:String,             // "https://accounts.google.com/o/oauth2/token",
    auth_provider_x509_cert_url:String, // "https://www.googleapis.com/oauth2/v1/certs",
    client_secret:String,            // "...",
    redirect_uris:Array<String>,     // ["http://localhost/oauth2callback"]
    javascript_origins:Array<String> // ["http://localhost"]
  }
}
