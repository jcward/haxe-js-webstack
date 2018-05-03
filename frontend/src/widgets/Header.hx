package widgets;

import riot.Riot;
import simple_router.SimpleRouter;

typedef HeaderOpts = {}

class Header extends RiotBase<HeaderOpts>
{
  public static var TAG_NAME:String = "the-header";

  private function nav(e:js.html.Event)
  {
    SimpleRouter.instance.navigate_to(untyped e.target.href);
    e.preventDefault();
    e.stopImmediatePropagation();
  }
}
