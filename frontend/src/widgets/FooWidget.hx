package widgets;

import riot.Riot;

typedef FooWidgetOpts = {}

class FooWidget extends RiotBase<FooWidgetOpts>
{
  public static var TAG_NAME:String = "foo-widget";

  private function new()
  {
    trace('FooWidget with opts: $opts');
  }
}
