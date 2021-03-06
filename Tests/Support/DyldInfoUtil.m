//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             DyldInfoUtil.m
//|
//|             D.V.
//|             Copyright (c) 2014-2015 D.V. All rights reserved.
//|
//| Permission is hereby granted, free of charge, to any person obtaining a
//| copy of this software and associated documentation files (the "Software"),
//| to deal in the Software without restriction, including without limitation
//| the rights to use, copy, modify, merge, publish, distribute, sublicense,
//| and/or sell copies of the Software, and to permit persons to whom the
//| Software is furnished to do so, subject to the following conditions:
//|
//| The above copyright notice and this permission notice shall be included
//| in all copies or substantial portions of the Software.
//|
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//| OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------------//

#import "DyldInfoUtil.h"

//----------------------------------------------------------------------------//
@implementation DyldInfoUtil

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseDylibs:(NSString*)input
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        if ([line rangeOfString:@"/"].location == NSNotFound) {
            if (result.count > 0) break;
            else continue;
        }
        
        NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSString* evaluatedObject, __unused id bindings) {
            return (BOOL)([evaluatedObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
        }]];
        
        if (components.count > 1)
            [result addObject:@{
                @"name": components[1],
                @"attributes": components[0]
            }];
        else
            [result addObject:@{
                @"name": components[0]
            }];
    }
    
    return result;
}

//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseRebaseCommands:(NSString*)input
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        if ([line rangeOfString:@"REBASE_"].location != NSNotFound)
            [result addObject:line];
    }
    
    return result;
}


//|++++++++++++++++++++++++++++++++++++|//
+ (NSArray*)parseFixups:(NSString*)input
{
    NSMutableArray *result = [NSMutableArray array];
    NSArray *lines = [input componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    for (NSString *line in lines) {
        NSArray *components = [line componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (components.count < 1 || [components[0] rangeOfString:@"__"].location != 0)
            continue;
        
        components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^(NSString* evaluatedObject, __unused id bindings) {
            return (BOOL)([evaluatedObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0);
        }]];
        
        [result addObject:@{
            @"segment": components[0],
            @"section": components[1],
            @"address": components[2],
            @"type": [[components subarrayWithRange:NSMakeRange(3, components.count - 3)] componentsJoinedByString:@" "]
        }];
    }
    
    return result;
}
@end
