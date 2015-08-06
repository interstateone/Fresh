//
//  FSHAccount 
//  Fresh
//
//  Created by brandon on 2014-03-12.
//  Copyright (c) 2014 Robots and Pencils Inc. All rights reserved.
//

@class RACSignal;
@class FSHSound;

@interface FSHAccount : NSObject

@property (strong, nonatomic) NSArray *sounds;
@property (strong, nonatomic) FSHSound *selectedSound;
@property (assign, nonatomic, readonly) BOOL isLoggedIn;

+ (instancetype)currentAccount;

- (void)logIn;
- (RACSignal *)updateSounds;
- (RACSignal *)fetchNextSounds;

@end
