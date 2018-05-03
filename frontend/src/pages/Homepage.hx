package pages;

import simple_router.SimpleRouter;
import riot.Riot;

typedef HomepageOpts = {}

class Homepage extends RiotBase<HomepageOpts>
  implements IPage
{
  public static var TAG_NAME:String = "the-homepage";

  private var router:SimpleRouter;
  private var items:Array<{ name:String }> = [];

  private function new()
  {
    trace('Hello from a new Homepage!');
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
