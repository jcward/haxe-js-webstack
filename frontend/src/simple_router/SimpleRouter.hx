package simple_router;

import js.Promise;
import js.Browser.window;
import js.html.Element;

interface IPage {
  // public static var route:RouteMatcher;
  private var router:SimpleRouter;
  public function set_title():Void;
  public function do_mount(root_element:Element):Void;
  public function do_unmount():Void;
}

enum RouteMatcher {
  RM_STRING(s:String);
  RM_EREG(r:EReg);
  RM_FUNCTION(func:String->Bool);
}

typedef HmmOdd = Dynamic; // Not sure why Class<IPage> isn't working here
typedef PageDef = {
  class_loader:Void->js.Promise<HmmOdd>,
  route_matcher:RouteMatcher
}

typedef ActivePage = {
  def:PageDef,
  page:IPage
}

typedef LoaderDef = {
                      ?loader_cls:Class<IPage>,
                      ?ready:Void->Bool
                    }

typedef SomeTBD = Dynamic;

/**
 * Uses the History API to handle IPage navigation.
 */
class SimpleRouter
{
  // TODO: unsingleton?
  public static var instance(default,null):SimpleRouter;
  
  private var _root_element:Element;
  private var _page_defs:Array<PageDef>;
  private var _active_page:ActivePage;

  public function new(root_element:Element,
                      page_defs:Array<PageDef>=null,
                      loader:LoaderDef)
  {
    _root_element = root_element;
    if (page_defs==null) page_defs = [];
    _page_defs = page_defs;

    instance = this;
    
    window.addEventListener('popstate', handle_url_change);

    inline function init() { handle_url_change(); }
    if (loader==null) {
      init();
    } else {
      if (loader.loader_cls!=null) {
        // Hmm, def:null is questionable...
        _active_page = { def:null, page:null };
        set_active_page(loader.loader_cls);
      }
      if (loader.ready==null) {
        init();
      } else {
        function check_ready() {
          if (loader.ready()) {
            init();
          } else {
            window.setTimeout(check_ready, 16);
          }
        }
        check_ready();
      }
    }
  }

  public function add_page_def(def:PageDef) {
    _page_defs.unshift(def);
  }

  public function navigate_to(url:String) {
    window.history.pushState(null,null,url);
    handle_url_change();
  }

  private function handle_url_change(e=null)
  {
    var state = e==null ? null : e.state;
    var route = window.location.pathname;
    if (route==null || route=='') route = '/';
    if (route.indexOf('/')!=0) {
      trace('Hmm, doesn\'t pathname always start with a / ?');
      route = '/'+route;
    }
    trace('SimpleRouter navigating to: ${ route }');

    var tgt_def = null;
    for (def in _page_defs) {
      var matcher = def.route_matcher;
      if (switch matcher {
            case RM_STRING(s): s==route;
            case RM_EREG(r): r.match(route);
            case RM_FUNCTION(f): f(route);
          }) { tgt_def = def; break; }
    }

    if (tgt_def!=null) {
      load_page_def(tgt_def, state);
    } else {
      trace('Error: route did not match a page: ${ route }');
    }
  }

  private function load_page_def(def:PageDef,
                                 state:SomeTBD)
  {
    if (_active_page!=null) {

      // Already on this page?
      if (_active_page.def==def) {
        // TODO: some refresh notion?
        return;
      }

      // Unload (or cancel load) active_page
      if (_active_page.page!=null) {
        _active_page.page.do_unmount();
      }
    }

    // Set _active_page and load page class via Bundle
    _active_page = { page:null, def:def };
    _active_page.def.class_loader().then(function(cls) {
      // Ensure we're still the active_page after loading...
      if (_active_page.def==def) set_active_page(cls);
    });
  }

  private function set_active_page(page_cls:Class<IPage>)
  {
    var page:IPage = Type.createInstance(page_cls, []);
    @:privateAccess page.router = this;
    _active_page.page = page;

    // TODO: I'm not sure about this -- will it flicker?
    // will things unmount / dispose properly?
    _root_element.innerHTML = '';

    page.do_mount(_root_element);
    page.set_title();
  }
}
