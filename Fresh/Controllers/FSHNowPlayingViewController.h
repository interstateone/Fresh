//
//  FSHNowPlayingViewController.h
//  Fresh
//
//  Created by Brandon on 2014-03-27.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

@class FSHNowPlayingViewModel;

@interface FSHNowPlayingViewController : NSTitlebarAccessoryViewController

@property (nonatomic, strong) FSHNowPlayingViewModel *viewModel;

- (instancetype)initWithViewModel:(FSHNowPlayingViewModel *)viewModel;

@end
