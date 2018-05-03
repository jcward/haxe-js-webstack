package util;

import js.html.Element;
import js.Browser.*;
import js.Promise;

//using util.StringUtil;
typedef Nothing = Dynamic;

class DOMUtil
{
  private static var CSS_PREFIX = 'duic';
  public static function inject_css(css:String, id:String)
  {
    var pid = '$CSS_PREFIX-$id';
    if (document.getElementById(pid)==null) {
      var style:Dynamic = document.createElement('style');
      if (style.styleSheet) style.styleSheet.cssText = css;
      else style.appendChild(document.createTextNode(css));
      document.head.appendChild(style);
    }
  }
  
  public static function load_stylesheet(url:String):Promise<Nothing>
  {
    return new Promise(function (resolve, reject) {
      var link:Dynamic = document.createElement('link');
      link.rel = 'stylesheet';
      link.href = url;
      link.onload = resolve;
      link.onerror = reject;
      // Any benefit to this: document.getElementsByTagName('head')[0].appendChild(link);
      document.head.appendChild(link);
    });
  }

  public static function load_script(url:String):Promise<Nothing> {
    return new Promise(function (resolve, reject) {
      var s:Dynamic = document.createElement('script');
      s.src = url;
      s.onload = resolve;
      s.onerror = reject;
      document.head.appendChild(s);
    });
  }

  // public static inline function add_class(e:Element, cls:String)
  // {
  //   var cur = e.className;
  //   cur.split(cls)
  // }
}
