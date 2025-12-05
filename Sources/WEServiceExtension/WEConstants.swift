//
//  WEConstants.swift
//  WEServiceExtension
//
//  Created by Shubham Naidu on 23/03/25.
//

import Foundation
struct WEConstants{
    
    // MARK: - Constants
    static let WEX_SERVICE_EXTENSION_VERSION = "1.2.0"
    static let WEX_TRACK_IP_LOCATION = "WEGTrackIPLocation"
    static let WEX_PROXY_URL = "proxy_url"
    static let WEX_LICENSE_CODE = "license_code"
    static let WEX_INTERFACE_ID = "interface_id"
    static let WEX_SDK_VERSION = "sdk_version"
    static let WEX_APP_ID = "app_id"
    static let WEX_ENVIRONMENT = "environment"
    static let WEX_EVENT_NAME = "event_name"
    static let WEX_CATEGORY = "category"
    static let WEX_SUID = "suid"
    static let WEX_LUID = "luid"
    static let WEX_CUID = "cuid"
    static let WEX_EVENT_TIME = "event_time"
    static let WEX_EVENT_DATA = "event_data"
    static let WEX_SYSTEM_DATA = "system_data"
    static let WEX_SDK_ID = "sdk_id"
    static let WEX_EXPERIMENT_ID = "experiment_id"
    static let WEX_NOTIFICATION_ID = "notification_id"
    static let KEY_DEBUGGER_EVENT_SYNC_URL = "debugger_event_sync_url"
    static let WE_SERVICE_EXTENSION = "WEServiceExtension"
    
    /// Keys for notification payload
    static let WEX_CUSTOM_DATA = "customData"
    static let WEX_KEY = "key"
    static let WEX_VALUE = "value"
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
