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
        if (style == "BIG_PICTURE" || style == "RATING_V1") && !image.isEmpty {
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
                print("WebEngage Downloaded Image for Rating Layout")
                bestAttemptContent?.attachments = [attachment]
            }
            
            Network.trackEvent(completion: {
                contentHandler?(bestAttemptContent ?? UNMutableNotificationContent())
            }, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
        }
    }
    
    /// Draw a carousel view for a notification with multiple items.
    ///
    /// - Parameters:
    ///   - items: An array of items for the carousel.
    ///   - bestAttemptContent: The best attempt notification content.
    ///   - contentHandler: A closure for handling the notification content.
    static func drawCarouselView(with items: [[String: Any]], bestAttemptContent: UNMutableNotificationContent?, contentHandler: ((UNNotificationContent) -> Void)?) {
        var attachmentsArray = [UNNotificationAttachment]()
        
        guard items.count > 0 else {
            return
        }
        
        var itemCounter = 0
        var imageDownloadAttemptCounter = 0
        
        for carouselItem in items {
            if let imageURL = carouselItem["image"] as? String {
                Network.fetchAttachment(for: imageURL, at: itemCounter) { attachment, index in
                    imageDownloadAttemptCounter += 1
                    
                    if let attachment = attachment {
                        print("Downloaded Attachment No. \(index)")
                        attachmentsArray.append(attachment)
                        bestAttemptContent?.attachments = attachmentsArray
                    }
                    
                    if imageDownloadAttemptCounter == items.count {
                        Network.trackEvent(completion: {
                            print("Ending WebEngage Rich Push Service")
                            if let bestAttemptContent = bestAttemptContent {
                                contentHandler?(bestAttemptContent)
                            }
                        }, bestAttemptContent: bestAttemptContent, contentHandler: contentHandler)
                    }
                }
                itemCounter += 1
            }
        }
    }
}
