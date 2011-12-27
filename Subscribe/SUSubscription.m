//
//  SUSubscription.m
//  Subscribe
//
//  Created by Ben Ubois on 12/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SUSubscription.h"

@implementation SUSubscription

@synthesize title;

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"New Subscription";
    }
}

@end
