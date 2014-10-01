//
//  FSHNowPlayingViewController.m
//  Fresh
//
//  Created by Brandon on 2014-03-27.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHNowPlayingViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>

#import "FSHNowPlayingViewModel.h"
#import "FSHWaveformSliderView.h"
#import "NSView+RACProperties.h"

@interface FSHNowPlayingViewController () <NSSharingServicePickerDelegate>

@property (weak, nonatomic) IBOutlet NSImageView *currentSoundImageView;
@property (weak, nonatomic) IBOutlet NSButton *masterPlayButton;
@property (weak, nonatomic) IBOutlet NSTextField *trackLabel;
@property (weak, nonatomic) IBOutlet NSTextField *authorLabel;
@property (weak, nonatomic) IBOutlet NSButton *tweetButton;
@property (weak, nonatomic) IBOutlet NSTextField *progressLabel;
@property (weak, nonatomic) IBOutlet NSTextField *durationLabel;
@property (weak, nonatomic) IBOutlet FSHWaveformSliderView *waveformSlider;
@property (weak, nonatomic) IBOutlet NSButton *favoriteButton;

@end

@implementation FSHNowPlayingViewController

- (instancetype)initWithViewModel:(FSHNowPlayingViewModel *)viewModel {
    self = [super initWithNibName:@"FSHNowPlayingView" bundle:nil];
    if (!self) return nil;

    _viewModel = viewModel;

    return self;
}

- (void)loadView {
    [super loadView];
    
    // Setup views
    [self.tweetButton sendActionOn:NSLeftMouseDownMask];
    [self.masterPlayButton setBordered:NO];
    [self.masterPlayButton setButtonType:NSMomentaryChangeButton];
    [self.tweetButton setBordered:NO];
    [self.tweetButton setButtonType:NSMomentaryChangeButton];

    [self.trackLabel.cell setBackgroundStyle:NSBackgroundStyleRaised];
    [self.authorLabel.cell setBackgroundStyle:NSBackgroundStyleRaised];
    [self.progressLabel.cell setBackgroundStyle:NSBackgroundStyleLowered];
    [self.durationLabel.cell setBackgroundStyle:NSBackgroundStyleLowered];

    [self.favoriteButton.cell setHighlightsBy:NSNoCellMask];
    [self.favoriteButton.cell setShowsStateBy:NSNoCellMask];

    // Setup bindings
    RAC(self.masterPlayButton, image) = [RACSignal combineLatest:@[ RACObserve(self, viewModel.playing) ] reduce:^id(NSNumber *playing){
        if ([playing boolValue]) {
            return [NSImage imageNamed:@"PauseButton"];
        }
        else {
            return [NSImage imageNamed:@"PlayButton"];
        }
    }];

    RAC(self, masterPlayButton.rac_command) = RACObserve(self, viewModel.toggleCurrentSound);

    RAC(self.trackLabel, stringValue) = [RACSignal combineLatest:@[ RACObserve(self, viewModel.title) ] reduce:^id(NSString *title){
        return title ?: @"";
    }];

    RAC(self.authorLabel, stringValue) = [RACSignal combineLatest:@[ RACObserve(self, viewModel.author) ] reduce:^id(NSString *author){
        return author ?: @"";
    }];

    RAC(self.progressLabel, stringValue) = [RACSignal combineLatest:@[ RACObserve(self, viewModel.progress), RACObserve(self, viewModel.duration) ] reduce:^id(NSNumber *progress, NSNumber *duration){
        NSInteger progressMinutes = [progress integerValue] / 60;
        NSInteger progressSeconds = [progress integerValue] % 60;
        return [NSString stringWithFormat:@"%.2ld:%.2ld", progressMinutes, progressSeconds];
    }];

    RAC(self.durationLabel, stringValue) = [RACSignal combineLatest:@[ RACObserve(self, viewModel.progress), RACObserve(self, viewModel.duration) ] reduce:^id(NSNumber *progress, NSNumber *duration){
        NSInteger durationMinutes = [duration integerValue] / 60;
        NSInteger durationSeconds = [duration integerValue] % 60;
        return [NSString stringWithFormat:@"%.2ld:%.2ld", durationMinutes, durationSeconds];
    }];

    RAC(self.waveformSlider, doubleValue) = [RACSignal combineLatest:@[ RACObserve(self, viewModel.progress) ] reduce:^id(NSNumber *progress){
        return progress ?: @0;
    }];

    RAC(self.waveformSlider, maxValue) = [RACSignal combineLatest:@[ RACObserve(self, viewModel.duration) ] reduce:^id(NSNumber *duration){
        return duration ?: @0;
    }];

    RAC(self.waveformSlider, waveformImage) = RACObserve(self, viewModel.waveformImage);

    @weakify(self);
    self.waveformSlider.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSSlider *slider) {
        @strongify(self);
        [self.viewModel seekToProgress:@(slider.doubleValue)];
        return [RACSignal empty];
    }];

    RAC(self.favoriteButton, alphaValue) = [RACSignal combineLatest:@[ RACObserve(self, viewModel.favorite)] reduce:^id(NSNumber *favorite){
        return [favorite boolValue] ? @(1.0f) : @(0.5f);
    }];

    self.favoriteButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.viewModel toggleFavorite];
        return [RACSignal empty];
    }];

    RAC(self, view.hidden, @YES) = RACObserve(self, viewModel.hidden);
}

#pragma mark - Actions

- (IBAction)shareCurrentSound:(NSControl *)sender {
    NSString *shareText = [NSString stringWithFormat:@"Listening to %@ by %@ with Fresh.\n\n%@", self.viewModel.title, self.viewModel.author, self.viewModel.permalinkURL];
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
        [[NSWorkspace sharedWorkspace] openURL:self.viewModel.permalinkURL];
    }];
    [services addObject:viewOnSoundCloud];

    return services;
}

@end
