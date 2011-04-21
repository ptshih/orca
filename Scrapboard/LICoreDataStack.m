//
//  LICoreDataStack.m
//  Scrapboard
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import "LICoreDataStack.h"

static NSPersistentStoreCoordinator *_persistentStoreCoordinator = nil;
static NSManagedObjectModel *_managedObjectModel = nil;
static NSManagedObjectContext *_managedObjectContext = nil;

static NSThread *_mocThread = nil;

@interface LICoreDataStack (Private)

+ (void)resetStoreState;
+ (NSString *)applicationDocumentsDirectory;

@end

@implementation LICoreDataStack

+ (void)initialize {
  if (self == [LICoreDataStack class]) {
    // Allocs for class (statics)
    _mocThread = [[NSThread alloc] initWithTarget:[self class] selector:@selector(cdThreadMain) object:nil];
    [_mocThread start];
  }
}

#pragma mark -
#pragma mark Thread
+ (void)cdThreadMain {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  //  NSLog(@"op thread main started on thread: %@", [NSThread currentThread]);
  [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
  [[NSRunLoop currentRunLoop] run];
  [pool release];
}

#pragma mark Initialization Methods
+ (void)resetPersistentStore {
  [[self class] deleteAllObjects:@"Event"];
  [[self class] deleteAllObjects:@"Kupo"];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:kCoreDataDidReset object:nil];
  
//  NSLog(@"reset persistent store and context");
//  [self resetStoreState];
//  [self resetManagedObjectContext];
}

+ (void)deleteAllObjects:(NSString *)entityDescription {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:[[self class] sharedManagedObjectContext]];
  [fetchRequest setEntity:entity];
  
  NSError *error;
  NSArray *items = [[[self class] sharedManagedObjectContext] executeFetchRequest:fetchRequest error:&error];
  [fetchRequest release];
  
  
  for (NSManagedObject *managedObject in items) {
    [[[self class] sharedManagedObjectContext] deleteObject:managedObject];
  }
  if (![[[self class] sharedManagedObjectContext] save:&error]) {
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
  if (_managedObjectContext) {
    [_managedObjectContext release];
    _managedObjectContext = nil;
  }
  
  NSPersistentStoreCoordinator *coordinator = [[self class] persistentStoreCoordinator];
  NSManagedObjectContext *managedObjectContext = nil;
  if (coordinator != nil) {
    managedObjectContext = [[NSManagedObjectContext alloc] init];
    [managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  
  _managedObjectContext = managedObjectContext;
}

#pragma mark Core Data Accessors
// shared static context
+ (NSManagedObjectContext *)sharedManagedObjectContext {
  if (_managedObjectContext != nil) {
    return _managedObjectContext;
  }
  
  // Use moc thread
//  [[self class] performSelector:@selector(initSharedManagedObjectContextInMocThread) onThread:_mocThread withObject:nil waitUntilDone:YES];
  
  // Use main thread
  NSPersistentStoreCoordinator *coordinator = [[self class] persistentStoreCoordinator];
  if (coordinator != nil) {
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
  
  return _managedObjectContext;
}

+ (void)initSharedManagedObjectContextInMocThread {
  NSPersistentStoreCoordinator *coordinator = [[self class] persistentStoreCoordinator];
  if (coordinator != nil) {
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
}

// returns a new retained context
+ (NSManagedObjectContext *)newManagedObjectContext {
  // Use moc thread
//  NSManagedObjectContext *context = nil;  
//  [[self class] performSelector:@selector(initManagedObjectContextInMocThread:) onThread:_mocThread withObject:context waitUntilDone:YES];
  
  // Use main thread
  NSPersistentStoreCoordinator *coordinator = [[self class] persistentStoreCoordinator];
  NSManagedObjectContext *context = nil;
  if (coordinator != nil) {
    context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:coordinator];
  }
  
  return context;
}

//+ (void)initManagedObjectContextInMocThread:(NSManagedObjectContext *)context {
//  NSPersistentStoreCoordinator *coordinator = [[self class] persistentStoreCoordinator];
//  if (coordinator != nil) {
//    context = [[NSManagedObjectContext alloc] init];
//    [context setPersistentStoreCoordinator:coordinator];
//  }
//}

+ (NSManagedObjectModel *)managedObjectModel {
  
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  
  NSString *path = [[NSBundle mainBundle] pathForResource:@"Scrapboard" ofType:@"momd"];
  NSURL *momURL = [NSURL fileURLWithPath:path];
  _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
  
  return _managedObjectModel;
}

+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
  if(_persistentStoreCoordinator != nil) {
    return _persistentStoreCoordinator;
  }
  
  // Create a new persistent store
  _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[[self class] managedObjectModel]];
  
  NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
  
  NSURL *storeURL = [NSURL fileURLWithPath:[[[self class] applicationDocumentsDirectory] stringByAppendingPathComponent:@"Scrapboard.sqlite"]];
  
  NSError *error = nil;
  
  if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
    // Handle the error.
    NSLog(@"failed to create persistent store");
    abort(); // NOTE: DON'T SHIP THIS
  } else {
    NSLog(@"init persistent store with path: %@", storeURL);
  }
  
  return _persistentStoreCoordinator;
}

#pragma mark Convenience Methods
+ (NSString *)applicationDocumentsDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
