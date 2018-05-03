package util;

import gapi.GAPI;
import gapi.classroom.GClassroom;

typedef MinimalParamConstraint = { ?pageSize:Int, ?pageToken:String };
typedef PossiblyPromise = Dynamic; // aka, I don't care: js.Promise<gapi.GAPIResponse<ResponseType>>
typedef DynamicResponseContainer = Dynamic // aka, { <some_param>:Array<ResponseType> }

class GAPIPaginationHelper
{
  // e.g. ResponseType -- GCCoursesListResult, aka { courses:Array<GCCourseData> }
  public static function fetch_paginated<ParamType:(MinimalParamConstraint),
                                         DynamicResponseContainer,
                                         ResponseType>(
    fetchFunc:ParamType -> Null<gapi.GAPIError -> DynamicResponseContainer -> Void> -> PossiblyPromise,
    result_param_name:String,
    params:ParamType=null,
    pageSize:Int=0, // by default, let Google decide (presumably, they'll choose "a large number")
    callback:GAPIError->Array<ResponseType>->Void=null)
  {
    // Always force pageSize to the number above
    if (params==null) params = untyped {};
    params.pageSize = pageSize;

    function done(err:Dynamic, arr:Dynamic) {
      callback(err, arr);
    }

    var array:Array<Dynamic> = [];
    function get_next_page() {
      //trace('fetch with params: ${params}');
      fetchFunc(params, function(err:Dynamic, res:Dynamic) {
        if (err!=null || res==null) {
          done(err, null);
        } else {
          var current_array:Array<Dynamic> = Reflect.field(res, result_param_name);
          //trace('Page has ${ current_array.length } items');
          if (current_array!=null && current_array.length>0) for (item in current_array) array.push(item);
          if (res.nextPageToken!=null && res.nextPageToken.length>0) {
            //trace('Fetching next page: ${ res.nextPageToken }');
            // Update the params with the next page token
            params.pageToken = res.nextPageToken;
            get_next_page();
          } else {
            done(null,array);
          }
        }
      });
    }
    get_next_page();

  }

}
