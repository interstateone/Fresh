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

@protocol FSHSoundListView <NSObject>

@property (nonatomic, strong) NSArray<SoundListRowModel *> *rowModels;

@end

@interface FSHSoundListViewController : NSViewController <FSHSoundListView>

@property (nonatomic, strong) FSHSoundListPresenter *presenter;
@property (nonatomic, strong) NSArray<SoundListRowModel *> *rowModels;

@end
