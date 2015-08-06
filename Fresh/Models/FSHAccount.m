//
//  FSHAccount 
//  Fresh
//
//  Created by brandon on 2014-03-12.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "FSHAccount.h"

#import <ReactiveCocoa/RACSignal.h>
#import <ReactiveCocoa/RACSubscriptingAssignmentTrampoline.h>
#import <ReactiveCocoa/NSObject+RACPropertySubscribing.h>
#import <ReactiveCocoa/RACSubscriber.h>
#import <RXCollections/RXCollection.h>
#import "STKAudioPlayer.h"
#import "SCRequest.h"
#import "SCAccount.h"
#import "SCSoundCloud.h"

#import "FSHSound.h"

@interface FSHAccount ()

@property (strong, nonatomic) SCAccount *soundcloudAccount;
@property (strong, nonatomic) NSURL *nextSoundsURL;

@end

@implementation FSHAccount

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserverForName:@"FSHSoundCloudUserDidAuthenticate" object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
            [FSHAccount currentAccount].soundcloudAccount = [SCSoundCloud account];
        }];
    }
    return self;
}

+ (instancetype)currentAccount {
    static FSHAccount *account;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        account = [[FSHAccount alloc] init];
        account.soundcloudAccount = [SCSoundCloud account];
    });
    return account;
}

- (BOOL)isLoggedIn {
    return (BOOL)self.soundcloudAccount;
}

- (void)logIn {
    [SCSoundCloud requestAccessWithPreparedAuthorizationURLHandler:^(NSURL *preparedURL) {
        [[NSWorkspace sharedWorkspace] openURL:preparedURL];
    }];
}

- (RACSignal *)updateSounds {
    return [RACSignal createSignal:^RACDisposable *(id <RACSubscriber> subscriber) {
        [SCRequest performMethod:SCRequestMethodGET onResource:[NSURL URLWithString:@"https://api.soundcloud.com/me/activities.json"] usingParameters:nil withAccount:self.soundcloudAccount sendingProgressHandler:nil responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (error) {
                [subscriber sendError:error];
                [subscriber sendCompleted];
            } else {
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];

                self.sounds = [[jsonResponse[@"collection"] rx_filterWithBlock:^BOOL(NSDictionary *soundInfo) {
                    BOOL streamable = [soundInfo[@"origin"][@"streamable"] isEqualToNumber:@1];
                    BOOL isTrack = [soundInfo[@"origin"][@"kind"] isEqualToString:@"track"];
                    return streamable && isTrack;
                }] rx_mapWithBlock:^id(NSDictionary *soundInfo) {
                    NSError *soundDeserializationError;
                    FSHSound *sound = [MTLJSONAdapter modelOfClass:[FSHSound class] fromJSONDictionary:soundInfo error:&soundDeserializationError];
                    if (soundDeserializationError) {
                        NSLog(@"Error deserializing FSHSound: %@", soundDeserializationError);
                    }
                    return sound;
                }];

                self.nextSoundsURL = [NSURL URLWithString:jsonResponse[@"next_href"]];

                [subscriber sendNext:self.sounds];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

- (RACSignal *)fetchNextSounds {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [SCRequest performMethod:SCRequestMethodGET onResource:self.nextSoundsURL usingParameters:nil withAccount:self.soundcloudAccount sendingProgressHandler:nil responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (error) {
                [subscriber sendError:error];
                [subscriber sendCompleted];
            } else {
                NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];

                self.sounds = [self.sounds arrayByAddingObjectsFromArray:[[jsonResponse[@"collection"] rx_filterWithBlock:^BOOL(NSDictionary *soundInfo) {
                    BOOL streamable = [soundInfo[@"origin"][@"streamable"] isEqualToNumber:@1];
                    BOOL isTrack = [soundInfo[@"origin"][@"kind"] isEqualToString:@"track"];
                    return streamable && isTrack;
                }] rx_mapWithBlock:^id(NSDictionary *soundInfo) {
                    NSError *soundDeserializationError;
                    FSHSound *sound = [MTLJSONAdapter modelOfClass:[FSHSound class] fromJSONDictionary:soundInfo error:&soundDeserializationError];
                    if (soundDeserializationError) {
                        NSLog(@"Error deserializing FSHSound: %@", soundDeserializationError);
                    }
                    return sound;
                }]];

                self.nextSoundsURL = [NSURL URLWithString:jsonResponse[@"next_href"]];

                [subscriber sendNext:self.sounds];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

@end
