//
//  FSHNowPlayingPresenter.h
//  Fresh
//
//  Created by Brandon on 2014-03-27.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHSound.h"
#import "FSHSoundListPresenter.h"

@class RACCommand;
@class FSHAccount;
@class FSHWaveform;
@protocol NowPlayingView;

@interface FSHNowPlayingPresenter : NSObject <SelectedSoundDelegate>

@property (nonatomic, strong) id<NowPlayingView> view;
@property (nonatomic, strong) FSHSound *sound;

- (void)toggleCurrentSound;
- (void)toggleFavorite;
- (void)seekToProgress:(NSNumber *)progress;
- (void)selectedSoundChanged:(FSHSound *)sound;

@end
