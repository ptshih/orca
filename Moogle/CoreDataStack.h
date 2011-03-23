//
//  CoreDataStack.h
//  Moogle
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDataStack : NSObject {

}

+ (NSManagedObjectModel *)managedObjectModel;
+ (NSManagedObjectContext *)managedObjectContext;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

+ (void)resetPersistentStore;
+ (void)resetManagedObjectContext;


@end
