//
//  FSHNowPlayingViewController.h
//  Fresh
//
//  Created by Brandon on 2014-03-27.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

@class FSHNowPlayingPresenter;
@class FSHWaveform;
@protocol NowPlayingView;

@interface FSHNowPlayingViewController : NSTitlebarAccessoryViewController <NowPlayingView>

@property (nonatomic, strong) FSHNowPlayingPresenter *presenter;

#pragma mark - NowPlayingView

@property (nonatomic, copy) NSString *trackTitle;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, assign) double progress;
@property (nonatomic, assign) double duration;
@property (nonatomic, copy) NSString *formattedProgress;
@property (nonatomic, copy) NSString *formattedDuration;
@property (nonatomic, assign) BOOL favorite;
@property (nonatomic, assign) BOOL hidden;
@property (nonatomic, strong) FSHWaveform *waveform;
@property (nonatomic, assign) BOOL playing;
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, strong) NSURL *permalinkURL;

@end
