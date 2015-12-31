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
#import "FSHSoundListViewController.h"
#import "Fresh-Swift.h"

@interface FSHSoundListPresenter ()

@property (strong, nonatomic) NSMutableArray<FSHSound *> *sounds;

@end

@implementation FSHSoundListPresenter

- (instancetype)initWithService:(SoundCloudService *)service {
    self = [super init];
    if (!self) return nil;
    if (!service) return self;

    _service = service;
    _sounds = [NSMutableArray array];
    _selectedSoundDelegates = [NSMutableArray array];

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
    self.selectedSound = [self soundAtIndex:index];
    [self.selectedSoundDelegates makeObjectsPerformSelector:@selector(selectedSoundChanged:) withObject:self.selectedSound];
}

- (NSInteger)indexOfSelectedSound {
    return [self.service.account.sounds indexOfObject:self.selectedSound];
}

#pragma mark Presenter

- (void)initializeView {
    @weakify(self)
    [[self updateSounds] subscribeNext:^(NSArray *sounds) {
        @strongify(self)
        NSMutableArray<SoundListRowModel *> *models = [NSMutableArray array];
        for (FSHSound *sound in sounds) {
            SoundListRowModel *model = [[SoundListRowModel alloc] init];
            model.title = sound.title;
            model.author = sound.author;
            [models addObject:model];
        }
        self.view.rowModels = [models copy];
    }];
}

@end
