//
//  PopoverContentViewController.m
//  Jeff
//
//  Created by Brandon on 2/21/2014.
//  Copyright (c) 2014 Brandon Evans. All rights reserved.
//

#import "PopoverContentViewController.h"

#import <RXCollections/RXCollection.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <libextobjc/EXTScope.h>
#import <MTLJSONAdapter.h>

#import "FSHSound.h"
#import "FSHSoundCellView.h"
#import "NSView+RACProperties.h"
#import "NSImageView+AFNetworking.h"
#import "STKAudioPlayer.h"
#import "FSHAccount.h"
#import "BSRefreshableScrollView.h"
#import "FSHSoundListViewModel.h"
#import "FSHSoundRowView.h"

@interface PopoverContentViewController () <NSTableViewDelegate, NSTableViewDataSource, BSRefreshableScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSTableView *tableView;
@property (weak, nonatomic) IBOutlet BSRefreshableScrollView *soundsScrollView;

@property (nonatomic, strong) FSHSound *selectedSound;

@end

@implementation PopoverContentViewController

- (void)loadView {
    [super loadView];

    self.soundsScrollView.refreshableSides = BSRefreshableScrollViewSideTop | BSRefreshableScrollViewSideBottom;

    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(rowWasDoubleClicked)];

    [self updateDashboardWithCompletion:nil];
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (void)setViewModel:(FSHSoundListViewModel *)viewModel {
    _viewModel = viewModel;
    [self updateDashboardWithCompletion:nil];

    [RACObserve(self.viewModel, numberOfSounds) subscribeNext:^(id x) {
        [self.tableView reloadData];
    }];
}

#pragma mark - Private

- (void)updateDashboardWithCompletion:(dispatch_block_t)completion {
    [[self.viewModel updateSounds] subscribeNext:^(NSArray *sounds) {
        if (completion) completion();
    }];
}

#pragma mark - BSRefreshableScrollViewDelegate

- (BOOL)scrollView:(BSRefreshableScrollView *)aScrollView startRefreshSide:(BSRefreshableScrollViewSide)refreshableSide {
    if (refreshableSide == BSRefreshableScrollViewSideBottom) {
        [[self.viewModel fetchNextSounds] subscribeNext:^(id x) {
            [self.soundsScrollView stopRefreshingSide:BSRefreshableScrollViewSideBottom];
        }];
    }
    else {
        [self updateDashboardWithCompletion:^{
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
    FSHSoundCellView *cell = [tableView makeViewWithIdentifier:NSStringFromClass([FSHSoundCellView class]) owner:self];
    
    [cell.trackNameField setStringValue:[self.viewModel titleForSoundAtIndex:row]];
    [cell.authorNameField setStringValue:[self.viewModel authorForSoundAtIndex:row]];

    return cell;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    return [[FSHSoundRowView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
}

@end
