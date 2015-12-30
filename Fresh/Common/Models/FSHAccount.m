//
//  FSHAccount 
//  Fresh
//
//  Created by brandon on 2014-03-12.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

#import "FSHAccount.h"

@import ReactiveCocoa;
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

                self.sounds = [self createSoundsFromDictionaries:jsonResponse[@"collection"]];
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

                self.sounds = [self.sounds arrayByAddingObjectsFromArray:[self createSoundsFromDictionaries:jsonResponse[@"collection"]]];
                self.nextSoundsURL = [NSURL URLWithString:jsonResponse[@"next_href"]];

                [subscriber sendNext:self.sounds];
                [subscriber sendCompleted];
            }
        }];
        return nil;
    }];
}

- (NSArray<FSHSound *> *)createSoundsFromDictionaries:(NSArray<NSDictionary *> *)soundDictionaries {
    NSArray *filteredSoundDictionaries = [soundDictionaries filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSDictionary * _Nonnull soundInfo, NSDictionary<NSString *,id> * _Nullable bindings) {
        BOOL streamable = [soundInfo[@"origin"][@"streamable"] isEqualToNumber:@1];
        BOOL isTrack = [soundInfo[@"origin"][@"kind"] isEqualToString:@"track"];
        return streamable && isTrack;
    }]];
    
    NSMutableArray *newSounds = [NSMutableArray array];
    for (NSDictionary *soundDictionary in filteredSoundDictionaries) {
        NSError *soundDeserializationError;
        FSHSound *sound = [MTLJSONAdapter modelOfClass:[FSHSound class] fromJSONDictionary:soundDictionary error:&soundDeserializationError];
        if (soundDeserializationError) {
            NSLog(@"Error deserializing FSHSound: %@", soundDeserializationError);
        }
        [newSounds addObject:sound];
    };
    
    return [newSounds copy];
}

@end
