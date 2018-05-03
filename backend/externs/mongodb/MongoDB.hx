package mongodb;

import haxe.extern.EitherType;

import js.Promise;

typedef ExternTODO = Dynamic;

typedef Query = {}; // Hmm... $and / $or / etc?
typedef Document = Dynamic;
typedef MongoError = {};
typedef ObjectId = String;

// http://mongodb.github.io/node-mongodb-native/3.0/api/Db.html
extern class MongoDB
{
  public function collection(name:String):Collection;
}

typedef CountOptions = {
  ?limit:Float,  // The limit of documents to count
  ?skip:Float,   // The number of documents to skip for the count
  ?hint:String, // An index name hint for the query.
  ?readPreference:String, // The preferred read preference (ReadPreference.PRIMARY, ReadPreference.PRIMARY_PREFERRED, ReadPreference.SECONDARY, ReadPreference.SECONDARY_PREFERRED, ReadPreference.NEAREST).
  ?maxTimeMS:Float, // Number of miliseconds to wait before aborting the query.
  ?session:ExternTODO // ClientSession
}

typedef UpdateOptions = {
  // w           // number | string null  optional, The write concern.
  ?wtimeout:Int, // number  null  optional, The write concern timeout.
  ?j:Bool,       // boolean false optional, Specify a journal write concern.
  ?upsert:Bool,  //  boolean false optional, Update operation is an upsert.
  ?multi:Bool,   // boolean false optional, Update one/all documents with operation.
  ?bypassDocumentValidation:Bool, //  boolean false optional, Allow driver to bypass schema validation in MongoDB 3.2 or higher.
  ?collation:Dynamic, // object  null  optional, Specify collation (MongoDB 3.4 or higher) settings for update operation (see 3.4 documentation for available fields).
  ?session:ExternTODO // ClientSession   optional, optional session to use for this operation
}

typedef RawResult = String; // Of object: { ok:Int, n:Int, ?upserted:ExternTODO }
typedef WriteOpResult = {
  insertedCount:Int,             // Number   The total amount of documents inserted.
  ops:Array<Query>,              // Array.<object>  All the documents inserted using insertOne/insertMany/replaceOne. Documents contain the _id field if forceServerObjectId == false for insertOne/insertMany
  insertedIds:Dynamic,           // Object.<Number, ObjectId>  Map of the index of the inserted document to the id of the inserted document.
  connection:Dynamic,            //  object  The connection object used for the operation.
  result:RawResult,              //  object  The raw command result object returned from MongoDB (content might vary by server version).
}

typedef FindOptions = {
  ?limit:Int,                 // number 0 optional Sets the limit of documents returned in the query.
  ?sort:ExternTODO,           // array | object null optional Set to sort the documents coming back from the query. Array of indexes, [['a', 1]] etc.
  ?projection:ExternTODO,     // object null optional The fields to return in the query. Object of fields to include or exclude (not both), {'a':1}
  ?fields:ExternTODO,         // object null optional Deprecated Use options.projection instead
  ?skip:Int,                  // number 0 optional Set to skip N documents ahead in your query (useful for pagination).
  ?hint:ExternTODO,           // Object null optional Tell the query to use specific indexes in the query. Object of indexes to use, {'_id':1}
  ?explain:Bool,              // boolean false optional Explain the query instead of returning the data.
  ?snapshot:Bool,             // boolean false optional Snapshot query.
  ?timeout:Bool,              // boolean false optional Specify if the cursor can timeout.
  ?tailable:Bool,             // boolean false optional Specify if the cursor is tailable.
  ?batchSize:Int,             // number 0 optional Set the batchSize for the getMoreCommand when iterating over the query results.
  ?returnKey:Bool,            // boolean false optional Only return the index key.
  ?maxScan:Int,               // number null optional Limit the number of items to scan.
  ?min:Int,                   // number null optional Set index bounds.
  ?max:Int,                   // number null optional Set index bounds.
  ?showDiskLoc:Bool,          // boolean false optional Show disk location of results.
  ?comment:String,            // string null optional You can put a $comment field on a query to make looking in the profiler logs simpler.
  ?raw:Bool,                  // boolean false optional Return document results as raw BSON buffers.
  ?promoteLongs:Bool,         // boolean true optional Promotes Long values to number if they fit inside the 53 bits resolution.
  ?promoteValues:Bool,        // boolean true optional Promotes BSON values to native types where possible, set to false to only receive wrapper types.
  ?promoteBuffers:Bool,       // boolean false optional Promotes Binary BSON values to native Node Buffers.
  ?readPreference:ExternTODO, // ReadPreference | string null optional The preferred read preference (ReadPreference.PRIMARY, ReadPreference.PRIMARY_PREFERRED, ReadPreference.SECONDARY, ReadPreference.SECONDARY_PREFERRED, ReadPreference.NEAREST).
  ?partial:Bool,              // boolean false optional Specify if the cursor should return partial results when querying against a sharded system
  ?maxTimeMS:Int,             // number null optional Number of miliseconds to wait before aborting the query.
  ?collation:ExternTODO       // object null optional Specify collation (MongoDB 3.4 or higher) settings for update operation (see 3.4 documentation for available fields).
}


// http://mongodb.github.io/node-mongodb-native/3.0/api/Collection.html
extern class Collection
{
  function count(query:Query=null, options:CountOptions=null, callback:MongoError->Int->Void=null):Promise<Int>;
  function insert(docs:EitherType<Document,Array<Document>>, options:ExternTODO=null, callback:MongoError->WriteOpResult->Void=null):Promise<WriteOpResult>;
  function ensureIndex(fieldOrSpec:{}, options:ExternTODO=null, callback:MongoError->ExternTODO->Void=null):Promise<ExternTODO>;
  function update(selector:Query, document:Document, options:UpdateOptions=null, callback:MongoError->RawResult->Void=null):Promise<WriteOpResult>;
  function findOne(query:Query=null, options:ExternTODO=null, callback:MongoError->Document->Void=null):Promise<Document>;
  function find(query:Query=null, options:FindOptions=null):Cursor;
  function drop(options:ExternTODO=null, Callback:ExternTODO->Void=null):Promise<ExternTODO>;
  function deleteMany(query:Query, options:ExternTODO=null, callback:MongoError->Int->Void=null):Promise<ExternTODO>;

// function aggregate
// function bulkWrite
// function count
// function createIndex
// function createIndexes
// function deleteMany
// function deleteOne
// function distinct
// function drop
// function dropAllIndexes
// function dropIndex
// function dropIndexes
// function ensureIndex
// function find
// function findAndModify
// function findAndRemove
// function findOne
// function findOneAndDelete
// function findOneAndReplace
// function findOneAndUpdate
// function geoHaystackSearch
// function group
// function indexes
// function indexExists
// function indexInformation
// function initializeOrderedBulkOp
// function initializeUnorderedBulkOp
// function insert
// function insertMany
// function insertOne
// function isCapped
// function listIndexes
// function mapReduce
// function options
// function parallelCollectionScan
// function reIndex
// function remove
// function rename
// function replaceOne
// function save
// function stats
// function update
// function updateMany
// function updateOne
// function watch
}

// http://mongodb.github.io/node-mongodb-native/3.0/api/Cursor.html
extern class Cursor {
  public var sortValue:String;          // string Cursor query sort setting.
  public var timeout:Bool;              // boolean Is Cursor able to time out.
  public var readPreference:ExternTODO; // ReadPreference Get cursor ReadPreference.

  // Lots of functions TODO

  // Note that hasNext is oddly asynchronous, so I've left it out...

  // Returns null when finished
  public function next(callback:MongoError->Document->Void):Promise<Document>;

  public function toArray(callback:MongoError->Array<Document>->Void):Promise<Array<Document>>;

  // For testing / profiling of queries
  public function explain(callback:MongoError->Document->Void=null):Void;
}
