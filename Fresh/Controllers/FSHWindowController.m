//
//  FSHWindowController.m
//  Fresh
//
//  Created by Brandon on 2014-03-27.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHWindowController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>

#import "Fresh-Swift.h"
#import "FSHNowPlayingViewController.h"
#import "PopoverContentViewController.h"
#import "FSHNowPlayingViewModel.h"
#import "FSHSoundListViewModel.h"
#import "FSHAccount.h"

@interface FSHWindowController ()

@property (nonatomic, strong) FSHLoginViewController *loginViewController;
@property (nonatomic, strong) PopoverContentViewController *listViewController;
@property (nonatomic, strong) FSHNowPlayingViewController *nowPlayingViewController;

@end

@implementation FSHWindowController

- (void)windowDidLoad {
    self.window.title = @"Fresh";

    self.loginViewController = [[FSHLoginViewController alloc] initWithNibName:@"FSHLoginView" bundle:nil];
    self.nowPlayingViewController = [[FSHNowPlayingViewController alloc] initWithViewModel:nil];
    self.listViewController = [[PopoverContentViewController alloc] initWithNibName:@"PopoverContentView" bundle:nil];

    // Setup bindings
    @weakify(self)
    [RACObserve(self, viewModel.nowPlayingViewModel) subscribeNext:^(FSHNowPlayingViewModel *viewModel) {
        @strongify(self)
        self.nowPlayingViewController.viewModel = viewModel;
    }];
    [RACObserve(self, viewModel.soundListViewModel) subscribeNext:^(FSHSoundListViewModel *viewModel) {
        @strongify(self)
        self.listViewController.viewModel = viewModel;
    }];

    [RACObserve(self, viewModel.account.selectedSound) subscribeNext:^(FSHSound *sound) {
        sound ? [self revealNowPlayingView] : [self hideNowPlayingView];
    }];

    RAC(self, window.contentView) = [RACObserve(self, viewModel.account.isLoggedIn) map:^NSView *(NSNumber *loggedIn) {
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
