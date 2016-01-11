//
//  SoundListViewController.swift
//  Fresh
//
//  Created by Brandon Evans on 2015-12-30.
//  Copyright © 2015 Brandon Evans. All rights reserved.
//

import Cocoa
import ReactiveCocoa

protocol SoundListView {
    var rowModels: [SoundListRowModel] { get set }
}

class SoundListViewController: NSViewController, SoundListView, NSTableViewDelegate, NSTableViewDataSource {
    var presenter: SoundListPresenter?
    var rowModels = [SoundListRowModel]() {
        didSet {
            tableView.reloadData()
        }
    }

    @IBOutlet var tableView: NSTableView!
    @IBOutlet var soundsScrollView: BSRefreshableScrollView!

    override func loadView() {
        super.loadView()

        soundsScrollView.refreshableSides = UInt(BSRefreshableScrollViewSideTop | BSRefreshableScrollViewSideBottom)

        tableView.target = self
        tableView.doubleAction = "rowWasDoubleClicked"

        presenter?.initializeView()
    }

    override var acceptsFirstResponder: Bool {
        return true
    }

    func selectedSoundChanged(sound: Sound?) {
        guard let presenter = presenter else { return }
        let selectedRowIndexes = tableView.selectedRowIndexes
        tableView.reloadData()
        tableView.selectRowIndexes(selectedRowIndexes, byExtendingSelection: false)
        if let selectedSoundIndex = presenter.indexOfSelectedSound {
            tableView.scrollRowToVisible(selectedSoundIndex)
        }
    }

    // MARK: BSRefreshableScrollViewDelegate

    func scrollView(aScrollView: BSRefreshableScrollView!, startRefreshSide refreshableSide: UInt) -> Bool {
        if refreshableSide == UInt(BSRefreshableScrollViewSideBottom) {
            presenter?.fetchNextSounds().startWithCompleted { [weak self] in
                self?.soundsScrollView.stopRefreshingSide(UInt(BSRefreshableScrollViewSideBottom))
            }
        }
        else {
            presenter?.updateSounds().startWithCompleted { [weak self] in
                self?.soundsScrollView.stopRefreshingSide(UInt(BSRefreshableScrollViewSideTop))
            }
        }
        return true
    }

    func rowWasDoubleClicked() {
        presenter?.selectSoundAtIndex(tableView.clickedRow)
    }

    override func keyDown(theEvent: NSEvent) {
        if theEvent.keyCode == 13 || theEvent.keyCode == 36 {
            presenter?.selectSoundAtIndex(tableView.selectedRow)
        }
        else {
            super.keyDown(theEvent)
        }
    }

    // MARK: NSTableViewDataSource

    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return rowModels.count
    }

    // MARK: NSTableViewDelegate

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let rowModel = rowModels[row]
        guard let cell = tableView.makeViewWithIdentifier("SoundListCellView", owner: self) as? SoundListCellView else { return nil }
        
        cell.trackNameField.stringValue = rowModel.title
        cell.authorNameField.stringValue = rowModel.author
        cell.playing = (row == presenter?.indexOfSelectedSound ?? NSNotFound)
        
        return cell
    }

    func tableView(tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return FSHSoundRowView(frame:CGRect(x: 0, y: 0, width: 100, height: 44))
    }
}
