//
//  NSString+ValidSize.m
//  Image Fun
//
//  Created by Victor Gafiatulin on 14/11/13.
//  Copyright (c) 2013 Victor Gafiatulin. All rights reserved.
//

#import "NSString+ValidSize.h"

@implementation NSString (ValidSize)
-(BOOL)isValidSize
{
    @autoreleasepool
    {
        BOOL val = NO;
        NSCharacterSet *NumericOnly = [NSCharacterSet decimalDigitCharacterSet];
        NSCharacterSet *myStringSet = [NSCharacterSet characterSetWithCharactersInString:self];
        if ([NumericOnly isSupersetOfSet: myStringSet] & ![self isEqualToString:@""])
            val = YES;
        return val;
    }
}

@end
