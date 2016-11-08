//
//  PreferencesController.swift
//  Click
//
//  Created by Matthew Cheok on 2/11/16.
//  Copyright © 2016 Matthew Cheok. All rights reserved.
//

import Cocoa
import ServiceManagement

enum PreferenceKey: String {
  case quality
  case saveUrl
  case recordShortcut
  case finishShortcut
  
  var keyPath: String {
    return "values.\(self.rawValue)"
  }
}

protocol PreferencesControllerDelegate: class {
  func preferencesController(didUpdateShortcut identifier: String)
}

class PreferencesController: NSWindowController, SRRecorderControlDelegate, SRValidatorDelegate {
  
  @IBOutlet var qualityLabel: NSTextField!
  @IBOutlet var qualityButton: NSPopUpButton!
  @IBOutlet var mediaLabel: NSTextField!
  @IBOutlet var mediaButton: NSButton!
  @IBOutlet var recordLabel: NSTextField!
  @IBOutlet var recordControl: SRRecorderControl!
  @IBOutlet var finishLabel: NSTextField!
  @IBOutlet var finishControl: SRRecorderControl!
  @IBOutlet var loginCheckbox: NSButton!
  
  var shortcutValidator: SRValidator!
  @IBOutlet var qualityValuesController: NSArrayController!
  
  weak var delegate: PreferencesControllerDelegate?
  
  override var windowNibName: String? {
    return "PreferencesController"
  }

  override func windowDidLoad() {
    super.windowDidLoad()
    qualityValuesController.add(contentsOf: WindowRecorder.Quality.allValues)

    qualityButton.bind(NSSelectedValueBinding, to: NSUserDefaultsController.shared(), withKeyPath: PreferenceKey.quality.keyPath, options: nil)
    mediaButton.bind(NSTitleBinding, to: NSUserDefaultsController.shared(), withKeyPath: PreferenceKey.saveUrl.keyPath, options: nil)
    recordControl.bind(NSValueBinding, to: NSUserDefaultsController.shared(), withKeyPath: PreferenceKey.recordShortcut.keyPath, options: nil)
    finishControl.bind(NSValueBinding, to: NSUserDefaultsController.shared(), withKeyPath: PreferenceKey.finishShortcut.keyPath, options: nil)
    shortcutValidator = SRValidator(delegate: self)
    
    self.window?.center()
    self.window?.makeKeyAndOrderFront(nil)
    NSApp.activate(ignoringOtherApps: true)
  }
  
  @IBAction func selectSaveDestination(_ sender: NSButton) {
    let openPanel = NSOpenPanel()
    openPanel.canChooseFiles = false
    openPanel.canChooseDirectories = true
    openPanel.allowsMultipleSelection = false
    openPanel.beginSheetModal(for: window!) {
      (response) in
      if response == NSFileHandlingPanelOKButton {
        guard let result = openPanel.urls.first else {
          return
        }
        UserDefaults.standard.set(result, forKey: PreferenceKey.saveUrl.rawValue)
      }
    }
  }
  
  // MARK: - SRRecorderControlDelegate
  
  func shortcutRecorderShouldBeginRecording(_ aRecorder: SRRecorderControl!) -> Bool {
    PTHotKeyCenter.shared().pause()
    return true
  }
  
  func shortcutRecorderDidEndRecording(_ aRecorder: SRRecorderControl!) {
    PTHotKeyCenter.shared().resume()
  }
  
  func shortcutRecorder(_ aRecorder: SRRecorderControl!, canRecordShortcut aShortcut: [AnyHashable : Any]!) -> Bool {
    guard let shortcut = aShortcut else {
      return false
    }
    
    do {
      try shortcutValidator.isKeyCode(shortcut[SRShortcutKeyCode] as! UInt16, andFlagsAvailable: NSEventModifierFlags(rawValue: shortcut[SRShortcutModifierFlagsKey] as! UInt))
    } catch {
      self.presentError(error, modalFor: window!, delegate: nil, didPresent: nil, contextInfo: nil)
      return false
    }
    
    return true
  }
  
  // MARK: - SRValidatorDelegate
  
  func shortcutValidator(_ aValidator: SRValidator!, isKeyCode aKeyCode: UInt16, andFlagsTaken aFlags: NSEventModifierFlags, reason outReason: AutoreleasingUnsafeMutablePointer<NSString?>!) -> Bool {
    guard let recorderControl = self.window?.firstResponder as? SRRecorderControl else {
      return false
    }
    
    guard let shortcut = SRShortcutWithCocoaModifierFlagsAndKeyCode(aFlags, aKeyCode) else {
      return false
    }
    
    if
      isShortcutTaken(shortcut: shortcut, thisControl: recorderControl, otherControl: recordControl) ||
      isShortcutTaken(shortcut: shortcut, thisControl: recorderControl, otherControl: finishControl)
    {
      outReason.pointee = "it is already used. First remove or change the other shortcut"
      return true
    }
    
    return false
  }
  
  func isShortcutTaken(shortcut: [AnyHashable: Any], thisControl: SRRecorderControl,  otherControl: SRRecorderControl) -> Bool {
    return thisControl != otherControl && SRShortcutEqualToShortcut(shortcut, otherControl.objectValue)
  }
  
}
