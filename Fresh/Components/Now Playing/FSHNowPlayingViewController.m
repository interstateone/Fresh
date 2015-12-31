//
//  FSHNowPlayingViewController.m
//  Fresh
//
//  Created by Brandon on 2014-03-27.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHNowPlayingViewController.h"

@import ReactiveCocoa;

#import "FSHNowPlayingPresenter.h"
#import "FSHWaveformSliderView.h"
#import "NSView+RACProperties.h"

@interface FSHNowPlayingViewController () <NSSharingServicePickerDelegate>

@property (weak, nonatomic) IBOutlet NSButton *masterPlayButton;
@property (weak, nonatomic) IBOutlet NSTextField *trackLabel;
@property (weak, nonatomic) IBOutlet NSTextField *authorLabel;
@property (weak, nonatomic) IBOutlet NSButton *tweetButton;
@property (weak, nonatomic) IBOutlet NSTextField *progressLabel;
@property (weak, nonatomic) IBOutlet NSTextField *durationLabel;
@property (weak, nonatomic) IBOutlet FSHWaveformSliderView *waveformSlider;
@property (weak, nonatomic) IBOutlet NSButton *favoriteButton;

@property (nonatomic, strong) id eventMonitor;

@end

@implementation FSHNowPlayingViewController

- (void)loadView {
    [super loadView];
    
    // Setup views
    [self.tweetButton sendActionOn:NSLeftMouseDownMask];

    [self.progressLabel.cell setBackgroundStyle:NSBackgroundStyleLowered];
    [self.durationLabel.cell setBackgroundStyle:NSBackgroundStyleLowered];

    // Setup bindings
    RAC(self.masterPlayButton, image) = [RACObserve(self, presenter.playing) map:^id(NSNumber *playing){
        return [playing boolValue] ? [NSImage imageNamed:@"PauseButton"] : [NSImage imageNamed:@"PlayButton"];
    }];

    RAC(self, masterPlayButton.rac_command) = RACObserve(self, presenter.toggleCurrentSound);

    RAC(self.favoriteButton, image) = [RACObserve(self, presenter.favorite) map:^id(NSNumber *favorite) {
        return [favorite boolValue] ? [NSImage imageNamed:@"FavoriteActive"] : [NSImage imageNamed:@"Favorite"];
    }];

    RAC(self.trackLabel, stringValue) = [RACObserve(self, presenter.title) map:^id(NSString *title){
        return title ?: @"";
    }];

    RAC(self.authorLabel, stringValue) = [RACObserve(self, presenter.author) map:^id(NSString *author){
        return author ?: @"";
    }];

    RAC(self.progressLabel, stringValue) = RACObserve(self, presenter.formattedProgress);

    RAC(self.durationLabel, stringValue) = RACObserve(self, presenter.formattedDuration);

    RAC(self.waveformSlider, doubleValue) = [RACObserve(self, presenter.progress) map:^id(NSNumber *progress){
        return progress ?: @0;
    }];

    RAC(self.waveformSlider, maxValue) = [RACObserve(self, presenter.duration) map:^id(NSNumber *duration){
        return duration ?: @0;
    }];

    RAC(self.waveformSlider, waveform) = RACObserve(self, presenter.waveform);

    @weakify(self);
    self.waveformSlider.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSSlider *slider) {
        @strongify(self);
        [self.presenter seekToProgress:((NSNumber *)slider.objectValue)];
        return [RACSignal empty];
    }];

    self.favoriteButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [[self.presenter toggleFavorite] execute:input];
        return [RACSignal empty];
    }];

    RAC(self, view.hidden, @YES) = RACObserve(self, presenter.hidden);

    NSEvent *(^eventHandler)(NSEvent *) = ^(NSEvent *theEvent) {
        @strongify(self);
        NSWindow *targetWindow = theEvent.window;
        if (targetWindow != self.view.window) {
            return theEvent;
        }

        NSEvent *result = theEvent;
        // Space bar
        // See HIToolbox/Events.h for reference
        if (theEvent.keyCode == 49) {
            [self.presenter toggleCurrentSound];
            result = nil;
        }

        return result;
    };
    self.eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:eventHandler];
}

- (void)dealloc {
    [NSEvent removeMonitor:self.eventMonitor];
}

#pragma mark - Actions

- (IBAction)shareCurrentSound:(NSControl *)sender {
    NSString *shareText = [NSString stringWithFormat:@"Listening to %@ by %@ with Fresh.\n\n%@", self.presenter.title, self.presenter.author, self.presenter.permalinkURL];
    NSSharingServicePicker *picker = [[NSSharingServicePicker alloc] initWithItems:@[ shareText ]];
    picker.delegate = self;
    [picker showRelativeToRect:NSZeroRect ofView:sender preferredEdge:NSMaxXEdge];
}

#pragma mark - NSSharingServicePickerDelegate

- (NSArray *)sharingServicePicker:(NSSharingServicePicker *)sharingServicePicker sharingServicesForItems:(NSArray *)items proposedSharingServices:(NSArray *)proposedServices {
    NSMutableArray *services = [NSMutableArray array];

    NSSharingService *twitter = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTwitter];
    if ([twitter canPerformWithItems:items]) {
        [services addObject:twitter];
    }

    NSSharingService *facebook = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnFacebook];
    if ([facebook canPerformWithItems:items]) {
        [services addObject:facebook];
    }

    NSSharingService *sinaWeibo = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnSinaWeibo];
    if ([sinaWeibo canPerformWithItems:items]) {
        [services addObject:sinaWeibo];
    }

    NSSharingService *tencentWeibo = [NSSharingService sharingServiceNamed:NSSharingServiceNamePostOnTencentWeibo];
    if ([tencentWeibo canPerformWithItems:items]) {
        [services addObject:tencentWeibo];
    }

    NSSharingService *viewOnSoundCloud = [[NSSharingService alloc] initWithTitle:@"View On SoundCloud" image:[NSImage imageNamed:@"SoundCloudLogoSmall"] alternateImage:nil handler:^{
        [[NSWorkspace sharedWorkspace] openURL:self.presenter.permalinkURL];
    }];
    [services addObject:viewOnSoundCloud];

    return services;
}

@end
