//
//  Network.swift
//  
//
//  Created by Shubham Naidu on 25/10/23.
//

import Foundation
import UserNotifications

/// A network utility for handling rich push notifications.
struct Network {
    
    /// Fetch an attachment for a notification.
    ///
    /// - Parameters:
    ///   - urlString: The URL of the attachment.
    ///   - index: The index of the attachment.
    ///   - completionHandler: A closure to handle the attachment and index.
    static func fetchAttachment(for urlString: String, at index: Int, completionHandler: @escaping (UNNotificationAttachment?, Int) -> Void) {
        var fileExt = "." + (urlString as NSString).pathExtension
        let fileExtensionLength = fileExt.count
        
        if fileExt == "." || fileExtensionLength >= 5 {
            fileExt = ".jpg"
        }
        
        guard let url = URL(string: urlString) else {
            completionHandler(nil, index)
            return
        }
        
        var request = URLRequest(url: url)
        request.cachePolicy = .useProtocolCachePolicy
        request.timeoutInterval = 10.0
        request.allHTTPHeaderFields = ["Accept": "image/webp"]
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.downloadTask(with: request) { temporaryFileLocation, response, error in
            var attachment: UNNotificationAttachment?
            
            if let error = error {
                print(error)
            } else {
                if let temporaryFileLocation = temporaryFileLocation {
                    let localURL = URL(fileURLWithPath: temporaryFileLocation.path + fileExt)
                    print("SIZE FOR THE FILE \(response?.expectedContentLength ?? 0)")
                    
                    do {
                        try FileManager.default.moveItem(at: temporaryFileLocation, to: localURL)
                        
                        attachment = try UNNotificationAttachment(identifier: "\(index)", url: localURL, options: nil)
                    } catch {
                        print("File Move Error: \(error)")
                    }
                }
            }
            
            print("Sending Callback")
            completionHandler(attachment, index)
        }
        
        task.resume()
    }
    
    /// Track notification events and call the provided completion handler.
    ///
    /// - Parameters:
    ///   - completion: A closure to be called when the events are tracked.
    ///   - bestAttemptContent: The best attempt notification content.
    ///   - contentHandler: A closure for handling the notification content.
    static func trackEvent(completion: (() -> Void)?, bestAttemptContent: UNMutableNotificationContent?, contentHandler: ((UNNotificationContent) -> Void)?) {
        if var requestForEventReceived = getRequestForTracker(eventName: "push_notification_received", bestAttemptContent: bestAttemptContent) {
            Utils.setProxyURL(urlrequest: &requestForEventReceived)
            URLSession.shared.dataTask(with: requestForEventReceived) { data, response, error in
                if let error = error {
                    print("Could not log push_notification_received event with error: \(error)")
                } else {
                    print("Push Tracker URLResponse: \(response.debugDescription )")
                }
                
                completion?()
            }.resume()
        }
        
        if var requestForEventView = getRequestForTracker(eventName: "push_notification_view", bestAttemptContent: bestAttemptContent) {
            Utils.setProxyURL(urlrequest: &requestForEventView)
            URLSession.shared.dataTask(with: requestForEventView) { data, response, error in
                if let error = error {
                    print("Could not log push_notification_view event with error: \(error)")
                } else {
                    print("Push Tracker URLResponse: \(response.debugDescription )")
                }
                
                completion?()
            }.resume()
        }
    }
    
    /// Get a URLRequest for tracking an event.
    ///
    /// - Parameters:
    ///   - eventName: The name of the event to track.
    ///   - bestAttemptContent: The best attempt notification content.
    /// - Returns: A URLRequest for the event.
    static func getRequestForTracker(eventName: String, bestAttemptContent: UNMutableNotificationContent?) -> URLRequest? {
        if let url = URL(string: getBaseURL()) {
            print("Base url: \(url)")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/transit+json", forHTTPHeaderField: "Content-type")
            request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
            request.httpBody = getTrackerRequestBody(eventName: eventName, bestAttemptContent: bestAttemptContent)
            return request
        }
        return nil
    }
    
    /// Get the base URL for event tracking based on environment.
    ///
    /// - Returns: The base URL for tracking events.
    static func getBaseURL() -> String {
        var baseURL = "https://c.webengage.com/tracker"
        
        if let userDefaultsData = Utils.getDataFromSharedUserDefaults() {
            let environment = userDefaultsData["environment"]
            
            print("Setting Environment to: \(environment ?? "")")
            
            if environment?.uppercased() == "IN" {
                baseURL = "https://c.in.webengage.com/tracker"
            } else if environment?.uppercased() == "IR0" {
                baseURL = "https://c.ir0.webengage.com/tracker"
            } else if environment?.uppercased() == "UNL" {
                baseURL = "https://c.unl.webengage.com/tracker"
            } else if environment?.uppercased() == "KSA" {
                baseURL = "https://c.ksa.webengage.com/tracker"
            } else if environment?.uppercased() == "STAGING" {
                baseURL = "https://c.stg.webengage.biz/tracker"
            }
        }
        
        return baseURL
    }
    
    /// Get the request body for event tracking.
    ///
    /// - Parameters:
    ///   - eventName: The name of the event.
    ///   - bestAttemptContent: The best attempt notification content.
    /// - Returns: The request body data for event tracking.
    static func getTrackerRequestBody(eventName: String, bestAttemptContent: UNMutableNotificationContent?) -> Data? {
        guard let userDefaultsData = Utils.getDataFromSharedUserDefaults() else {
            return nil
        }
        
        var body = [String: Any]()
        body["event_name"] = eventName
        body["category"] = "system"
        body["suid"] = "null"
        body["luid"] = "null"
        body["cuid"] = "null"
        body["event_time"] = Utils.getCurrentFormattedTime()
        body["license_code"] = userDefaultsData["license_code"]
        body["interface_id"] = userDefaultsData["interface_id"]
        
        if let customData = bestAttemptContent?.userInfo["customData"] as? [[String: Any]] {
            var customDataDictionary = [String: Any]()
            for customDataItem in customData {
                if let key = customDataItem["key"] as? String, let value = customDataItem["value"] {
                    customDataDictionary[key] = value
                }
            }
            body["event_data"] = customDataDictionary
        } else {
            body["event_data"] = [String: Any]()
        }
        
        var systemData = [String: Any]()
        systemData["sdk_id"] = 3
        if let sdkVersion = userDefaultsData["sdk_version"], let intValue = Int(sdkVersion) {
            systemData["sdk_version"] = intValue
        }
        systemData["app_id"] = userDefaultsData["app_id"]
        systemData["experiment_id"] = bestAttemptContent?.userInfo["experiment_id"]
        systemData["id"] = bestAttemptContent?.userInfo["notification_id"]
        
        body["system_data"] = systemData
        
        body = WEHelper.dictionaryOfProperties(property: body) as! [String: Any]
        
        print("Data reporting to tracker: \(body)")
        
        do {
            let data = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            return data
        } catch {
            print("Error in converting data: \(error)")
            return nil
        }
    }
}
