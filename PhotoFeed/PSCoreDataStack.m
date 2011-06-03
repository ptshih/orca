//
//  PSCoreDataStack.m
//  PhotoFeed
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import "PSCoreDataStack.h"

static NSPersistentStoreCoordinator *_persistentStoreCoordinator = nil;
static NSManagedObjectModel *_managedObjectModel = nil;
static NSManagedObjectContext *_mainThreadContext = nil;

static NSDictionary *_storeOptions = nil;
static NSURL *_storeURL = nil;

@interface PSCoreDataStack (Private)

+ (void)resetStoreState;
+ (NSString *)applicationDocumentsDirectory;

@end

@implementation PSCoreDataStack

#pragma mark Initialization Methods
+ (void)initialize {  
  _storeOptions = [[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil] retain];
  
  if (![[NSUserDefaults standardUserDefaults] objectForKey:@"persistentStoreName"]) {
    [[self class] generateNewPersistentStoreName];
  }
  _storeURL = [[NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] stringForKey:@"persistentStoreName"]]] retain];
}

+ (void)resetPersistentStore {
  [[self class] deleteAllObjects:@"Album"];
  [[self class] deleteAllObjects:@"Photo"];
  [[self class] deleteAllObjects:@"Comment"];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:kCoreDataDidReset object:nil];
  
  //  NSLog(@"reset persistent store and context");
  //  [self resetStoreState];
  //  [self resetManagedObjectContext];
}

+ (void)deleteAllObjects:(NSString *)entityDescription {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:[[self class] mainThreadContext]];
  [fetchRequest setEntity:entity];
  
  NSError *error;
  NSArray *items = [[[self class] mainThreadContext] executeFetchRequest:fetchRequest error:&error];
  [fetchRequest release];
  
  
  for (NSManagedObject *managedObject in items) {
    [[[self class] mainThreadContext] deleteObject:managedObject];
  }
  if (![[[self class] mainThreadContext] save:&error]) {
  }
}

+ (void)resetStoreState {
  NSArray *stores = [_persistentStoreCoordinator persistentStores];
  
  for(NSPersistentStore *store in stores) {
    [_persistentStoreCoordinator removePersistentStore:store error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
  }
  
  [_managedObjectModel release];
  [_persistentStoreCoordinator release];
  _managedObjectModel = nil;
  _persistentStoreCoordinator = nil;
}

+ (void)resetManagedObjectContext {
  if (_mainThreadContext) {
    [_mainThreadContext release];
    _mainThreadContext = nil;
  }
  
  NSPersistentStoreCoordinator *coordinator = [[self class] persistentStoreCoordinator];
  NSManagedObjectContext *managedObjectContext = nil;
  if (coordinator != nil) {
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  
  _mainThreadContext = managedObjectContext;
}

#pragma mark Core Data Accessors
// shared static context
+ (NSManagedObjectContext *)mainThreadContext {
  NSAssert([NSThread isMainThread], @"mainThreadContext must be called from the main thread");
  
  if (_mainThreadContext != nil) {
    return _mainThreadContext;
  }
  
  // Use main thread
  NSPersistentStoreCoordinator *coordinator = [[self class] persistentStoreCoordinator];
  if (coordinator != nil) {
    _mainThreadContext = [[NSManagedObjectContext alloc] init];
    [_mainThreadContext setPersistentStoreCoordinator:coordinator];
  }
  
  return _mainThreadContext;
}

// returns a new retained context
+ (NSManagedObjectContext *)newManagedObjectContext {
  // Called on requesting thread
  
  NSPersistentStoreCoordinator *coordinator = [[self class] persistentStoreCoordinator];
  NSManagedObjectContext *context = nil;
  if (coordinator != nil) {
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coordinator];
  }
  
  // not autoreleased
  return context;
}

#pragma mark Save
+ (void)saveMainThreadContext {
  NSError *error = nil;
  if ([_mainThreadContext hasChanges]) {
    if (![_mainThreadContext save:&error]) {
      abort(); // NOTE: DO NOT SHIP
    }
  }
}

+ (void)saveInContext:(NSManagedObjectContext *)context {
  NSError *error = nil;
  if ([context hasChanges]) {
    if (![context save:&error]) {
      abort(); // NOTE: DO NOT SHIP
    }
  }
}

+ (void)resetInContext:(NSManagedObjectContext *)context {
  [context reset];
}

#pragma mark Accessors
+ (NSManagedObjectModel *)managedObjectModel {
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  
  NSString *path = [[NSBundle mainBundle] pathForResource:@"PhotoFeed" ofType:@"momd"];
  NSURL *momURL = [NSURL fileURLWithPath:path];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
  
  return _managedObjectModel;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if(_persistentStoreCoordinator != nil) {
    return _persistentStoreCoordinator;
  }
  
  // Create a new persistent store
  if (![[self class] createPersistentStoreCoordinator]) {
    // Error creating store, reset and try again
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutRequested object:nil];
//    if (![[self class] createPersistentStoreCoordinator]) {
//      // Fatal error that we can't recover from
//      abort();
//    }
  }
  
  return _persistentStoreCoordinator;
}

+ (BOOL)createPersistentStoreCoordinator {
  [[self class] createDocumentDirectory];
  
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[self class] managedObjectModel]];
  
  NSError *error = nil;
  NSPersistentStore *newStore = [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:_storeURL options:_storeOptions error:&error];

  if (!newStore || error) {
    DLog(@"Failed to create persistent store: %@", [error userInfo]);
    return NO;
  } else {
    DLog(@"Init persistent store with path: %@", _storeURL);
    return YES;
  }
}

+ (void)resetPersistentStoreCoordinator {
  [_managedObjectModel release];
  [_persistentStoreCoordinator release];
  _managedObjectModel = nil;
  _persistentStoreCoordinator = nil;
  
  if (_storeURL) {
    [[NSFileManager defaultManager] removeItemAtURL:_storeURL error:nil];
  }
  
  [[self class] generateNewPersistentStoreName];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:kCoreDataDidReset object:nil];
}

+ (NSString *)generateNewPersistentStoreName {
  CFUUIDRef theUUID = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, theUUID);
  CFRelease(theUUID);
  NSString *uniqueString = (NSString *)string;
  
  NSString *newPersistentStoreName = [NSString stringWithFormat:@"%@.sqlite", uniqueString];
  CFRelease(uniqueString);
  
  // Save to UserDefaults
  [[NSUserDefaults standardUserDefaults] setValue:newPersistentStoreName forKey:@"persistentStoreName"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  // set storeURL
  if (_storeURL) [_storeURL autorelease];
  _storeURL = [[NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[[NSUserDefaults standardUserDefaults] stringForKey:@"persistentStoreName"]]] retain];
  
  return newPersistentStoreName;
}

+ (void)createDocumentDirectory {
  BOOL isDir;
  [[NSFileManager defaultManager] fileExistsAtPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] isDirectory:&isDir];
  if (!isDir) {
    [[NSFileManager defaultManager] createDirectoryAtPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] withIntermediateDirectories:YES attributes:nil error:nil];
  }
}

@end
