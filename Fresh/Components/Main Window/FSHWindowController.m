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

@interface FSHWindowController ()

@property (nonatomic, strong) FSHLoginViewController *loginViewController;
@property (nonatomic, strong) FSHSoundListViewController *listViewController;
@property (nonatomic, strong) FSHNowPlayingViewController *nowPlayingViewController;

@end

@implementation FSHWindowController

- (void)windowDidLoad {
    self.window.title = @"Fresh";

    self.loginViewController = [[FSHLoginViewController alloc] initWithNibName:@"FSHLoginView" bundle:nil];
    self.nowPlayingViewController = [[FSHNowPlayingViewController alloc] initWithPresenter:nil];
    self.listViewController = [[FSHSoundListViewController alloc] initWithNibName:@"FSHSoundListView" bundle:nil];

    // Setup bindings
    @weakify(self)
    [RACObserve(self, presenter.nowPlayingPresenter) subscribeNext:^(FSHNowPlayingPresenter *presenter) {
        @strongify(self)
        self.nowPlayingViewController.presenter = presenter;
    }];
    [RACObserve(self, presenter.soundListPresenter) subscribeNext:^(FSHSoundListPresenter *presenter) {
        @strongify(self)
        self.listViewController.presenter = presenter;
    }];

    [RACObserve(self, presenter.account.selectedSound) subscribeNext:^(FSHSound *sound) {
        sound ? [self revealNowPlayingView] : [self hideNowPlayingView];
    }];

    RAC(self, window.contentView) = [RACObserve(self, presenter.account.isLoggedIn) map:^NSView *(NSNumber *loggedIn) {
        return loggedIn.boolValue ? self.listViewController.view : self.loginViewController.view;
    }];
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

@end
