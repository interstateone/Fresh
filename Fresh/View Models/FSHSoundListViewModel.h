//
//  FSHSoundListViewModel.h
//  Fresh
//
//  Created by Brandon on 2014-03-29.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

@class FSHAccount;
@class FSHSound;
@class RACSignal;

@interface FSHSoundListViewModel : NSObject

@property (nonatomic, strong) FSHAccount *account;

@property (nonatomic, assign) NSInteger numberOfSounds;

- (instancetype)initWithAccount:(FSHAccount *)account;

- (FSHSound *)soundAtIndex:(NSInteger)index;
- (NSString *)titleForSoundAtIndex:(NSInteger)index;
- (NSString *)authorForSoundAtIndex:(NSInteger)index;

- (RACSignal *)updateSounds;
- (void)selectSoundAtIndex:(NSInteger)index;

@end
