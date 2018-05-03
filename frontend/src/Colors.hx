package;

class Colors
{
  public static var WHITE:ColorValue = RGB(255,255,255);
  public static var PRIMARY:ColorValue = '#4353bc'; // RGB(134,45,96);   // '#f26';
  public static var TEXT_ON_PRIMARY:ColorValue = RGB(255,255,255); // '#f26';

  public static function mix(c0:ColorValue,c1:ColorValue,pct:Float):EColorValue
  {
    var r:Int;
    var g:Int;
    var b:Int;
    var a:Float = 1.0;
    switch c0 {
      case RGB(r0,g0,b0):     r = r0; g = g0; b = b0; a = 1.0;
      case RGBA(r0,g0,b0,a0): r = r0; g = g0; b = b0; a = 1.0;
    }
    inline function mf(from:Float,to:Float) return to*pct+from*(1-pct);
    inline function mi(from:Int,to:Int) return Math.round(to*pct+from*(1-pct));
    switch c1 {
      case RGB(r1,g1,b1):     r = mi(r,r1); g = mi(g,g1); b = mi(b,b1); a = mf(a,1.0);
      case RGBA(r1,g1,b1,a1): r = mi(r,r1); g = mi(g,g1); b = mi(b,b1); a = mf(a,a1);
    }
    if (a>=1.0) return validate(RGB(r,g,b));
    return validate(RGBA(r,g,b,a));
  }

  public static function validate(c:EColorValue):EColorValue
  {
    inline function bi(v:Int) { return (v<0 ? 0 : (v>255 ? 255 : v)); }
    inline function bf(v:Float) { return (v<0 ? 0 : (v>1.0 ? 1.0 : v)); }
    return switch c {
      case RGB(r,g,b):    RGB(bi(r), bi(g), bi(b));
      case RGBA(r,g,b,a): (a>=1.0) ? RGB(bi(r), bi(g), bi(b)) : RGBA(bi(r), bi(g), bi(b), bf(a));
    }
  }

  // THX: https://github.com/openfl/svg/blob/master/format/svg/SVGData.hx
	public static function parseHex(hex:String):EColorValue
	{
		// Support 3-character hex color shorthand
		//  e.g. #RGB -> #RRGGBB
		if (hex.length == 3) {
			hex = hex.substr(0,1) + hex.substr(0,1) +
			      hex.substr(1,1) + hex.substr(1,1) +
			      hex.substr(2,1) + hex.substr(2,1);
		}
		var i = Std.parseInt ("0x" + hex);
    return RGB((i>>16)&0xff,(i>>8)&0xff,i&0xff);
	}

  public static function parseRGB(s:String):EColorValue
	{
    inline function pi(v:String):Int
    {
      var rtn = Std.parseFloat(v);
      if (v.indexOf('%')>=0) {
        rtn = 255*rtn/100;
      }
      return Math.round(rtn);
    }

    var left = s.indexOf('(');
    var right = s.indexOf(')');
    var values = s.substr(left+1, right-left-1).split(',');

    if (values.length==3) {
      return Colors.validate( RGB(pi(values[0]), pi(values[1]), pi(values[2])) );
    } else if (values.length==4) {
      return Colors.validate( RGBA(pi(values[0]), pi(values[1]), pi(values[2]), Std.parseFloat(values[3])) );
    } else {
      throw 'Failed to parse RGB: $s';
    }
	}
}

enum EColorValue {
  RGB(r:Int, g:Int, b:Int);
  RGBA(r:Int, g:Int, b:Int, a:Float);
}

abstract ColorValue(EColorValue) from EColorValue to EColorValue {

  public function r():Int {
    return switch this {
      case RGB(r,g,b): r;
      case RGBA(r,g,b,a): r;
    }
  }
  public function g():Int {
    return switch this {
      case RGB(r,g,b): g;
      case RGBA(r,g,b,a): g;
    }
  }
  public function b():Int {
    return switch this {
      case RGB(r,g,b): b;
      case RGBA(r,g,b,a): b;
    }
  }
  public function a():Float {
    return switch this {
      case RGB(r,g,b): 1.0;
      case RGBA(r,g,b,a): a;
    }
  }
  public function cmax():Int {
    return switch this {
      case RGB(r,g,b) | RGBA(r,g,b,_):
        var max = r;
        if (g>max) max = g;
        if (b>max) max = b;
        max;
    }
  }
  public function cmin():Int {
    return switch this {
      case RGB(r,g,b) | RGBA(r,g,b,_):
        var min = r;
        if (g<min) min = g;
				if (b<min) min = b;
        min;
    }
  }

  public function clight():Float {
    return switch this {
      case RGB(r,g,b) | RGBA(r,g,b,_):
        return (cmax()+cmin())/510.0;
    }
  }

  // The default toString goes to a CSS-compatible string
  @:to
  public function toString():String {
    return switch this {
      case RGB(r,g,b): 'rgb($r,$g,$b)';
      case RGBA(r,g,b,a): 'rgba($r,$g,$b,$a)';
    }
  }

  @:from
  public static function fromString(s:String):ColorValue {
    if (s.indexOf(' ')>=0) s = StringTools.trim(s);
    if (s.indexOf('#')==0 || s.indexOf('x')==0) return Colors.parseHex(s.substr(1));
    if (s.indexOf('0x')==0) return Colors.parseHex(s.substr(1));
    if (s.indexOf('rgb')==0) return Colors.parseRGB(s);
    throw 'Couldn\'t parse color from: $s';
  }
}


