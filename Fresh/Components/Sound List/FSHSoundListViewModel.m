//
//  FSHSoundListViewModel.m
//  Fresh
//
//  Created by Brandon on 2014-03-29.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHSoundListViewModel.h"

@import ReactiveCocoa;

#import "FSHAccount.h"
#import "FSHSound.h"

@implementation FSHSoundListViewModel

- (instancetype)initWithAccount:(FSHAccount *)account {
    self = [super init];
    if (!self) return nil;
    if (!account) return self;

    _account = account;

    RAC(self, numberOfSounds) = [RACObserve(self, account.sounds) map:^id(NSArray *sounds) {
        return @([sounds count]);
    }];

    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"FSHSoundEndedNotification" object:nil] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(NSNotification *note) {
        @strongify(self)
        NSInteger index = [self.account.sounds indexOfObject:note.object];

        if (index == self.account.sounds.count - 1) {
            @weakify(self)
            [[self fetchNextSounds] subscribeNext:^(id x) {
                @strongify(self)
                [self selectSoundAtIndex:(index + 1)];
            }];
        }
        else {
            [self selectSoundAtIndex:(index + 1)];
        }
    }];

    return self;
}

- (FSHSound *)soundAtIndex:(NSInteger)index {
    // Returning nil as opposed to constraining to the list which would loop the last track
    if (index < 0 || index > ([self.account.sounds count] - 1)) return nil;
    return self.account.sounds[index];
}

- (NSString *)titleForSoundAtIndex:(NSInteger)index {
    return [self soundAtIndex:index].title;
}

- (NSString *)authorForSoundAtIndex:(NSInteger)index {
    return [self soundAtIndex:index].author;
}

- (RACSignal *)updateSounds {
    return [self.account updateSounds];
}

- (RACSignal *)fetchNextSounds {
    return [self.account fetchNextSounds];
}

- (void)selectSoundAtIndex:(NSInteger)index {
    self.account.selectedSound = [self soundAtIndex:index];
}

- (NSInteger)indexOfSelectedSound {
    return [self.account.sounds indexOfObject:self.account.selectedSound];
}

@end
