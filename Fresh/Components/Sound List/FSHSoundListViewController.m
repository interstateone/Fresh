//
//  FSHSoundListViewController.m
//  Jeff
//
//  Created by Brandon on 2/21/2014.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHSoundListViewController.h"

@import ReactiveCocoa;
@import Mantle;

#import "FSHSound.h"
#import "FSHSoundCellView.h"
#import "FSHAccount.h"
#import "BSRefreshableScrollView.h"
#import "FSHSoundListPresenter.h"
#import "FSHSoundRowView.h"
#import "Fresh-Swift.h"

@interface FSHSoundListViewController () <NSTableViewDelegate, NSTableViewDataSource, BSRefreshableScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSTableView *tableView;
@property (weak, nonatomic) IBOutlet BSRefreshableScrollView *soundsScrollView;

@end

@implementation FSHSoundListViewController

- (void)loadView {
    [super loadView];

    self.soundsScrollView.refreshableSides = BSRefreshableScrollViewSideTop | BSRefreshableScrollViewSideBottom;

    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(rowWasDoubleClicked)];

    @weakify(self)
    [RACObserve(self, presenter.service.account.selectedSound) subscribeNext:^(id x) {
        @strongify(self);
        NSIndexSet *selectedRowIndexes = self.tableView.selectedRowIndexes;
        [self.tableView reloadData];
        [self.tableView selectRowIndexes:selectedRowIndexes byExtendingSelection:NO];
        [self.tableView scrollRowToVisible:self.presenter.indexOfSelectedSound];
    }];

    [self.presenter initializeView];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)setPresenter:(FSHSoundListPresenter *)presenter {
    _presenter = presenter;
    [[self.presenter updateSounds] subscribeCompleted:^{}];
}

- (void)setRowModels:(NSArray<SoundListRowModel *> *)rowModels {
    _rowModels = rowModels;
    [self.tableView reloadData];
}

#pragma mark - BSRefreshableScrollViewDelegate

- (BOOL)scrollView:(BSRefreshableScrollView *)aScrollView startRefreshSide:(BSRefreshableScrollViewSide)refreshableSide {
    @weakify(self)
    if (refreshableSide == BSRefreshableScrollViewSideBottom) {
        [[self.presenter fetchNextSounds] subscribeNext:^(id x) {
            @strongify(self)
            [self.soundsScrollView stopRefreshingSide:BSRefreshableScrollViewSideBottom];
        }];
    }
    else {
        [[self.presenter updateSounds] subscribeNext:^(NSArray *sounds) {
            @strongify(self)
            [self.soundsScrollView stopRefreshingSide:BSRefreshableScrollViewSideTop];
        }];
    }
    return YES;
}

#pragma mark - Table View

- (void)rowWasDoubleClicked {
    [self.presenter selectSoundAtIndex:[self.tableView clickedRow]];
}

- (void)keyDown:(NSEvent *)theEvent {
    if ([theEvent keyCode] == 13 || [theEvent keyCode] == 36) {
        [self.presenter selectSoundAtIndex:[self.tableView selectedRow]];
        return;
    }
    else {
        [super keyDown:theEvent];
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.rowModels.count;
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    SoundListRowModel *rowModel = self.rowModels[row];
    FSHSoundCellView *cell = [tableView makeViewWithIdentifier:NSStringFromClass([FSHSoundCellView class]) owner:self];
    
    [cell.trackNameField setStringValue:rowModel.title];
    [cell.authorNameField setStringValue:rowModel.author];
    cell.playing = row == self.presenter.indexOfSelectedSound;

    return cell;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[FSHSoundRowView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
}

@end
