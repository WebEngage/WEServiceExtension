//
//  WEDLogProcessor.swift
//  WEServiceExtension
//
//  Public API for logging debugger events from the Service Extension.
//  Each method creates a structured event and queues it for delivery.
//

import Foundation
import UserNotifications

// MARK: - Log Processor (Public API)

@objcMembers
public class WEXLogProcessor: NSObject {
    
    // MARK: - Push Lifecycle Events
    
    /// Logs when a push notification is received by the Service Extension.
    public static func logReceivedNotification(
        loglevel: WEGLogLevel,
        message: Any,
        notification: UNMutableNotificationContent?
    ) {
        guard WEDUtils.isDebuggerEnabled() else { return }
        
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)
        let campaignId = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        
        let tags = WEDTagBuilder.create()
            .addTag("push_notification", metadata: [loglevel.description: userInfo])
            .addTag("campaign", metadata: WEDEventBuilder.campaignMetadata(from: notification))
            .addTag("service_extension", metadata: [
                loglevel.description: [
                    "sdk_version": WEConstants.WEX_SERVICE_EXTENSION_VERSION,
                    "message": message
                ]
            ])
            .build()
        
        submit(
            eventName: WEDConstants.EVENT_PUSH_RECEIVED,
            level: loglevel,
            message: campaignId,
            tags: tags,
            deliveryStatus: "delivered",
            notification: notification
        )
    }
    
    /// Logs when the notification is successfully rendered (contentHandler called).
    public static func logNotificationRendered(notification: UNMutableNotificationContent?) {
        guard WEDUtils.isDebuggerEnabled() else { return }
        
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)
        let campaignId = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        
        let tags = WEDTagBuilder.create()
            .addTag("push_notification", metadata: [WEGLogLevel.info.description: userInfo])
            .addTag("campaign", metadata: WEDEventBuilder.campaignMetadata(from: notification))
            .addTag("service_extension", metadata: [
                WEGLogLevel.info.description: [
                    "sdk_version": WEConstants.WEX_SERVICE_EXTENSION_VERSION,
                    "message": "Notification rendered successfully"
                ]
            ])
            .build()
        
        submit(
            eventName: WEDConstants.EVENT_PUSH_RENDERED,
            level: .info,
            message: "Rendered \(campaignId)",
            tags: tags,
            deliveryStatus: "delivered",
            notification: notification
        )
    }
    
    /// Logs when the Service Extension time limit expires (30s).
    public static func logServiceExtensionExpired(notification: UNMutableNotificationContent?) {
        guard WEDUtils.isDebuggerEnabled() else { return }
        
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)
        let campaignId = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        
        let tags = WEDTagBuilder.create()
            .addTag("push_notification", metadata: [WEGLogLevel.warning.description: userInfo])
            .addTag("campaign", metadata: WEDEventBuilder.campaignMetadata(from: notification))
            .addTag("service_extension", metadata: [
                WEGLogLevel.warning.description: [
                    "sdk_version": WEConstants.WEX_SERVICE_EXTENSION_VERSION,
                    "message": "Service Extension time expired"
                ]
            ])
            .build()
        
        submit(
            eventName: WEDConstants.EVENT_PUSH_EXTENSION_EXPIRED,
            level: .warning,
            message: "Time Expired \(campaignId)",
            tags: tags,
            deliveryStatus: "failed",
            notification: notification
        )
    }
    
    // MARK: - Image Download Events
    
    /// Logs when an image download starts.
    public static func logImageDownloading(
        loglevel: WEGLogLevel,
        message: Any,
        notification: UNMutableNotificationContent?
    ) {
        guard WEDUtils.isDebuggerEnabled() else { return }
        
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)
        let campaignId = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        
        let tags = WEDTagBuilder.create()
            .addTag("push_notification", metadata: [loglevel.description: userInfo])
            .addTag("campaign", metadata: WEDEventBuilder.campaignMetadata(from: notification))
            .addTag("resource_download", metadata: [
                loglevel.description: [
                    "sdk_version": WEConstants.WEX_SERVICE_EXTENSION_VERSION,
                    "message": message
                ]
            ])
            .build()
        
        submit(
            eventName: WEDConstants.EVENT_PUSH_IMAGE_DOWNLOAD_STARTED,
            level: loglevel,
            message: campaignId,
            tags: tags,
            deliveryStatus: "delivered",
            notification: notification
        )
    }
    
    /// Logs when an image download succeeds.
    public static func logImageDownloadSuccess(
        message: Any,
        notification: UNMutableNotificationContent?
    ) {
        guard WEDUtils.isDebuggerEnabled() else { return }
        
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)
        let campaignId = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        
        let tags = WEDTagBuilder.create()
            .addTag("push_notification", metadata: [WEGLogLevel.info.description: userInfo])
            .addTag("campaign", metadata: WEDEventBuilder.campaignMetadata(from: notification))
            .addTag("resource_download", metadata: [
                WEGLogLevel.info.description: [
                    "sdk_version": WEConstants.WEX_SERVICE_EXTENSION_VERSION,
                    "message": message
                ]
            ])
            .build()
        
        submit(
            eventName: WEDConstants.EVENT_PUSH_IMAGE_DOWNLOAD_SUCCESS,
            level: .info,
            message: "Image Downloaded \(campaignId)",
            tags: tags,
            deliveryStatus: "delivered",
            notification: notification
        )
    }
    
    /// Logs when an image download fails.
    public static func logImageDownloadingFailed(
        loglevel: WEGLogLevel,
        message: Any,
        notification: UNMutableNotificationContent?
    ) {
        guard WEDUtils.isDebuggerEnabled() else { return }
        
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)
        let campaignId = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        
        let tags = WEDTagBuilder.create()
            .addTag("push_notification", metadata: [loglevel.description: ""])
            .addTag("campaign", metadata: WEDEventBuilder.campaignMetadata(from: notification))
            .addTag("service_extension", metadata: [
                loglevel.description: [
                    "sdk_version": WEConstants.WEX_SERVICE_EXTENSION_VERSION,
                    "message": message
                ]
            ])
            .build()
        
        submit(
            eventName: WEDConstants.EVENT_PUSH_IMAGE_DOWNLOAD_FAILED,
            level: loglevel,
            message: "Image Download Failed \(campaignId)",
            tags: tags,
            deliveryStatus: "failed",
            notification: notification
        )
    }
    
    // MARK: - Tracker Events
    
    /// Logs when a tracker event (received/view) is sent successfully.
    public static func logtrackEvent(
        loglevel: WEGLogLevel,
        event: Any,
        notification: UNMutableNotificationContent?
    ) {
        guard WEDUtils.isDebuggerEnabled() else { return }
        
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)
        let campaignId = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        
        let tags = WEDTagBuilder.create()
            .addTag("push_notification", metadata: userInfo)
            .addTag("campaign", metadata: WEDEventBuilder.campaignMetadata(from: notification))
            .addTag("service_extension", metadata: [
                loglevel.description: [
                    "sdk_version": WEConstants.WEX_SERVICE_EXTENSION_VERSION,
                    "message": event
                ]
            ])
            .build()
        
        submit(
            eventName: WEDConstants.EVENT_PUSH_TRACKER_SENT,
            level: loglevel,
            message: campaignId,
            tags: tags,
            deliveryStatus: "delivered",
            notification: notification
        )
    }
    
    /// Logs when a tracker event fails to send.
    public static func logTrackEventFailed(
        eventName: String,
        error: Any,
        notification: UNMutableNotificationContent?
    ) {
        guard WEDUtils.isDebuggerEnabled() else { return }
        
        let userInfo = WEDUtils.convertUserInfoToDictionary(notification)
        let campaignId = userInfo[WEDConstants.KEY_NOTIFICATION_ID] as? String ?? ""
        
        let tags = WEDTagBuilder.create()
            .addTag("push_notification", metadata: userInfo)
            .addTag("campaign", metadata: WEDEventBuilder.campaignMetadata(from: notification))
            .addTag("service_extension", metadata: [
                WEGLogLevel.error.description: [
                    "sdk_version": WEConstants.WEX_SERVICE_EXTENSION_VERSION,
                    "message": "Failed to track \(eventName): \(error)"
                ]
            ])
            .build()
        
        submit(
            eventName: WEDConstants.EVENT_PUSH_TRACKER_FAILED,
            level: .error,
            message: "Track Event Failed \(campaignId)",
            tags: tags,
            deliveryStatus: "failed",
            notification: notification
        )
    }
    
    // MARK: - Private Helper
    
    private static func submit(
        eventName: String,
        level: WEGLogLevel,
        message: String,
        tags: [[String: Any]],
        deliveryStatus: String,
        notification: UNMutableNotificationContent?
    ) {
        guard let event = WEDEventBuilder.build(
            eventName: eventName,
            level: level,
            message: message,
            tags: tags,
            deliveryStatus: deliveryStatus,
            notification: notification
        ) else { return }
        
        WEDEventQueue.enqueue(event)
    }
}
