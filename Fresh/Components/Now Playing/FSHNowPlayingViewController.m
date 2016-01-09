//
//  FSHNowPlayingViewController.m
//  Fresh
//
//  Created by Brandon on 2014-03-27.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHNowPlayingViewController.h"
#import "FSHNowPlayingPresenter.h"
#import "FSHWaveformSliderView.h"
#import "Fresh-Swift.h"

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

    self.hidden = YES;
    
    // Setup views
    [self.tweetButton sendActionOn:NSLeftMouseDownMask];

    [self.progressLabel.cell setBackgroundStyle:NSBackgroundStyleLowered];
    [self.durationLabel.cell setBackgroundStyle:NSBackgroundStyleLowered];

    self.masterPlayButton.target = self.presenter;
    self.masterPlayButton.action = @selector(toggleCurrentSound);
    self.favoriteButton.target = self.presenter;
    self.favoriteButton.action = @selector(toggleFavorite);
    self.waveformSlider.target = self;
    self.waveformSlider.action = @selector(waveformSliderChanged:);

    NSEvent *(^eventHandler)(NSEvent *) = ^(NSEvent *theEvent) {
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

- (void)waveformSliderChanged:(FSHWaveformSliderView *)slider {
    [self.presenter seekToProgress:slider.objectValue];
}

#pragma mark - NowPlayingView

- (void)setTrackTitle:(NSString *)trackTitle {
    _trackTitle = trackTitle;
    self.trackLabel.stringValue = trackTitle;
}

- (void)setAuthor:(NSString *)author {
    _author = author;
    self.authorLabel.stringValue = author;
}

- (void)setProgress:(double)progress {
    _progress = progress;
    self.waveformSlider.doubleValue = progress;
}

- (void)setDuration:(double)duration {
    _duration = duration;
    self.waveformSlider.maxValue = duration;
}

- (void)setFormattedProgress:(NSString *)progress {
    _formattedProgress = progress;
    self.progressLabel.stringValue = progress;
}

- (void)setFormattedDuration:(NSString *)duration {
    _formattedDuration = duration;
    self.durationLabel.stringValue = duration;
}

- (void)setFavorite:(BOOL)favorite {
    _favorite = favorite;
    self.favoriteButton.image = favorite ? [NSImage imageNamed:@"FavoriteActive"] : [NSImage imageNamed:@"Favorite"];
}

- (void)setHidden:(BOOL)hidden {
    _hidden = hidden;
    self.view.hidden = hidden;
}

- (void)setWaveform:(FSHWaveform *)waveform {
    _waveform = waveform;
    self.waveformSlider.waveform = waveform;
}

- (void)setPlaying:(BOOL)playing {
    self.masterPlayButton.image = playing ? [NSImage imageNamed:@"PauseButton"] : [NSImage imageNamed:@"PlayButton"];
}

#pragma mark - Actions

- (IBAction)shareCurrentSound:(NSControl *)sender {
    NSString *shareText = [NSString stringWithFormat:@"Listening to %@ by %@ with Fresh.\n\n%@", self.trackTitle, self.author, self.permalinkURL];
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
        [[NSWorkspace sharedWorkspace] openURL:self.permalinkURL];
    }];
    [services addObject:viewOnSoundCloud];

    return services;
}

@end
