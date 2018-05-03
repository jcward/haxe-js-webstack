package google;

typedef UserInfo = {
  id:String,            // 111924607520028912559, 
  email:String,         // woot.teacher.1@gmail.com, 
  verified_email:Bool,  // true, 
  name:String,          // : Woot Teacher, 
  given_name:String,    // Woot, 
  family_name:String,   // Teacher, 
  picture:String,       // https://lh3.googleusercontent.com/-XdUIqdMkCWA/AAAAAAAAAAI/AAAAAAAAAAA/4252rscbv5M/photo.jpg, 
  locale:String         // en
}

extern class UserInfoAccessor {
  public function get(opts:Dynamic, ?params:Dynamic, ?callback:Dynamic->UserInfo->Void):Void;
}

extern class OAuth2API
{
  // options -> params -> callback
  public var userinfo:UserInfoAccessor;
}
