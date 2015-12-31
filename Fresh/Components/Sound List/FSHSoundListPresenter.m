//
//  FSHSoundListPresenter.m
//  Fresh
//
//  Created by Brandon on 2014-03-29.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHSoundListPresenter.h"

@import ReactiveCocoa;

#import "FSHAccount.h"
#import "FSHSound.h"
#import "Fresh-Swift.h"

@interface FSHSoundListPresenter ()

@property (strong, nonatomic) NSMutableArray<FSHSound *> *sounds;

@end

@implementation FSHSoundListPresenter

- (instancetype)initWithService:(SoundCloudService *)service {
    self = [super init];
    if (!self) return nil;
    if (!service) return self;

    RAC(self, numberOfSounds) = [RACObserve(self, sounds) map:^id(NSArray *sounds) {
        return @([sounds count]);
    }];

    _service = service;
    _sounds = [NSMutableArray array];

    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"FSHSoundEndedNotification" object:nil] takeUntil:[self rac_willDeallocSignal]] subscribeNext:^(NSNotification *note) {
        @strongify(self)
        NSInteger index = [self.service.account.sounds indexOfObject:note.object];

        if (index == self.service.account.sounds.count - 1) {
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
    if (index < 0 || index > ([self.sounds count] - 1)) return nil;
    return self.sounds[index];
}

- (RACSignal *)updateSounds {
    RACSignal *signal = [self.service updateSounds];
    [signal subscribeNext:^(id x) {
        self.sounds = x;
    }];
    return signal;
}

- (RACSignal *)fetchNextSounds {
    return [self.service fetchNextSounds];
}

- (void)selectSoundAtIndex:(NSInteger)index {
    self.service.account.selectedSound = [self soundAtIndex:index];
}

- (NSInteger)indexOfSelectedSound {
    return [self.service.account.sounds indexOfObject:self.service.account.selectedSound];
}

@end