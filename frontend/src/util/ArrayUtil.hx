package util;

import haxe.macro.Context;
import haxe.macro.Expr;

using Lambda;

@:keep
class ArrayUtil {

  @generic static public function as_array_of<T>(A:Array<Dynamic>, cls:Class<T>):Array<T>
  {
    var t:Array<T> = A.map(function(a):T { return cast a; }).array();
    return t;
  }

  public static function any<T>(array:Array<T>, filter:T->Bool):Bool
  {
    for (i in 0...array.length) if (filter(array[i])) return true;
    return false;
  }

  public static inline function shallow_clone<T>(array:Array<T>):Array<T>
  {
    // Yep, this is your basic array comprehension, in case
    // you forget the syntax:
    return [ for (i in array) i ];
  }

  // returns the first element for which filter(element) returns true
  public static function find<T>(array:Array<T>, filter:T->Bool):T
  {
    for (i in 0...array.length) if (filter(array[i])) return array[i];
    return null;
  }

  // Run the handler on each element in the array
  public static function each<T>(array:Array<T>, handler:T->Void):Array<T>
  {
    for (i in 0...array.length) handler(array[i]);
    return array;
  }

  // Remove elements from the array for which filter(element) returns true
  public static function delete<T>(array:Array<T>, filter:T->Bool):Array<T>
  {
    // Note: Haxe iterator spec means that array.length will be captured
    //       at the beginning, so incrementing to array.length while
    //       modifying the array is legitimate.
    var l = array.length-1;
    for (i in 0...array.length) if (filter(array[l-i])) array.splice(l-i, 1);
    return array;
  }

  // Returns a new array of elements for which filter(elem) == true
  public static function select<T>(array:Array<T>, filter:T->Bool):Array<T>
  {
    var rtn = [];
    for (i in 0...array.length) if (filter(array[i])) rtn.push(array[i]);
    return rtn;
  }

  // Returns the first element for which filter(element) returns true
  public static function select_one<T>(array:Array<T>, filter:T->Bool):T
  {
    for (i in 0...array.length) if (filter(array[i])) return array[i];
    return null;
  }

  inline public static function sort_strings(A:Array<String>):Void {
    A.sort(function(a:String, b:String):Int {return (a < b) ? -1 : ((a > b) ? 1 : 0);});
  }

  public static function uniq_strings(A:Array<String>):Array<String> {
    var hash = {};
    return delete(A,function(a:String):Bool {
      if (!Reflect.hasField(hash,a)) {Reflect.setField(hash,a,true); return false;}
      return true;
      });
  }


  // Return a randomly selected array element
  public static function sample<T>(A:Array<T>):T {
    if (A==null || A.length==0) return null;
    return A[Std.random(A.length)];
  }

  //shuffle items in arrays using a modern Fisher–Yates shuffle as described
  // by Richard Durstenfeld in ACM volume 7, issue 7: "Algorithm 235: Random permutation".
  //   Wikipedia: http://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle
  public static function shuffle<T>(A:Array<T>):Void
  {
    for (k in 0...A.length) {
      var i = (A.length-1)-k;
      var j:Int = Std.random(i+1);
      var temp:T = A[i]; A[i] = A[j]; A[j] = temp;
    }
  }

  // Insert an item in the array, replacing an existing item
  // based on the given match function. Returns true if
  // the item is successfully placed in the array.
  public static function upsert<T>(A:Array<T>,
                                   item:T,
                                   match:T->Bool,
                                   push_if_unmatched:Bool=true):Bool
  {
    if (A==null) return false;

    for (i in 0...A.length) {
      var existing = A[i];
      if (match(existing)) {
        A[i] = item;
        return true;
      }
    }

    if (push_if_unmatched) {
      A.push(item);
      return true;
    }
    return false;
  }

  // TODO: merge into above shuffle (good implementation above, but needs
  //       RNG capability)
  // Return a new array with the same elements as in array, but in random order
  public static function shuffle_rng<T>(array:Array<T>, rng:Void->Float=null):Array<T>
  {
    // Naive implementation, need one with RNG seed
    var random = [];
    for (lbl in array) {
      var uniform = rng==null ? Math.random() : rng();
      var idx = Std.int(uniform*(1 + random.length));
      var right = random.splice(idx, random.length-idx);
      right.unshift(lbl);
      random = random.splice(0, idx).concat(right);
    }

    return random;
  }

  // returns the last element of the array
  public static function last<T>(array:Array<T>):T { return array[array.length-1]; }
  public static function penultimate<T>(array:Array<T>):T { return array[array.length-2]; }

  // returns the first element of the array
  public static function first<T>(array:Array<T>):T { return array[0]; }

}
