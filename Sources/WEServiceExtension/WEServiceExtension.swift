//
//  WebEngageBannerPush.swift
//
//
//  Created by Shubham Naidu on 19/10/23.
//

import UserNotifications

open class WEXPushNotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    var customCategories: [String]?
    
    open override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        if let source = request.content.userInfo["source"] as? String, source == "webengage" {
            self.contentHandler = contentHandler
            self.bestAttemptContent = request.content.mutableCopy() as? UNMutableNotificationContent
            Utils.setExtensionDefaults()
            
            print("Push Notification content: \(request.content.userInfo)")
            
            if let expandableDetails = request.content.userInfo["expandableDetails"] as? [String: Any], let style = expandableDetails["style"] as? String {
                if style == "CAROUSEL_V1", let items = expandableDetails["items"] as? [[String: Any]] {
                    WERenderer.drawCarouselView(with: items, bestAttemptContent: self.bestAttemptContent, contentHandler: self.contentHandler)
                } else if style == "RATING_V1", let image = expandableDetails["image"] as? String {
                    WERenderer.handleContentFor(style: style, image: image, bestAttemptContent: self.bestAttemptContent, contentHandler: self.contentHandler)
                } else if style == "BIG_PICTURE" || style == "BIG_TEXT" || style == "OVERLAY" {
                    customCategories = ["WEG_RICH_V1", "WEG_RICH_V2", "WEG_RICH_V3", "WEG_RICH_V4", "WEG_RICH_V5", "WEG_RICH_V6", "WEG_RICH_V7", "WEG_RICH_V8"]
                    
                    if let customCategory = WEHelper.getCategoryFor(categories: customCategories ?? [""], currentCategory: bestAttemptContent?.categoryIdentifier ?? "")  {
                        UNUserNotificationCenter.current().getNotificationCategories { existingCategories in
                            var currentCategory: UNNotificationCategory?
                            var isCategoryRegistered = false
                            var isCurrentCatCustom = false
                            var existingMutableCategories = Set(existingCategories)
                            
                            for dict in existingCategories {
                                if dict.identifier == self.bestAttemptContent?.categoryIdentifier {
                                    currentCategory = dict
                                    isCategoryRegistered = dict.identifier == customCategory
                                    isCurrentCatCustom = self.customCategories?.contains(dict.identifier) ?? false
                                } else {
                                    existingMutableCategories.insert(dict)
                                }
                            }
                            
                            if isCategoryRegistered {
                                if !isCurrentCatCustom {
                                    self.bestAttemptContent?.categoryIdentifier = customCategory
                                }
                                WERenderer.handleContentFor(style: style, image: expandableDetails["image"] as? String ?? "", bestAttemptContent: self.bestAttemptContent, contentHandler: self.contentHandler)
                                return
                            }
                            
                            // Register banner layout here.
                            var actions = [UNNotificationAction]()
                            if let currentCategory = currentCategory {
                                for action in currentCategory.actions {
                                    let actionObject = UNNotificationAction(identifier: action.identifier, title: action.title, options: action.options)
                                    actions.append(actionObject)
                                }
                            }
                            
                            let category = UNNotificationCategory(identifier: customCategory, actions: actions, intentIdentifiers: [], options: [.customDismissAction])
                            existingMutableCategories.insert(category)
                            UNUserNotificationCenter.current().setNotificationCategories(existingMutableCategories)
                            self.bestAttemptContent?.categoryIdentifier = customCategory
                            
                            // Dispatching on Main thread after a 2-second delay to ensure our category is registered with NotificationCenter
                            // Registering will make sure contentHandler invokes ContentExtension with this custom category
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                WERenderer.handleContentFor(style: style, image: expandableDetails["image"] as? String ?? "", bestAttemptContent: self.bestAttemptContent, contentHandler: self.contentHandler)
                            }
                        }
                    }
                } else {
                    WERenderer.handleContentFor(style: style, image: "", bestAttemptContent: self.bestAttemptContent, contentHandler: self.contentHandler)
                }
            }
        }
    }
    
    open override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
