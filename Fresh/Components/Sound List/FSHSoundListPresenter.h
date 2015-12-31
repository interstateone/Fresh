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
@protocol SoundListView;

@protocol SelectedSoundDelegate <NSObject>
- (void)selectedSoundChanged:(FSHSound *)sound;
@end

@interface FSHSoundListPresenter: NSObject <Presenter>

@property (nonatomic, strong) SoundCloudService *service;
@property (nonatomic, strong) id<SoundListView> view;
// TODO: Change this to an ObserverSet once converted to Swift
@property (nonatomic, strong) NSMutableArray<id <SelectedSoundDelegate>> *selectedSoundDelegates;

- (instancetype)initWithService:(SoundCloudService *)service;

@property (nonatomic, strong) FSHSound *selectedSound;

- (RACSignal *)updateSounds;
- (RACSignal *)fetchNextSounds;
- (void)selectSoundAtIndex:(NSInteger)index;
- (NSInteger)indexOfSelectedSound;

#pragma mark Presenter

- (void)initializeView;

@end
