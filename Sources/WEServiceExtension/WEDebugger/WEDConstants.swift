//
//  WEDConstants.swift
//  WEServiceExtension
//
//  Created by Shubham Naidu on 07/12/25.
//

import Foundation

struct WEDConstants {
    
    static let KEY_DEBUGGER_EVENT_SYNC_URL = "debugger_event_sync_url"
    static let WE_SERVICE_EXTENSION = "WEServiceExtension"
    
    // Event keys
    static let KEY_NOTIFICATION_ID = "notification_id"
    static let KEY_SDK_VERSION = "sdk_version"
    static let KEY_MESSAGE = "message"
    static let KEY_TAG = "tag"
    static let KEY_METADATA = "metadata"
    
    // Tag names
    static let TAG_PUSH_NOTIFICATION = "Push Notification"
    static let TAG_CAMPAIGN_ID = "Campaign_id"
    
    // Event names
    static let EVENT_SERVICE_EXTENSION = "Service Extension"
    static let EVENT_SERVICE_EXTENSION_EVENT = "Service Extension Event"
    
    // Messages
    static let MSG_DEBUGGER_DATA_SENT = "Debugger Data sent"
    
}


@objc public enum WEGLogLevel: Int {
    case debug, info, warning, error, critical
    
    var description: String {
        switch self {
        case .debug: return "debug"
        case .info: return "info"
        case .warning: return "warning"
        case .error: return "error"
        case .critical: return "critical"
        }
    }
}
