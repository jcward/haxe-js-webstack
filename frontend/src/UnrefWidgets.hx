package;

@:keep
class UnrefWidgets
{
  // Since it's quite possible that widgets never be statically
  // referenced, we need a "catch all" module that holds any
  // widgets that aren't. Note that haxe-modular (seems to)
  // bundle widgets into the lib(s) in which they're used.

  // TODO: macro this list?
  @:keep
  private static var links:Array<Dynamic> = [ widgets.FooWidget, widgets.Header ];
}
