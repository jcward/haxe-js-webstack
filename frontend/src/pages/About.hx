package pages;

import simple_router.SimpleRouter;
import riot.Riot;

typedef AboutOpts = {}

class About extends RiotBase<AboutOpts>
  implements IPage
{
  public static var TAG_NAME:String = "about-page";

  private var router:SimpleRouter;
  private var items:Array<{ name:String }> = [];

  private function new()
  {
    trace('Hello from a new About!');
    fetch_items_from_server();
  }

  private function fetch_items_from_server():Void
  {
    util.HTTPUtil.load_json('/api/v1.0/get_items').then(function(items) {
      this.items = items;
      update();
    });
  }

  public function handle_click(e:js.html.Event)
  {
    trace('Got click event: '+e);
  }

  public function do_unmount() {
    trace('TODO: unmount');
  }

  public function set_title() js.Browser.document.title = 'Welcome!';
}
