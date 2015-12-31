//
//  FSHNowPlayingPresenter.m
//  Fresh
//
//  Created by Brandon on 2014-03-27.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHNowPlayingPresenter.h"

#import <StreamingKit/STKAudioPlayer.h>
@import ReactiveCocoa;

#import "FSHAccount.h"
#import "Fresh-Swift.h"

@interface FSHNowPlayingPresenter () <STKAudioPlayerDelegate>

@property (nonatomic, strong) STKAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *tickTimer;

@end

@implementation FSHNowPlayingPresenter

- (void)setSound:(FSHSound *)sound {
    _sound = sound;

    _audioPlayer = [[STKAudioPlayer alloc] init];
    _audioPlayer.delegate = self;

    RAC(self, playing) = [RACObserve(self, audioPlayer.state) map:^id(NSNumber *state){
        return @([state integerValue] == STKAudioPlayerStatePlaying);
    }];

    RAC(self, loading) = [RACObserve(self, audioPlayer.state) map:^id(NSNumber *state){
        return @([state integerValue] == STKAudioPlayerStateBuffering);
    }];

    RAC(self, permalinkURL) = RACObserve(self, sound.permalinkURL);

    RAC(self, title) = RACObserve(self, sound.title);

    RAC(self, author) = RACObserve(self, sound.author);

    RAC(self, waveform) = [RACObserve(self, sound) flattenMap:^RACStream *(FSHSound *sound) {
        return [sound fetchWaveform];
    }];

    RAC(self, favorite, @NO) = RACObserve(self, sound.favorite);

    [RACObserve(self, sound) subscribeNext:^(FSHSound *sound) {
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

    RAC(self, hidden, @YES) = [RACObserve(self, sound) map:^id(FSHSound *sound) {
        return @(!sound);
    }];

    RAC(self, formattedDuration) = [RACObserve(self, duration) map:^id(NSNumber *duration) {
        return [self formatSeconds:duration];
    }];

    RAC(self, formattedProgress) = [RACObserve(self, progress) map:^id(NSNumber *progress) {
        return [self formatSeconds:progress];
    }];

    // Setup commands
    _toggleCurrentSound = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        if (!self.sound) return [RACSignal empty];
        if (self.audioPlayer.state == STKAudioPlayerStatePlaying) {
            [self.audioPlayer pause];
        }
        else {
            [self.audioPlayer resume];
        }
        return [RACSignal empty];
    }];

    _toggleFavorite = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        [self.sound toggleFavorite];
        return [RACSignal empty];
    }];
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

}

- (void)selectedSoundChanged:(FSHSound *)sound {
    self.sound = sound;
}

@end
