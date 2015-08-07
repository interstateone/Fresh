//
//  FSHNowPlayingViewModel.m
//  Fresh
//
//  Created by Brandon on 2014-03-27.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHNowPlayingViewModel.h"

#import <StreamingKit/STKAudioPlayer.h>
@import ReactiveCocoa;

#import "FSHAccount.h"
#import "Fresh-Swift.h"

@interface FSHNowPlayingViewModel () <STKAudioPlayerDelegate>

@property (nonatomic, strong) FSHAccount *account;
@property (nonatomic, strong) STKAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *tickTimer;

@end

@implementation FSHNowPlayingViewModel

- (instancetype)initWithAccount:(FSHAccount *)account {
    self = [super init];
    if (!self) return nil;
    if (!account) return self;

    _audioPlayer = [[STKAudioPlayer alloc] init];
    _audioPlayer.delegate = self;

    _account = account;

    RAC(self, playing) = [RACObserve(self, audioPlayer.state) map:^id(NSNumber *state){
        return @([state integerValue] == STKAudioPlayerStatePlaying);
    }];

    RAC(self, loading) = [RACObserve(self, audioPlayer.state) map:^id(NSNumber *state){
        return @([state integerValue] == STKAudioPlayerStateBuffering);
    }];

    RAC(self, permalinkURL) = RACObserve(self, account.selectedSound.permalinkURL);

    RAC(self, title) = RACObserve(self, account.selectedSound.title);

    RAC(self, author) = RACObserve(self, account.selectedSound.author);

    RAC(self, waveform) = [RACObserve(self, account.selectedSound) flattenMap:^RACStream *(FSHSound *sound) {
        return [sound fetchWaveform];
    }];

    RAC(self, favorite, @NO) = RACObserve(self, account.selectedSound.favorite);

    [RACObserve(self, account.selectedSound) subscribeNext:^(FSHSound *sound) {
        if (sound && !sound.streamable) return;

        if (!sound) {
            [self.tickTimer invalidate];
            return;
        }

        self.tickTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
        self.tickTimer.tolerance = 0.25;

        [[sound fetchPlayURL] subscribeNext:^(NSURL *playURL) {
            [self.audioPlayer play:[playURL absoluteString]];
            self.duration = @(self.audioPlayer.duration);
        }];
    }];

    RAC(self, hidden, @YES) = [RACObserve(self, account.selectedSound) map:^id(FSHSound *sound) {
        return @(!sound);
    }];

    // Setup commands
    _toggleCurrentSound = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        if (!self.account.selectedSound) return [RACSignal empty];
        if (self.audioPlayer.state == STKAudioPlayerStatePlaying) {
            [self.audioPlayer pause];
        }
        else {
            [self.audioPlayer resume];
        }
        return [RACSignal empty];
    }];

    _toggleFavorite = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self.account.selectedSound toggleFavorite];
        return [RACSignal empty];
    }];

    return self;
}

- (void)dealloc {
    [self.tickTimer invalidate];
    self.tickTimer = nil;
}

- (void)seekToProgress:(NSNumber *)progress {
    [self.audioPlayer seekToTime:[progress doubleValue]];
}

- (void)tick:(NSTimer *)timer {
    if (self.playing) {
        self.progress = @(self.audioPlayer.progress);
        self.duration = @(self.audioPlayer.duration);
    }
}

#pragma mark - STKAudioPlayerDelegate

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode {
    NSLog(@"StreamingKit unexpected error: %d", errorCode);
}

- (void)audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration {
    if (stopReason == STKAudioPlayerStopReasonEof) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FSHSoundEndedNotification" object:self.account.selectedSound userInfo:nil];
    }
}

- (void)audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId {

}

- (void)audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId {

}

- (void)audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {

}

@end
