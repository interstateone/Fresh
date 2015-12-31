//
//  FSHSoundListViewController.h
//  Jeff
//
//  Created by Brandon on 2/21/2014.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

@class FSHAccount;
@class FSHSound;
@class FSHSoundListPresenter;
@class SoundListRowModel;

@interface FSHSoundListViewController : NSViewController

@property (nonatomic, strong) FSHSoundListPresenter *presenter;
@property (nonatomic, strong) NSArray<SoundListRowModel *> *rowModels;

@end
