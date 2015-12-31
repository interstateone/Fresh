//
//  FSHSoundListPresenter.h
//  Fresh
//
//  Created by Brandon on 2014-03-29.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//


@class FSHAccount;
@class FSHSound;
@class RACSignal;
@class SoundCloudService;

@interface FSHSoundListPresenter: NSObject

@property (nonatomic, strong) SoundCloudService *service;

- (instancetype)initWithService:(SoundCloudService *)service;

- (RACSignal *)updateSounds;
- (RACSignal *)fetchNextSounds;
- (void)selectSoundAtIndex:(NSInteger)index;
- (NSInteger)indexOfSelectedSound;

@end
