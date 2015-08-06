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

@interface FSHWindowController () <NSWindowDelegate>

@property (nonatomic, strong) PopoverContentViewController *listViewController;
@property (nonatomic, strong) FSHLoginViewController *loginViewController;
@property (nonatomic, strong) FSHNowPlayingViewController *nowPlayingViewController;
@property (nonatomic, strong) id eventMonitor;
@property (nonatomic, strong) FSHAccount *account;

@end

@implementation FSHWindowController

- (instancetype)init {
    self = [super initWithWindowNibName:@"FSHWindow"];
    if (!self) return nil;

    self.account = [FSHAccount currentAccount];

    return self;
}

- (void)windowDidLoad {
    // Setup views
    NSWindow *window = self.window;
    window.title = @"Fresh";
    window.delegate = self;

    self.nowPlayingViewController = [[FSHNowPlayingViewController alloc] initWithViewModel:nil];
    self.nowPlayingViewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self revealNowPlayingView];

    self.listViewController = [[PopoverContentViewController alloc] initWithNibName:@"PopoverContentView" bundle:nil];
    self.loginViewController = [[FSHLoginViewController alloc] initWithNibName:@"FSHLoginView" bundle:nil];

    // Setup bindings
    @weakify(self)
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FSHSoundCloudUserDidAuthenticate" object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        @strongify(self)
        self.account = [FSHAccount currentAccount];
    }];

    RACSignal *accountSignal = RACObserve(self, account);
    [accountSignal subscribeNext:^(FSHAccount *account) {
        @strongify(self)
        self.nowPlayingViewController.viewModel = [[FSHNowPlayingViewModel alloc] initWithAccount:account];
        self.listViewController.viewModel = [[FSHSoundListViewModel alloc] initWithAccount:account];
    }];

    [RACObserve(self, account.selectedSound) subscribeNext:^(FSHSound *sound) {
        sound ? [self revealNowPlayingView] : [self hideNowPlayingView];
    }];

    RAC(self, window.contentView) = [accountSignal map:^NSView *(FSHAccount *account) {
        if (account.isLoggedIn) {
            return self.listViewController.view;
        }
        return self.loginViewController.view;
    }];

    NSEvent *(^eventHandler)(NSEvent *) = ^(NSEvent *theEvent) {
        @strongify(self);
        NSWindow *targetWindow = theEvent.window;
        if (targetWindow != self.window) {
            return theEvent;
        }

        NSEvent *result = theEvent;
        // Space bar
        // See HIToolbox/Events.h for reference
        if (theEvent.keyCode == 49) {
            [self.nowPlayingViewController.viewModel toggleCurrentSound];
            result = nil;
        }

        return result;
    };
    self.eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:eventHandler];
}

- (void)dealloc {
    [NSEvent removeMonitor:self.eventMonitor];
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
