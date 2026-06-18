//
//  WEDebugger.swift
//  WEServiceExtension
//
//  Thin public facade for backward compatibility.
//  Actual logic lives in WEDEventBuilder, WEDEventQueue, and WEDLogProcessor.
//

import Foundation
import UserNotifications

// MARK: - Public Facade

/// Public entry point for queueing and flushing debugger events.
struct WEXDebugger {
    
    /// Queues an event for delivery.
    static func queueEvent(_ event: [String: Any]) {
        WEDEventQueue.enqueue(event)
    }
    
    /// Flushes all queued events immediately. Call before extension terminates.
    static func flushEvents() {
        WEDEventQueue.flush()
    }
}
