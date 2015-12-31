//
//  FSHWindowController.m
//  Fresh
//
//  Created by Brandon on 2014-03-27.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHWindowController.h"

@import ReactiveCocoa;

#import "Fresh-Swift.h"
#import "FSHNowPlayingViewController.h"
#import "FSHSoundListViewController.h"
#import "FSHNowPlayingPresenter.h"
#import "FSHSoundListPresenter.h"
#import "FSHAccount.h"

@implementation FSHWindowController

- (void)windowDidLoad {
    self.window.title = @"Fresh";
    [self.presenter initializeView];
}

- (void)revealNowPlayingView {
    if (self.nowPlayingViewController.parentViewController) {
        return;
    }

    [self.window addTitlebarAccessoryViewController:self.nowPlayingViewController];
    self.window.titleVisibility = NSWindowTitleHidden;
}

- (void)hideNowPlayingView {
    if (!self.nowPlayingViewController.parentViewController) {
        return;
    }
    
    [self.nowPlayingViewController removeFromParentViewController];
    self.window.titleVisibility = NSWindowTitleVisible;
}

- (void)transitionToSoundList {
    self.window.contentView = self.listViewController.view;
}

- (void)transitionToLogin {
    self.window.contentView = self.loginViewController.view;
}

@end
