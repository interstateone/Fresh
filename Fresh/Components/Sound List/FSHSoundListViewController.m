//
//  FSHSoundListViewController.m
//  Jeff
//
//  Created by Brandon on 2/21/2014.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "FSHSoundListViewController.h"

#import <RXCollections/RXCollection.h>
@import ReactiveCocoa;
@import Mantle;

#import "FSHSound.h"
#import "FSHSoundCellView.h"
#import "FSHAccount.h"
#import "BSRefreshableScrollView.h"
#import "FSHSoundListViewModel.h"
#import "FSHSoundRowView.h"

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
    [RACObserve(self, viewModel.numberOfSounds) subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];

    [RACObserve(self, viewModel.account.selectedSound) subscribeNext:^(id x) {
        @strongify(self);
        NSIndexSet *selectedRowIndexes = self.tableView.selectedRowIndexes;
        [self.tableView reloadData];
        [self.tableView selectRowIndexes:selectedRowIndexes byExtendingSelection:NO];
        [self.tableView scrollRowToVisible:self.viewModel.indexOfSelectedSound];
    }];

    [[self.viewModel updateSounds] subscribeCompleted:^{}];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)setViewModel:(FSHSoundListViewModel *)viewModel {
    _viewModel = viewModel;
    [[self.viewModel updateSounds] subscribeCompleted:^{}];
}

#pragma mark - BSRefreshableScrollViewDelegate

- (BOOL)scrollView:(BSRefreshableScrollView *)aScrollView startRefreshSide:(BSRefreshableScrollViewSide)refreshableSide {
    @weakify(self)
    if (refreshableSide == BSRefreshableScrollViewSideBottom) {
        [[self.viewModel fetchNextSounds] subscribeNext:^(id x) {
            @strongify(self)
            [self.soundsScrollView stopRefreshingSide:BSRefreshableScrollViewSideBottom];
        }];
    }
    else {
        [[self.viewModel updateSounds] subscribeNext:^(NSArray *sounds) {
            @strongify(self)
            [self.soundsScrollView stopRefreshingSide:BSRefreshableScrollViewSideTop];
        }];
    }
    return YES;
}

#pragma mark - Table View

- (void)rowWasDoubleClicked {
    [self.viewModel selectSoundAtIndex:[self.tableView clickedRow]];
}

- (void)keyDown:(NSEvent *)theEvent {
    if ([theEvent keyCode] == 13 || [theEvent keyCode] == 36) {
        [self.viewModel selectSoundAtIndex:[self.tableView selectedRow]];
        return;
    }
    else {
        [super keyDown:theEvent];
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.viewModel.numberOfSounds;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    return [self.viewModel soundAtIndex:row];
}

#pragma mark - NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    FSHSound *sound = [self.viewModel soundAtIndex:row];
    FSHSoundCellView *cell = [tableView makeViewWithIdentifier:NSStringFromClass([FSHSoundCellView class]) owner:self];
    
    [cell.trackNameField setStringValue:[self.viewModel titleForSoundAtIndex:row]];
    [cell.authorNameField setStringValue:[self.viewModel authorForSoundAtIndex:row]];
    cell.playing = [sound isEqual:self.viewModel.account.selectedSound];

    return cell;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[FSHSoundRowView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
}

@end
