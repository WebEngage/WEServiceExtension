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
        
        let totalDownloads = imageItems.count + indexOffset
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
        
        if let bgImage = backgroundImage, !bgImage.isEmpty {
            let options: [AnyHashable: Any] = [UNNotificationAttachmentOptionsThumbnailHiddenKey: true]
            
            Network.fetchAttachment(for: bgImage, at: 0) { attachment, _ in
                   if let attachment = attachment {
                       do {
                           let newAttachment = try UNNotificationAttachment(
                               identifier: attachment.identifier,
                               url: attachment.url,
                               options: [
                                   UNNotificationAttachmentOptionsThumbnailHiddenKey: true
                               ]
                           )
                           lock.lock()
                           attachmentsArray.append(newAttachment)
                           attachmentsArray.sort { Int($0.identifier)! < Int($1.identifier)! }
                           bestAttemptContent?.attachments = attachmentsArray
                           lock.unlock()
                           
                       } catch {
                           // fallback to original if needed
                           lock.lock()
                           attachmentsArray.append(attachment)
                           lock.unlock()
                       }
                   }
                   completionCheck()
               }
        }
        
        for (index, imageURL) in imageItems {
            Network.fetchAttachment(for: imageURL, at: index) { attachment, _ in
                lock.lock()
                if let attachment = attachment {
                    attachmentsArray.append(attachment)
                    attachmentsArray.sort { Int($0.identifier)! < Int($1.identifier)! }
                    bestAttemptContent?.attachments = attachmentsArray
                } else {
                    hasFailure = true
                }
                lock.unlock()
                completionCheck()
            }
        }
    }
    
    /// Marks the notification as fallback by adding is_fallback=true to customData in userInfo.
    private static func markAsFallback(bestAttemptContent: UNMutableNotificationContent?) {
        guard let bestAttemptContent = bestAttemptContent else { return }
        var userInfo = bestAttemptContent.userInfo
        var customData = userInfo["customData"] as? [[String: Any]] ?? []
        customData.append(["key": "is_fallback", "value": true])
        userInfo["customData"] = customData
        bestAttemptContent.userInfo = userInfo
        bestAttemptContent.attachments = []
    }
}
