//
//  myImageObject.m
//  Image Fun
//
//  Created by Victor Gafiatulin on 12/11/13.
//  Copyright (c) 2013 Victor Gafiatulin. All rights reserved.
//

#import "myImageObject.h"

@implementation myImageObject

@synthesize path;
@synthesize version;

- (NSString *)imageRepresentationType{return IKImageBrowserPathRepresentationType;}
- (id)imageRepresentation{return path;}
- (NSString *)imageUID{return path;}
- (NSUInteger) imageVersion{return version;}

@end
