//
//  ReleaseNotesContentViewController.swift
//  Latest
//
//  Created by Max Langer on 12.08.18.
//  Copyright © 2018 Max Langer. All rights reserved.
//

import Cocoa

fileprivate let ReleaseNotesTextParagraphCellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "ReleaseNotesTextParagraphCellIdentifier")

/// The controller displaying the actual release notes
class ReleaseNotesTextViewController: NSViewController {

    /// The view displaying the release notes
    @IBOutlet var textView: NSTextView!
    
    /// Updates the view with the given release notes
    func set(_ string: NSAttributedString) {
        // Format the release notes
        let text = self.format(string)
        
        self.textView.textStorage?.setAttributedString(text)
    }
    
    /// Updates the text views scroll insets
    func updateInsets(with inset: CGFloat) {
        let scrollView = self.textView.enclosingScrollView
        
        scrollView?.automaticallyAdjustsContentInsets = false
        scrollView?.contentInsets.top = inset + 5 // 5 is some padding
        
        self.view.layout()
        scrollView?.documentView?.scroll(CGPoint(x: 0, y: -inset * 2))
    }
    
    // MARK: - Private Methods
    
    /**
     This method manipulates the release notes to make them look uniform.
     All custom fonts and font sizes are removed for a more unified look. Specific styles like bold or italic parts as well as links are preserved.
     - parameter attributedString: The string to be formatted
     - returns: The formatted string
     */
    private func format(_ attributedString: NSAttributedString) -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: attributedString)
        let fullRange = NSMakeRange(0, attributedString.length)
        let defaultFont = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        
        /// Remove all color
        string.removeAttribute(.foregroundColor, range: fullRange)
        string.addAttribute(.foregroundColor, value: NSColor.labelColor, range: fullRange)
        
        /// Reset font
        string.removeAttribute(.font, range: fullRange)
        string.addAttribute(.font, value: defaultFont, range: fullRange)
        
        // Copy traits like italic and bold
        attributedString.enumerateAttribute(NSAttributedString.Key.font, in: fullRange, options: .reverse) { (fontObject, range, stopPointer) in
            guard let font = fontObject as? NSFont else { return }
            
            let traits = font.fontDescriptor.symbolicTraits
            let fontDescriptor = defaultFont.fontDescriptor.withSymbolicTraits(traits)
            
            string.addAttribute(.font, value: NSFont(descriptor: fontDescriptor, size: defaultFont.pointSize)!, range: range)
        }
        
        return string
    }
    
}

extension ReleaseNotesTextViewController: ReleaseNotesContentProtocol {
    
    typealias ReleaseNotesContentController = ReleaseNotesTextViewController
    
    static var StoryboardIdentifier: String {
        return "ReleaseNotesTextViewControllerIdentifier"
    }
    
}
