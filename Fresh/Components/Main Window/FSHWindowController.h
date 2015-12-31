//
//  FSHWindowController.h
//  Fresh
//
//  Created by Brandon on 2014-03-27.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

@class MainWindowPresenter;
@class FSHLoginViewController;
@class FSHSoundListViewController;
@class FSHNowPlayingViewController;

@interface FSHWindowController : NSWindowController

@property (nonatomic, strong) MainWindowPresenter *presenter;

@property (nonatomic, strong) FSHLoginViewController *loginViewController;
@property (nonatomic, strong) FSHSoundListViewController *listViewController;
@property (nonatomic, strong) FSHNowPlayingViewController *nowPlayingViewController;

- (void)revealNowPlayingView;
- (void)hideNowPlayingView;
- (void)transitionToSoundList;
- (void)transitionToLogin;

@end
