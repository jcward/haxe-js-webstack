package;

#if js
extern class JSON
{
  public static function parse(json:String):Dynamic;
  public static function stringify(value:Dynamic, ?replacer:Dynamic->Dynamic->Dynamic, ?space:String):String;
}
#end
