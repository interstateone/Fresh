//
//  FSHAppDelegate.m
//  Fresh
//
//  Created by Brandon on 2014-03-09.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHAppDelegate.h"
#import "SCSoundCloud.h"
#import <Keys/FreshKeys.h>
#import "Fresh-Swift.h"

@interface FSHAppDelegate ()

@property (nonatomic, strong) MainWireframe *wireframe;

@end

@implementation FSHAppDelegate

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
    NSAppleEventManager *appleEventManager = [NSAppleEventManager sharedAppleEventManager];
    [appleEventManager setEventHandler:self andSelector:@selector(handleGetURLEvent:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    FreshKeys *keys = [[FreshKeys alloc] init];
    [SCSoundCloud setClientID:keys.soundCloudClientID secret:keys.soundCloudClientSecret redirectURL:[NSURL URLWithString:@"freshapp://oauth"]];

    self.wireframe = [[MainWireframe alloc] init];
    [self.wireframe presentMainWindow];
}

- (void)handleGetURLEvent:(NSAppleEventDescriptor*)event withReplyEvent:(NSAppleEventDescriptor*)replyEvent {
    NSString* url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];

    BOOL handled = [SCSoundCloud handleRedirectURL:[NSURL URLWithString:url]];
    if (!handled) {
        NSLog(@"The URL (%@) could not be handled by the SoundCloud API. Maybe you want to do something with it.", url);
        return;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"FSHSoundCloudUserDidAuthenticate" object:nil];
}

@end
