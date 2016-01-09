//
//  FSHNowPlayingPresenter.m
//  Fresh
//
//  Created by Brandon on 2014-03-27.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHNowPlayingPresenter.h"

#import <StreamingKit/STKAudioPlayer.h>

#import "FSHAccount.h"
#import "Fresh-Swift.h"

@interface FSHNowPlayingPresenter () <STKAudioPlayerDelegate>

@property (nonatomic, strong) STKAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *tickTimer;

@end

@implementation FSHNowPlayingPresenter

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    _audioPlayer = [[STKAudioPlayer alloc] init];
    _audioPlayer.delegate = self;

    return self;
}

- (void)setSound:(FSHSound *)sound {
    if (!sound) {
        self.view.hidden = YES;
        [self.tickTimer invalidate];
        return;
    }
    if (!sound.streamable) return;

    _sound = sound;

    self.tickTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    self.tickTimer.tolerance = 0.25;

    self.view.trackTitle = sound.title;
    self.view.author = sound.author;
    self.view.favorite = sound.favorite;
    self.view.hidden = NO;
    self.view.permalinkURL = sound.permalinkURL;

    [self.audioPlayer stop];
    [[sound fetchPlayURL] subscribeNext:^(NSURL *playURL) {
        [self.audioPlayer play:[playURL absoluteString]];
        self.view.duration = self.audioPlayer.duration;
    }];

    [[sound fetchWaveform] subscribeNext:^(FSHWaveform *waveform) {
        self.view.waveform = waveform;
    }];
}

- (void)dealloc {
    [self.tickTimer invalidate];
    self.tickTimer = nil;
}

- (void)toggleCurrentSound {
    if (!self.sound) return;

    if (self.audioPlayer.state == STKAudioPlayerStatePlaying) {
        [self.audioPlayer pause];
    }
    else {
        [self.audioPlayer resume];
    }
}

- (void)toggleFavorite {
    [self.sound toggleFavorite];
}

- (void)seekToProgress:(NSNumber *)progress {
    [self.audioPlayer seekToTime:[progress doubleValue]];
}

- (void)tick:(NSTimer *)timer {
    if (self.audioPlayer.state == STKAudioPlayerStatePlaying) {
        self.view.progress = self.audioPlayer.progress;
        self.view.duration = self.audioPlayer.duration;
        self.view.formattedDuration = [self formatSeconds:@(self.audioPlayer.duration)];
        self.view.formattedProgress = [self formatSeconds:@(self.audioPlayer.progress)];
    }
}

- (NSString *)formatSeconds:(NSNumber *)totalSeconds {
    NSInteger minutes = [totalSeconds integerValue] / 60;
    NSInteger seconds = [totalSeconds integerValue] % 60;
    return [NSString stringWithFormat:@"%.2ld:%.2ld", minutes, seconds];
}

#pragma mark - STKAudioPlayerDelegate

- (void)audioPlayer:(STKAudioPlayer *)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode {
    NSLog(@"StreamingKit unexpected error: %ld", (long)errorCode);
}

- (void)audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration {
    if (stopReason == STKAudioPlayerStopReasonEof) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FSHSoundEndedNotification" object:self.sound userInfo:nil];
    }
}

- (void)audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId {

}

- (void)audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId {

}

- (void)audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {
    self.view.playing = state == STKAudioPlayerStatePlaying;
    self.view.loading = state == STKAudioPlayerStateBuffering;
}

- (void)selectedSoundChanged:(FSHSound *)sound {
    self.sound = sound;
}

@end
