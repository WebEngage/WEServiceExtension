//
//  WEDEventBuilder.swift
//  WEServiceExtension
//
//  Responsible for constructing debug event payloads.
//

import Foundation
import UserNotifications

// MARK: - Event Builder

struct WEDEventBuilder {
    
    /// Constructs a debug event dictionary ready to be sent to the server.
    ///
    /// - Parameters:
    ///   - eventName: Human-readable event identifier
    ///   - level: Log level (info, warning, error, etc.)
    ///   - message: Short log message (typically campaign_id)
    ///   - tags: Array of tag dictionaries built via `WEDTagBuilder`
    ///   - deliveryStatus: Push delivery status (delivered / failed)
    ///   - notification: The notification content for extracting push & campaign metadata
    /// - Returns: A complete event dictionary, or nil if shared defaults are unavailable
    static func build(
        eventName: String,
        level: WEGLogLevel = .info,
        message: String = "",
        tags: [[String: Any]] = [],
        deliveryStatus: String = "delivered",
        notification: UNMutableNotificationContent? = nil
    ) -> [String: Any]? {
        
        guard let sharedData = Utils.getDataFromSharedUserDefaults(),
              let defaults = Utils.getSharedUserDefaults() else {
            return nil
        }
        
        // Base event structure (matches tracker format)
        var event: [String: Any] = [
            "event_name": eventName,
            "category": "system",
            "suid": "null",
            "luid": "null",
            "cuid": "null",
            "event_time": Utils.getCurrentFormattedTime(),
            "license_code": sharedData[WEConstants.WEX_LICENSE_CODE] ?? "",
            "interface_id": sharedData[WEConstants.WEX_INTERFACE_ID] ?? "",
            "event_data": "",
            "isDebugLog": true,
            "log_level": level.description
        ]
        
        // System data
        var systemData: [String: Any] = [
            "app_id": sharedData[WEConstants.WEX_APP_ID] ?? "",
            "sdk_id": 3
        ]
        if let version = sharedData[WEConstants.WEX_SDK_VERSION] as? String, let intVal = Int(version) {
            systemData["sdk_version"] = intVal
        }
        event["system_data"] = systemData
        
        // Push metadata
        event["push"] = [
            "token": defaults.string(forKey: "apns_token") ?? "",
            "token_type": WEDConstants.PUSH_TOKEN_TYPE,
            "delivery_status": deliveryStatus,
            "extension_name": WEDConstants.WE_SERVICE_EXTENSION,
            "extension_version": WEConstants.WEX_SERVICE_EXTENSION_VERSION
        ]
        
        // Debug payload
        event["debug"] = [
            "log_level": level.description,
            "log": message,
            "onlydebug": 1,
            "tags": tags
        ]
        
        return event
    }
    
    /// Extracts campaign metadata from notification userInfo for use in debug tags.
    static func campaignMetadata(from notification: UNMutableNotificationContent?) -> [String: Any] {
        guard let userInfo = notification?.userInfo else { return ["channel": "push"] }
        
        var meta: [String: Any] = ["channel": "push"]
        
        if let id = userInfo[WEConstants.WEX_NOTIFICATION_ID] as? String {
            meta["id"] = id
        }
        if let variationId = userInfo[WEConstants.WEX_EXPERIMENT_ID] as? String {
            meta["variation_id"] = variationId
        }
        if let expandable = userInfo["expandableDetails"] as? [String: Any],
           let style = expandable["style"] as? String {
            meta["layout_id"] = style
        }
        
        return meta
    }
}
