//
//  FSHSound.h
//  Fresh
//
//  Created by Brandon on 2014-03-09.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import <Mantle/MTLModel.h>
#import <Mantle/MTLJSONAdapter.h>
#import <ReactiveCocoa/RACSignal.h>

typedef void (^FSHSoundStreamURLBlock)(NSURL *streamURL, NSError *error);

@interface FSHSound : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic) NSString *trackID;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *author;
@property (strong, nonatomic) NSURL *streamURL;
@property (strong, nonatomic) NSURL *playURL;
@property (assign, nonatomic) BOOL streamable;
@property (assign, nonatomic) NSNumber *duration;
@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSURL *artworkURL;
@property (strong, nonatomic) NSURL *waveformURL;
@property (strong, nonatomic) NSURL *permalinkURL;
@property (assign, nonatomic) BOOL favorite;

- (RACSignal *)fetchPlayURL;
- (RACSignal *)fetchWaveformImage;
- (void)toggleFavorite;

@end
