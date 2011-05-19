//
//  Album.m
//  PhotoFeed
//
//  Created by Peter Shih on 5/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Album.h"
#import "Photo.h"


@implementation Album
@dynamic fromId;
@dynamic location;
@dynamic fromName;
@dynamic id;
@dynamic count;
@dynamic coverPhoto;
@dynamic type;
@dynamic timestamp;
@dynamic name;
@dynamic caption;
@dynamic imageData;
@dynamic photos;

- (void)addPhotosObject:(Photo *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"photos" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"photos"] addObject:value];
    [self didChangeValueForKey:@"photos" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removePhotosObject:(Photo *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"photos" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"photos"] removeObject:value];
    [self didChangeValueForKey:@"photos" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addPhotos:(NSSet *)value {    
    [self willChangeValueForKey:@"photos" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"photos"] unionSet:value];
    [self didChangeValueForKey:@"photos" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removePhotos:(NSSet *)value {
    [self willChangeValueForKey:@"photos" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"photos"] minusSet:value];
    [self didChangeValueForKey:@"photos" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
