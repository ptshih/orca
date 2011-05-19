//
//  LICoreDataStack.h
//  PhotoFeed
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Constants.h"

@interface LICoreDataStack : NSObject {

}

+ (NSManagedObjectContext *)newManagedObjectContext; // returns retained context
+ (NSManagedObjectContext *)sharedManagedObjectContext; // shared static context
+ (NSManagedObjectModel *)managedObjectModel;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

+ (void)resetPersistentStore;
+ (void)resetManagedObjectContext;
//+ (void)initManagedObjectContextInMocThread:(NSManagedObjectContext *)context;
+ (void)initSharedManagedObjectContextInMocThread;
+ (void)deleteAllObjects:(NSString *)entityDescription;
+ (void)saveSharedContextIfNeeded;

@end
