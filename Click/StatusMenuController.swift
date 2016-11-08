//
//  StatusMenuController.swift
//  Click
//
//  Created by Matthew Cheok on 2/11/16.
//  Copyright © 2016 Matthew Cheok. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject, SessionControllerDelegate {
  @IBOutlet weak var statusMenu: NSMenu!
  @IBOutlet weak var recordMenuItem: NSMenuItem!
  @IBOutlet weak var sessionController: SessionController!

  let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
  var preferencesController: PreferencesController?
  
  private var recordUpdateTimer: DispatchSourceTimer?
  private let recordUpdateQueue = DispatchQueue(label: "com.matthewcheok.click", attributes: .concurrent)

  override func awakeFromNib() {
    statusItem.image = NSImage(named: "status-menu-icon")
    statusItem.menu = statusMenu
    sessionController.delegate = self
    setupShortcuts()
  }
  
  func setupShortcuts() {
    let defaults = NSUserDefaultsController.shared()
    defaults.addObserver(self, forKeyPath: PreferenceKey.recordShortcut.keyPath, options: .initial, context: nil)
    defaults.addObserver(self, forKeyPath: PreferenceKey.finishShortcut.keyPath, options: .initial, context: nil)
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    guard let keyPath = keyPath else {
      return
    }
    
    if
      keyPath == PreferenceKey.recordShortcut.keyPath ||
      keyPath == PreferenceKey.finishShortcut.keyPath {
      let hotKeyCenter = PTHotKeyCenter.shared()!
      if let oldHotKey = hotKeyCenter.hotKey(withIdentifier: keyPath) {
        hotKeyCenter.unregisterHotKey(oldHotKey)
      }
      
      guard
        let defaults = object as? NSUserDefaultsController,
        let newShortcut = defaults.value(forKeyPath: keyPath) as? [AnyHashable: Any] else {
          return
      }
      
      let selector: Selector
      switch keyPath {
      case PreferenceKey.recordShortcut.keyPath:
        selector = #selector(StatusMenuController.handleRecord(_:))
      case PreferenceKey.finishShortcut.keyPath:
        selector = #selector(StatusMenuController.handleFinish(_:))
      default:
        fatalError()
      }
      
      guard let newHotKey = PTHotKey(identifier: keyPath, keyCombo: newShortcut, target: self, action:selector) else {
        return
      }
      hotKeyCenter.register(newHotKey)
    } else {
      super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
  }
  
  @IBAction func handleRecord(_ sender: NSMenuItem) {
    switch sessionController.state {
    case .ready:
      sessionController.beginRecording()
    case .selecting:
      sessionController.cancelRecording()
    case .waiting:
      ()
    case .recording:
      sessionController.stopRecording()
    }
  }
  
  @IBAction func handleFinish(_ sender: NSMenuItem) {
    sessionController.stopRecording()
  }
  
  @IBAction func handlePreferences(_ sender: NSMenuItem) {
    preferencesController = PreferencesController()
    preferencesController?.showWindow(nil)
  }
  
  @IBAction func handleQuit(_ sender: NSMenuItem) {
    NSApplication.shared().terminate(self)
  }
  
  // MARK: - SessionControllerDelegate
  
  func sessionController(didUpdateTo state: SessionController.State) {
    recordMenuItem.isEnabled = true
    switch state {
    case .ready:
      recordMenuItem.title = "Record Window..."
      recordUpdateTimer?.cancel()
      recordUpdateTimer = nil
      statusItem.image = NSImage(named: "status-menu-icon")
      statusItem.title = nil
      
    case .selecting:
      recordMenuItem.title = "Cancel Selection..."
      statusItem.image = NSImage(named: "status-menu-icon")
      statusItem.title = nil
      
    case .waiting:
      recordMenuItem.isEnabled = false
      
    case .recording:
      statusItem.title = "0:00"
      statusItem.image = NSImage(named: "status-menu-icon-recording")
      recordMenuItem.title = "Stop Recording..."
      let startDate = Date()
      
      let timer = DispatchSource.makeTimerSource(flags: [], queue: recordUpdateQueue)
      timer.scheduleRepeating(wallDeadline: .now(), interval: .seconds(1))
      timer.setEventHandler(handler: {
        [statusItem]
        (timer) in
        let interval = Int(Date().timeIntervalSince(startDate))
        let seconds = interval % 60
        let minutes = interval / 60
        statusItem.title = String(format: "%d:%02d", minutes, seconds)
      })
      timer.resume()
      recordUpdateTimer = timer
    }
  }
}
