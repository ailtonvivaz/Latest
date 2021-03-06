//
//  TouchBarHandling.swift
//  Latest
//
//  Created by Max Langer on 22.07.18.
//  Copyright © 2018 Max Langer. All rights reserved.
//

import Cocoa

/// The identifier used for the update item view
fileprivate let UpdateItemViewIdentifier = NSUserInterfaceItemIdentifier(rawValue: "com.max-langer.latest.update-item-identifier")

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    
    /// The identifier for the update scrubber bar
    static let updatesScrubber = NSTouchBarItem.Identifier(rawValue: "com.max-langer.latest.updates-scrubber")
    
}

@available(OSX 10.12.2, *)
/// An extension of the Updates Table View that handles the touchbar related methods
extension UpdateTableViewController: NSTouchBarDelegate {
 
    /// Returns the scrubber bar, if available
    var scrubber: NSScrubber? {
        return self.touchBar?.item(forIdentifier: .updatesScrubber)?.view as? NSScrubber
    }
    
    
    // MARK: Delegate
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        
        touchBar.defaultItemIdentifiers = [.updatesScrubber]
        touchBar.customizationAllowedItemIdentifiers = [.updatesScrubber]
        touchBar.principalItemIdentifier = .updatesScrubber
        touchBar.delegate = self
        
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case .updatesScrubber:
            let scrubber = NSScrubber()
            
            scrubber.register(UpdateItemView.self, forItemIdentifier: UpdateItemViewIdentifier)
            scrubber.mode = .free
            scrubber.showsArrowButtons = true
            scrubber.selectionBackgroundStyle = .roundedBackground
            scrubber.selectionOverlayStyle = .outlineOverlay
            scrubber.backgroundColor = NSColor.controlColor
            
            scrubber.dataSource = self
            scrubber.delegate = self
            
            let item = NSCustomTouchBarItem(identifier: identifier)
            item.view = scrubber
            
            return item
        default:
            ()
        }
        
        return nil
    }
    
}

@available(OSX 10.12.2, *)
/// An extension of the Updates Table View that handles the scrubber bar that displays all available updates
extension UpdateTableViewController: NSScrubberDataSource, NSScrubberDelegate, NSScrubberFlowLayoutDelegate {
    
    // MARK: Data Source
    
    func numberOfItems(for scrubber: NSScrubber) -> Int {
        let count = self.apps.count
        
        self.updateScrubberAppearance(with: count)
        
        return count
    }
    
    func scrubber(_ scrubber: NSScrubber, viewForItemAt index: Int) -> NSScrubberItemView {
        if self.apps.isSectionHeader(at: index) {
            return self.textViewForSection(at: index)
        }
        
        guard let view = scrubber.makeItem(withIdentifier: UpdateItemViewIdentifier, owner: nil) as? UpdateItemView else {
            return NSScrubberItemView()
        }
        
        let app = self.apps[index]
        
        view.textField.stringValue = app.name
        
        IconCache.shared.icon(for: app) { (image) in
            view.imageView.image = image
        }
        
        return view
    }
    
    
    // MARK: Delegate
    
    func scrubber(_ scrubber: NSScrubber, layout: NSScrubberFlowLayout, sizeForItemAt itemIndex: Int) -> NSSize {
        if self.apps.isSectionHeader(at: itemIndex) {
            return NSSize(width: 100, height: 30)
        }
        
        let size = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let name = self.apps[itemIndex].name as NSString
        let options: NSString.DrawingOptions = [.usesFontLeading, .usesLineFragmentOrigin]
        let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 0)]
        
        let textRect = name.boundingRect(with: size, options: options, attributes: attributes)
        
        var width = 16 // Spacing
        width += 30 // Image
        width += Int(textRect.size.width)
        
        return NSSize(width: width, height: 30)
    }
    
    func scrubber(_ scrubber: NSScrubber, didSelectItemAt selectedIndex: Int) {
        if self.apps.isSectionHeader(at: selectedIndex) {
            self.scrubber?.selectedIndex = self.tableView.selectedRow
            return
        }
        
        self.selectApp(at: selectedIndex)
    }
    
    private func updateScrubberAppearance(with count: Int) {
        self.scrubber?.isHidden = count == 0
        self.scrubber?.showsArrowButtons = count > 3
    }
    
    fileprivate func textViewForSection(at index: Int) -> NSScrubberTextItemView {
        let view = NSScrubberTextItemView()
        view.textField.stringValue = index == 0 ? NSLocalizedString("Available", comment: "") : NSLocalizedString("Installed", comment: "")
        return view
    }
    
}
