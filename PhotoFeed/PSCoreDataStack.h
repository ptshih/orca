//
//  PSCoreDataStack.h
//  PhotoFeed
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Constants.h"

@interface PSCoreDataStack : NSObject {

}

+ (NSManagedObjectModel *)managedObjectModel;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+ (NSManagedObjectContext *)newManagedObjectContext; // returns retained context
+ (NSManagedObjectContext *)mainThreadContext; // shared static context

+ (void)resetPersistentStore;
+ (void)resetManagedObjectContext;
+ (void)deleteAllObjects:(NSString *)entityDescription;
+ (void)saveMainThreadContext;
+ (void)saveInContext:(NSManagedObjectContext *)context;
+ (void)resetInContext:(NSManagedObjectContext *)context;

@end
