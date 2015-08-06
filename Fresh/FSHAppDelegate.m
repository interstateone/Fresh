//
//  FSHAppDelegate.m
//  Fresh
//
//  Created by Brandon on 2014-03-09.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHAppDelegate.h"
#import "SCSoundCloud.h"
#import "FSHWindowController.h"

@interface FSHAppDelegate ()

@property (nonatomic, strong) FSHWindowController *windowController;

@end

@implementation FSHAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setupSoundCloud]; // Must happen first
    [self setupWindow];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent {
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];

    BOOL handled = [SCSoundCloud handleRedirectURL:[NSURL URLWithString:url]];
    if (!handled) {
        NSLog(@"The URL (%@) could not be handled by the SoundCloud API. Maybe you want to do something with it.", url);
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"FSHSoundCloudUserDidAuthenticate" object:nil];
}

- (void)setupWindow {
    self.windowController = [[FSHWindowController alloc] init];
    [self.windowController showWindow:nil];
}

- (void)setupSoundCloud {
    [SCSoundCloud setClientID:@"912a424bf4a12ab4c858bf841953eddc" secret:@"e8d7fd3754f91a80e181718a161dc935" redirectURL:[NSURL URLWithString:@"freshapp://oauth"]];
}

@end
