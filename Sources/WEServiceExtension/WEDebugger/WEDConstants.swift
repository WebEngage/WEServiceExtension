//
//  WEDConstants.swift
//  WEServiceExtension
//
//  Central configuration for debugger constants.
//

import Foundation

// MARK: - Debugger Constants

struct WEDConstants {
    
    // MARK: Shared UserDefaults Keys
    static let KEY_DEBUGGER_EVENT_SYNC_URL = "debugger_event_sync_url"
    static let KEY_DEBUGGER_AUTH_TOKEN = "debugger_auth_token"
    
    // MARK: Identifiers
    static let WE_SERVICE_EXTENSION = "WEServiceExtension"
    static let PUSH_TOKEN_TYPE = "apns"
    
    // MARK: Notification Payload Keys
    static let KEY_NOTIFICATION_ID = "notification_id"
    
    // MARK: Event Names
    static let EVENT_PUSH_RECEIVED              = "push_notification_received"
    static let EVENT_PUSH_RENDERED              = "push_notification_rendered"
    static let EVENT_PUSH_IMAGE_DOWNLOAD_STARTED = "push_image_download_started"
    static let EVENT_PUSH_IMAGE_DOWNLOAD_SUCCESS = "push_image_download_success"
    static let EVENT_PUSH_IMAGE_DOWNLOAD_FAILED  = "push_image_download_failed"
    static let EVENT_PUSH_TRACKER_SENT          = "push_tracker_event_sent"
    static let EVENT_PUSH_TRACKER_FAILED        = "push_tracker_event_failed"
    static let EVENT_PUSH_EXTENSION_EXPIRED     = "push_extension_time_expired"
}

// MARK: - Log Level

@objc public enum WEGLogLevel: Int {
    case debug, info, warning, error, critical
    
    public var description: String {
        switch self {
        case .debug: return "debug"
        case .info: return "info"
        case .warning: return "warning"
        case .error: return "error"
        case .critical: return "critical"
        }
    }
}
