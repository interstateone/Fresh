//
//  FSHSound.m
//  Fresh
//
//  Created by Brandon on 2014-03-09.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHSound.h"

@import ReactiveCocoa;
#import "Fresh-Swift.h"
#import "SCRequest.h"
#import "SCAccount.h"
#import "SCSoundCloud.h"
#import "NXOAuth2.h"
#import <AFNetworking/AFHTTPRequestOperation.h>

@implementation FSHSound

#pragma mark - Mantle

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss Z"];
    });
    return dateFormatter;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"trackID" : @"origin.id",
        @"title" : @"origin.title",
        @"author" : @"origin.user.username",
        @"streamURL" : @"origin.stream_url",
        @"streamable" : @"origin.streamable",
        @"duration" : @"origin.duration",
        @"createdAt" : @"created_at",
        @"artworkURL" : @"origin.artwork_url",
        @"waveformURL" : @"origin.waveform_url",
        @"permalinkURL" : @"origin.permalink_url",
        @"favorite" : @"origin.user_favorite"
    };
}

+ (NSValueTransformer *)streamURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)durationJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *string, BOOL *success, NSError *__autoreleasing *error) {
        return @([string floatValue]);
    } reverseBlock:^id(NSNumber *number, BOOL *success, NSError *__autoreleasing *error) {
        return [number stringValue];
    }];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *str, BOOL *success, NSError *__autoreleasing *error) {
        return [[self dateFormatter] dateFromString:str];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        return [[self dateFormatter] stringFromDate:date];
    }];
}

+ (NSValueTransformer *)artworkURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)waveformURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)permalinkURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)favoriteJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSNumber *boolean, BOOL *success, NSError *__autoreleasing *error) {
        if ([boolean isKindOfClass:[NSNumber class]]) {
            return @(boolean.boolValue);
        }
        return @NO;
    }];
}

@end
