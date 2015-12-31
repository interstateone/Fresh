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
@protocol Presenter;
@protocol FSHSoundListView;

@interface FSHSoundListPresenter: NSObject <Presenter>

@property (nonatomic, strong) SoundCloudService *service;
@property (nonatomic, strong) id<FSHSoundListView> view;

- (instancetype)initWithService:(SoundCloudService *)service;

- (RACSignal *)updateSounds;
- (RACSignal *)fetchNextSounds;
- (void)selectSoundAtIndex:(NSInteger)index;
- (NSInteger)indexOfSelectedSound;

#pragma mark Presenter

- (void)initializeView;

@end
