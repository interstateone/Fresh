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
#import <INAppStoreWindow/INAppStoreWindow.h>

#import "FSHNowPlayingViewController.h"
#import "PopoverContentViewController.h"
#import "FSHNowPlayingViewModel.h"
#import "FSHSoundListViewModel.h"
#import "FSHAccount.h"

@interface FSHWindowController ()

@property (nonatomic, strong) PopoverContentViewController *listViewController;
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
    INAppStoreWindow *window = (INAppStoreWindow *)self.window;
    window.centerTrafficLightButtons = NO;
    window.showsTitle = YES;
    window.title = @"Fresh";

    self.nowPlayingViewController = [[FSHNowPlayingViewController alloc] init];
    self.nowPlayingViewController.view.frame = window.titleBarView.bounds;
    self.nowPlayingViewController.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [window.titleBarView addSubview:self.nowPlayingViewController.view];

    self.listViewController = [[PopoverContentViewController alloc] initWithNibName:@"PopoverContentView" bundle:nil];

    // Setup bindings
    @weakify(self)
    [[NSNotificationCenter defaultCenter] addObserverForName:@"FSHSoundCloudUserDidAuthenticate" object:nil queue:[NSOperationQueue currentQueue] usingBlock:^(NSNotification *note) {
        @strongify(self)
        self.account = [FSHAccount currentAccount];
    }];

    [RACObserve(self, account) subscribeNext:^(FSHAccount *account) {
        @strongify(self)
        self.nowPlayingViewController.viewModel = [[FSHNowPlayingViewModel alloc] initWithAccount:account];
        self.listViewController.viewModel = [[FSHSoundListViewModel alloc] initWithAccount:account];
    }];

    [RACObserve(self, account.selectedSound) subscribeNext:^(FSHSound *sound) {
        sound ? [self revealNowPlayingView] : [self hideNowPlayingView];
    }];

    RAC(self, window.contentView) = RACObserve(self, listViewController.view);

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
    INAppStoreWindow *window = (INAppStoreWindow *)self.window;
    window.titleBarHeight = 75.0f;
    window.showsTitle = NO;
}

- (void)hideNowPlayingView {
    INAppStoreWindow *window = (INAppStoreWindow *)self.window;
    window.titleBarHeight = 22.0;
    window.showsTitle = YES;
}


@end
