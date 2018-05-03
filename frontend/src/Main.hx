package;

import js.Promise;
import js.html.Element;
import js.Browser.*;

import simple_router.SimpleRouter;
import pages.Homepage;
import pages.About;

class Main
{
  public static function main()
  {
    var page_defs = [
      { class_loader:Bundle.deferredLoader(Homepage), route_matcher:RM_STRING('/') },
      { class_loader:Bundle.deferredLoader(About), route_matcher:RM_STRING('/about') }
    ];
    var check_fonts_loaded = FontLoader.load_fonts();
    var check_scripts_loaded = ScriptLoader.load_scripts();
    var unref_widgets_promise = null;
    var unref_widgets_loaded = false;

    var loader:LoaderDef = {
      loader_cls:Loader,
      ready:function() {
        var phase1:Bool = untyped (check_fonts_loaded() &&
                                   check_scripts_loaded() )==true;
        if (phase1) {
          if (unref_widgets_promise==null) {
            Bundle.load(UnrefWidgets).then(function(_) {
              unref_widgets_loaded = true;
            });
          }
          return unref_widgets_loaded;
        }
        return false;
      }
    };
    var router = new simple_router.SimpleRouter(window.document.body,
                                                page_defs,
                                                loader);
  }
}

class FontLoader {
  private static var font_urls = [
    "https://fonts.googleapis.com/css?family=Montserrat|Open+Sans:300,600",
    "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.css"
  ];

  public static function load_fonts():Void->Bool
  {
    util.DOMUtil.inject_css('body { font-family: "Open Sans", sans-serif; } h1,h2,h3,h4 { font-family: "Montserrat", sans-serif; }', 'app-fonts');
    var outstanding = font_urls.length;
    for (url in font_urls) {
      util.DOMUtil.load_stylesheet(url).then(function(n) { outstanding--; });
    }
    return function() {
      return outstanding==0;
    };
  }
}

class ScriptLoader {
  private static var init_scripts = [
    "https://cdnjs.cloudflare.com/ajax/libs/sizzle/2.3.3/sizzle.min.js",
    "https://cdnjs.cloudflare.com/ajax/libs/riot/3.9.4/riot.js"
  ];

  public static function load_scripts():Void->Bool
  {
    var outstanding = init_scripts.length;
    for (url in init_scripts) {
      util.DOMUtil.load_script(url).then(function(n) { outstanding--; });
    }
    return function() {
      return outstanding==0;
    };
  }
}

// Be careful not to use any logic / libs provided by
// the init scripts or CSS in the Loader.
class Loader implements IPage
{
  public var router:SimpleRouter;
  private var _content:Element;

  public function new()
  {
    _content = js.Browser.document.createElement('div');
    _content.innerHTML = '<div style="margin:10%;text-align:center">Loading...</div>';
  }

  public function set_title() js.Browser.document.title = 'Welcome!';

  public function do_mount(root_element:Element):Void
  {
    root_element.appendChild(_content);
  }

  public function do_unmount():Void
  {
    _content.remove();
  }
}
