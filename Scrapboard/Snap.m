//
//  Snap.m
//  Scrapboard
//
//  Created by Peter Shih on 5/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Snap.h"
#import "Comment.h"
#import "Like.h"


@implementation Snap
@dynamic id;
@dynamic message;
@dynamic timestamp;
@dynamic type;
@dynamic userPictureUrl;
@dynamic userId;
@dynamic userName;
@dynamic lat;
@dynamic isLiked;
@dynamic albumId;
@dynamic lng;
@dynamic photoUrl;
@dynamic videoUrl;
@dynamic comments;
@dynamic likes;

- (void)addCommentsObject:(Comment *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"comments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"comments"] addObject:value];
    [self didChangeValueForKey:@"comments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeCommentsObject:(Comment *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"comments" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"comments"] removeObject:value];
    [self didChangeValueForKey:@"comments" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addComments:(NSSet *)value {    
    [self willChangeValueForKey:@"comments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"comments"] unionSet:value];
    [self didChangeValueForKey:@"comments" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeComments:(NSSet *)value {
    [self willChangeValueForKey:@"comments" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"comments"] minusSet:value];
    [self didChangeValueForKey:@"comments" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


- (void)addLikesObject:(Like *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"likes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"likes"] addObject:value];
    [self didChangeValueForKey:@"likes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeLikesObject:(Like *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"likes" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"likes"] removeObject:value];
    [self didChangeValueForKey:@"likes" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addLikes:(NSSet *)value {    
    [self willChangeValueForKey:@"likes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"likes"] unionSet:value];
    [self didChangeValueForKey:@"likes" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeLikes:(NSSet *)value {
    [self willChangeValueForKey:@"likes" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"likes"] minusSet:value];
    [self didChangeValueForKey:@"likes" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
