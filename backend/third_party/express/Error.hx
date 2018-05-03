package express;

@:native("Error")
extern class Error extends js.Error {
  public var status : Int;
}
