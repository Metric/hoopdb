hoopdb
===============================
A noSQL database for mobile devices. I was looking for one that fit my needs, and couldn't find any. 

I looked at Couchbase Lite, but it didn't make sense why they required views to do any sort of query.
Basically, I was wanting something similar to mongoDB where you could query any field or even an in query with json.

Thus, hoopdb was born! It uses sqlite as the underlying database, because most mobile devices support it. 
So, think of hoopdb like a wrapper of sorts for it, but with no queries involved and document based.

The first version is the iOS version. There will also be an Android version eventually.


iOS Version Features
=================================
*Full object support for all primitive types.
*NSArray and NSDictionary support.
*NSDate (ISO8601) and NSData (Converted to base64 automagically) support.
*Automatic document referencing for sub objects based on the HDocument class.
*Document versioning support
*Simple load (Requires _id to be set) and save of objects.
*Turn any HDocument object to a json string.
*Does not currently support NSValue objects. Maybe in future releases.
*Full ARC support and iOS 7 32bit and 64bit support.

Getting Started
=================================
Drag the hoopdb folder into your Xcode project. However, make sure to set the option: Make Folders into Groups when copying.

Next go into your project settings > build phases and set the MARTNSObject.m with the following flag to disable ARC on it: -fno-objc-arc

Finally, link the sqlite3.dylib to your project.

That's it you can now build!


Creating your first hoopdb
=================================
hoopdb is pretty straight forward to use, but here is guidance on getting your first db up and running!

Create a new class we will call it TestDocument for now.

			#import <Foundation/Foundation.h>
			#import "hoopdb/hoopdb.h"

			@interface TestDocument : HDocument
			@property (nonatomic, strong) NSString *something;
			@property (nonatomic, strong) TestDocument *doc;
			@property (nonatomic, strong) NSMutableArray *stuff;
			@property (nonatomic) int someValue;
			@end
			
Now let us open the database up and create a new object to store in it! This should be put somewhere after the app has loaded of course!

			//Opening the DB, if it doesn't exist it is created
			//All DB files can be found in the Users Documents folder for you app
			if([hoopdb open:@"testDB"]) {
	
				//Now lets register our TestDocument document model for its collection
				//This will create the collection if it doesn't exist, or updates it if any new properties are added.
				//It returns a HoopQuery object ready to do any queries on the collection!
				HoopQuery *testQuery = [hoopdb registerDocumentModel:[TestDocument class]];
	
				//Whenever a HDocument is created it already has an id assigned to it
				TestDocument *doc = [[TestDocument alloc] init];
			
				//Let us set some stuff up on it now!
				doc.something = @"Testing";
				doc.someValue = 43;
				doc.stuff = [NSMutableArray arrayWithObjects: @"One", [NSNumber numberWithInt: 2], @"Three", nil];
			
				//Right then let us save!
				if([doc save]) {
					NSLog(@"Document Successfully Saved!");
				}
				else {
					NSLog(@"Oops something went wrong!");
				}
			}
			else {
				NSLog(@"Failed to open DB. Storage is most likely full or not enough memory available!");
			}

That is all it takes to create an object and save it!
Now let us load that document back from the database with a simple query.

			//This is assumming you still have your collection's HoopQuery available
			TestDocumet *returnedDoc = (TestDocument *)[[[testQuery where:@"something"] equals: @"Testing"] findOne:nil];
			
			if(doc) {
				NSLog(@"Found Document!");
				
				//Let us verify it is the document we were expecting
				NSLog(@"Documet someValue: %d", returnedDoc.someValue);
				//This should spit out 43 in the console.
			}
			else {
				NSLog(@"No document found!");
			}
			
What if I already have the documents id? Well then it is even simpler to load the document back from the DB!

			TestDocument *returnedDoc = [[TestDocument alloc] init];
			//Sets its _id to the one we have (We assume we have a NSString called myId);
			returnedDoc._id = myId;
			if([returnedDoc load]) {
				NSLog(@"Document loaded successfully!");
			}
			else {
				NSLog(@"Failed to load document. You might want to check your _id!");
			}
			
Can I create a new HoopQuery object? Sure can! This is actually the recommended way of doing it if in a different thread!

			HoopQuery *query = [HoopQuery withCollection: [TestDocument class]];
			
Before your application exits be sure to close the database! Yes, it will close it for you, but you should always do it to be on the safe side!
			[hoopdb close];
			
What Not TODO!
===============================
Never ever create a circular sub document reference! This is bad and you will get a EXEC BAD ACCESS aka StackOverflow when trying to load the document back!

This is how it should be: Object A -> Object B -> Object C

These are circular references!
This is NOT OKAY: Object A -> Object B -> Object A -> Object C
This is also NOT OKAY: Object A -> Object B -> Object C -> Object A

Chain-able Queries
=================================
		where: (NSString *) field
		whereOr: (NSString *) field //This creates an Or where statement
		equals: (id) data //anything that has an id type can accept: strings, dictionaries, nsnumber, arrays, nsdate, and nsdata
		lte: (id) data
		gte: (id) data
		lt: (id) data
		gt: (id) data
		like: (id) data //This is recommended if you wish to search a field that is an array or dictionary for a value, or just a field with text in general!
		notEqual: (id) data
		inArray: (id) data //If passed just a string then it will default to a like statement to search for the value, if an array it actually loads the document and compares the where field value against the items in the array.
		
		//Non Where or Equal Base Chainables
		take: (int) count
		skip: (int) count
		
		//This can accept a json string or nsdictionary
		//Basically it is field:sort type. (Sort type can be: -1, 1, desc, asc)
		sort: (id) data
		
Basically the above should go something like: where -> equals statement of some sort (This includes any of the above) -> where -> equals statement and so on.

Non-Chain-able Queries
=================================
		//This can accept a json string or nsdictionary. Every key:value is an AND where statement.
		//If passed nil, then it is expected to be the last item on the Where Chain to actually return your result.
		(HDocument *) findOne: (id) data
		(NSArray *) find: (id) data //Same as above but returns all results found
		(BOOL) remove: (id) data //Same as above, except it doesn't return results. It removes the documents instead!
		
		//This is expected to be on the end of a where chain.
		//The json or dictionary are the fields and values that it should update the documents too.
		(BOOL) update: (id) data 
		
		//Same as find and findOne but returns the count for the matching number of documents.
		//This is recommended for getting the total number of documents. 
		//It is faster since it performs an underlying sqlite COUNT(*)
		(int) count: (id) json 
		