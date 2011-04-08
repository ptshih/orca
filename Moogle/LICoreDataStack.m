//
//  LICoreDataStack.m
//  Moogle
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
  [[self class] deleteAllObjects:@"Place"];
  [[self class] deleteAllObjects:@"Kupo"];
  
  [[NSNotificationCenter defaultCenter] postNotificationName:kCoreDataDidReset object:nil];
  
//  NSLog(@"reset persistent store and context");
//  [self resetStoreState];
//  [self resetManagedObjectContext];
}

+ (void)deleteAllObjects:(NSString *)entityDescription {
  NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
  NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:[[self class] managedObjectContext]];
  [fetchRequest setEntity:entity];
  
  NSError *error;
  NSArray *items = [[[self class] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
  [fetchRequest release];
  
  
  for (NSManagedObject *managedObject in items) {
    [[[self class] managedObjectContext] deleteObject:managedObject];
  }
  if (![[[self class] managedObjectContext] save:&error]) {
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
+ (NSManagedObjectContext *)managedObjectContext {
  if (_managedObjectContext != nil) {
    return _managedObjectContext;
  }
  
  [[self class] performSelector:@selector(initManagedObjectContextInMocThread) onThread:_mocThread withObject:nil waitUntilDone:YES];
  
//  NSPersistentStoreCoordinator *coordinator = [[self class] persistentStoreCoordinator];
//  if (coordinator != nil) {
//    _managedObjectContext = [[NSManagedObjectContext alloc] init];
//    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//  }
  
  return _managedObjectContext;
}

+ (void)initManagedObjectContextInMocThread {
  NSPersistentStoreCoordinator *coordinator = [[self class] persistentStoreCoordinator];
  if (coordinator != nil) {
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
  }
}

+ (NSManagedObjectModel *)managedObjectModel {
  
  if (_managedObjectModel != nil) {
    return _managedObjectModel;
  }
  
  NSString *path = [[NSBundle mainBundle] pathForResource:@"Moogle" ofType:@"momd"];
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
  
  NSURL *storeURL = [NSURL fileURLWithPath:[[[self class] applicationDocumentsDirectory] stringByAppendingPathComponent:@"Moogle.sqlite"]];
  
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
