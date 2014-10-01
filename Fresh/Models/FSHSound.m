//
//  FSHSound.m
//  Fresh
//
//  Created by Brandon on 2014-03-09.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHSound.h"

#import <Mantle/MTLValueTransformer.h>
#import <Mantle/NSValueTransformer+MTLPredefinedTransformerAdditions.h>
#import "SCRequest.h"
#import "SCAccount.h"
#import "SCSoundCloud.h"
#import "NXOAuth2.h"
#import <ReactiveCocoa/RACSignal+Operations.h>
#import <ReactiveCocoa/RACSubscriber.h>
#import <ReactiveCocoa/RACDisposable.h>
#import <AFNetworking/AFHTTPRequestOperation.h>

@implementation FSHSound

- (RACSignal *)fetchPlayURL {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (self.playURL) {
            [subscriber sendNext:self.playURL];
            [subscriber sendCompleted];
            return nil;
        }

        [self getStreamURL:^(NSURL *streamURL, NSError *error) {
            self.playURL = streamURL;
            [subscriber sendNext:streamURL];
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (void)getStreamURL:(FSHSoundStreamURLBlock)streamURLBlock {
    if (!self.streamURL) return;

    NXOAuth2Request *request = [[NXOAuth2Request alloc] initWithResource:self.streamURL method:@"GET" parameters:nil];
    request.account = [SCSoundCloud account].oauthAccount;
    [request performRequestWithSendingProgressHandler:nil responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSURL *streamURL = [NSURL URLWithString:[((NSHTTPURLResponse *)response) allHeaderFields][@"Location"]];
        if (streamURLBlock) streamURLBlock(streamURL, error);
    }];
}

- (RACSignal *)fetchWaveformImage {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (!self.waveformURL) {
            [subscriber sendCompleted];
            return nil;
        }

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.waveformURL];
        [request setHTTPShouldHandleCookies:NO];
        [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];

        AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSImage *image = [[NSImage alloc] initWithData:responseObject];
            [subscriber sendNext:image];
            [subscriber sendCompleted];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [subscriber sendError:error];
            [subscriber sendCompleted];
        }];

        [[[self class] requestOperationQueue] addOperation:requestOperation];

        return nil;
    }];
}

+ (NSOperationQueue *)requestOperationQueue {
    static NSOperationQueue *requestOperationQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        requestOperationQueue = [[NSOperationQueue alloc] init];
        [requestOperationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    });

    return requestOperationQueue;
}

- (void)toggleFavorite {
    self.favorite = !self.favorite;

    NSString *method = @"PUT";
    if (!self.favorite) {
        method = @"DELETE";
    }
    NSURL *resource = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.soundcloud.com/me/favorites/%@", self.trackID]];
    NXOAuth2Request *request = [[NXOAuth2Request alloc] initWithResource:resource method:method parameters:nil];
    request.account = [SCSoundCloud account].oauthAccount;
    [request performRequestWithSendingProgressHandler:nil responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
            NSLog(@"Error favoriting track: %@, favorite: %d", error, self.favorite);
            self.favorite = !self.favorite;
        }
    }];
}

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
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^id(NSString *string) {
        return @([string floatValue]);
    } reverseBlock:^id(NSNumber *number) {
        return [number stringValue];
    }];
}

+ (NSValueTransformer *)createdAtJSONTransformer {
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str) {
        return [[self dateFormatter] dateFromString:str];
    } reverseBlock:^(NSDate *date) {
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

@end
