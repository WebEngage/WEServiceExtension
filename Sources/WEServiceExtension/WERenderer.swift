//
//  WERenderer.swift
//
//
//  Created by Shubham Naidu on 25/10/23.
//

import Foundation
import UserNotifications

/// A helper struct for rendering rich push notifications.
struct WERenderer {
    
    /// Handle the content for a specific notification style and image.
    ///
    /// - Parameters:
    ///   - style: The notification style.
    ///   - image: The image URL.
    ///   - bestAttemptContent: The best attempt notification content.
    ///   - contentHandler: A closure for handling the notification content.
    static func handleContentFor(style: String, image: String, bestAttemptContent: UNMutableNotificationContent?, contentHandler: ((UNNotificationContent) -> Void)?) {
        if (style == "BIG_PICTURE" || style == "RATING_V1" || style == "OVERLAY") && !image.isEmpty {
            drawBannerView(with: image, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
        } else {
            Network.trackEvent(completion: {
                if let bestAttemptContent = bestAttemptContent {
                    contentHandler?(bestAttemptContent)
                }
            },bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
        }
    }
    
    /// Draw a banner view for a notification with an image.
    ///
    /// - Parameters:
    ///   - urlStr: The image URL.
    ///   - bestAttemptContent: The best attempt notification content.
    ///   - contentHandler: A closure for handling the notification content.
    static func drawBannerView(with urlStr: String, bestAttemptContent: UNMutableNotificationContent?, contentHandler: ((UNNotificationContent) -> Void)?) {
        Network.fetchAttachment(for: urlStr, at: 0) { attachment, index in
            if let attachment = attachment {
                bestAttemptContent?.attachments = [attachment]
            }
            
            Network.trackEvent(completion: {
                contentHandler?(bestAttemptContent ?? UNMutableNotificationContent())
            }, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
        }
    }
    
    /// Draw a multi-image view for a notification with multiple items.
    ///
    /// - Parameters:
    ///   - items: An array of items for the multi-image layout.
    ///   - backgroundImage: Optional background image URL (downloaded at index 0, shifts item indices by 1).
    ///   - bestAttemptContent: The best attempt notification content.
    ///   - contentHandler: A closure for handling the notification content.
    static func drawMultiImageView(with items: [[String: Any]], backgroundImage: String? = nil, bestAttemptContent: UNMutableNotificationContent?, contentHandler: ((UNNotificationContent) -> Void)?) {
        let hasBgImage = backgroundImage != nil && !backgroundImage!.isEmpty
        let indexOffset = hasBgImage ? 1 : 0
        
        let imageItems = items.enumerated().compactMap { index, item -> (Int, String)? in
            guard let imageURL = item["image"] as? String else { return nil }
            return (index + indexOffset, imageURL)
        }
        
        guard !imageItems.isEmpty else { return }
        
        let totalDownloads = imageItems.count
        var attachmentsArray = [UNNotificationAttachment]()
        var downloadAttemptCounter = 0
        var hasFailure = false
        let lock = NSLock()
        
        let completionCheck = {
            lock.lock()
            downloadAttemptCounter += 1
            let isComplete = downloadAttemptCounter == totalDownloads
            let shouldFallback = hasFailure
            lock.unlock()
            
            if isComplete {
                if shouldFallback {
                    markAsFallback(bestAttemptContent: bestAttemptContent)
                }
                Network.trackEvent(completion: {
                    if let bestAttemptContent = bestAttemptContent {
                        contentHandler?(bestAttemptContent)
                    }
                }, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
            }
        }
        
        let downloadTiles = {
            for (index, imageURL) in imageItems {
                Network.fetchAttachment(for: imageURL, at: index) { attachment, _ in
                    lock.lock()
                    if let attachment = attachment {
                        attachmentsArray.append(attachment)
                        attachmentsArray.sort {(Int($0.identifier) ?? 0) < (Int($1.identifier) ?? 0)}
                        bestAttemptContent?.attachments = attachmentsArray
                    } else {
                        hasFailure = true
                    }
                    lock.unlock()
                    completionCheck()
                }
            }
        }
        
        if let bgImage = backgroundImage, !bgImage.isEmpty {
            Network.fetchAttachment(for: bgImage, at: 0) { attachment, _ in
                if let attachment = attachment {
                    lock.lock()
                    if let newAttachment = try? UNNotificationAttachment(
                        identifier: attachment.identifier,
                        url: attachment.url,
                        options: [
                            UNNotificationAttachmentOptionsThumbnailHiddenKey: true
                        ]
                    ) {
                        attachmentsArray.append(newAttachment)
                    } else {
                        attachmentsArray.append(attachment)
                    }
                    attachmentsArray.sort {(Int($0.identifier) ?? 0) < (Int($1.identifier) ?? 0)}
                    bestAttemptContent?.attachments = attachmentsArray
                    lock.unlock()
                    downloadTiles()
                } else {
                    // Background image failed, skip tiles and go straight to fallback
                    markAsFallback(bestAttemptContent: bestAttemptContent)
                    Network.trackEvent(completion: {
                        if let bestAttemptContent = bestAttemptContent {
                            contentHandler?(bestAttemptContent)
                        }
                    }, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                }
            }
        } else {
            downloadTiles()
        }
    }
    
    /// Marks the notification as fallback by adding is_fallback=true to customData in userInfo.
    private static func markAsFallback(bestAttemptContent: UNMutableNotificationContent?) {

        guard let bestAttemptContent = bestAttemptContent else { return }

        // Early exit: only proceed if style == "TILES"
        guard
            let expandableDetails = bestAttemptContent.userInfo["expandableDetails"] as? [String: Any],
            let style = expandableDetails["style"] as? String,
            style.uppercased() == "TILES"
        else {
            return
        }

        var userInfo = bestAttemptContent.userInfo
        var customData = userInfo["customData"] as? [[String: Any]] ?? []

        customData.append(["key": "is_fallback", "value": true])
        userInfo["customData"] = customData

        bestAttemptContent.userInfo = userInfo
        // If any image fails to load, we fall back to the default layout. In the collapsed state, no image should be displayed, but since we don’t remove it from bestAttemptContent.attachments, it still appears in the collapsed view.
        for attachment in bestAttemptContent.attachments {
            try? FileManager.default.removeItem(at: attachment.url)
        }
        bestAttemptContent.attachments = []
    }
}
