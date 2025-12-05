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
                WEXLogProcessor.logImageDownloadingFailed(loglevel: WEGLogLevel.error, message: "Image Downloading failed for \(urlString): \(error)")
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
    if Utils.isAppGroupConfigured(){
        let events = ["push_notification_received", "push_notification_view"]

        for eventName in events {
            if var requestForEvent = getRequestForTracker(eventName: eventName, bestAttemptContent: bestAttemptContent) {
                Utils.configureProxyURL(urlrequest: &requestForEvent)
                Utils.trackIPLocation(request: &requestForEvent)
                Utils.getInterceptedRequest(request: requestForEvent) { _modifiedRequest in
                    requestForEvent = _modifiedRequest
                    URLSession.shared.dataTask(with: requestForEvent) { data, response, error in
                        var networkResponse = WENetworkResponse.create(data: data, response: response, error: error)
                        Utils.getInterceptedResponse(taskResponse: networkResponse) { _modifiedResponse in
                            networkResponse = _modifiedResponse
                            if let error = networkResponse.error {
                                print("Could not log \(eventName) event with error: \(error)")
                            } else {
                                print("Push Tracker URLResponse: \(networkResponse.response.debugDescription)")
                            }
                        }
                        completion?()
                    }.resume()
                }
            }
        }
    } else {
            completion?()
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
            //The below request is a var because in Swift using NSMutableURLRequest is not recommended
            //The best way to achieve the equivalent rest using var instead of let while creating a request.
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
        
        if let userDefaultsData = Utils.getDataFromSharedUserDefaults(),
           let environment = userDefaultsData["environment"] as? String{

            
            print("Setting Environment to: \(environment)")
            
            if environment.uppercased() == "IN" {
                baseURL = "https://c.in.webengage.com/tracker"
            } else if environment.uppercased() == "IR0" {
                baseURL = "https://c.ir0.webengage.com/tracker"
            } else if environment.uppercased() == "UNL" {
                baseURL = "https://c.unl.webengage.com/tracker"
            } else if environment.uppercased() == "KSA" {
                baseURL = "https://c.ksa.webengage.com/tracker"
            } else if environment.uppercased() == "STAGING" {
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
           body[WEConstants.WEX_EVENT_NAME] = eventName
           body[WEConstants.WEX_CATEGORY] = "system"
           body[WEConstants.WEX_SUID] = "null"
           body[WEConstants.WEX_LUID] = "null"
           body[WEConstants.WEX_CUID] = "null"
           body[WEConstants.WEX_EVENT_TIME] = Utils.getCurrentFormattedTime()
           body[WEConstants.WEX_LICENSE_CODE] = userDefaultsData[WEConstants.WEX_LICENSE_CODE]
           body[WEConstants.WEX_INTERFACE_ID] = userDefaultsData[WEConstants.WEX_INTERFACE_ID]
           
           if let customData = bestAttemptContent?.userInfo[WEConstants.WEX_CUSTOM_DATA] as? [[String: Any]] {
               var customDataDictionary = [String: Any]()
               for customDataItem in customData {
                   if let key = customDataItem[WEConstants.WEX_KEY] as? String, let value = customDataItem[WEConstants.WEX_VALUE] {
                       customDataDictionary[key] = value
                   }
               }
               body[WEConstants.WEX_EVENT_DATA] = customDataDictionary
           } else {
               body[WEConstants.WEX_EVENT_DATA] = [String: Any]()
           }
           
           var systemData = [String: Any]()
           systemData[WEConstants.WEX_SDK_ID] = 3
           if let sdkVersion = userDefaultsData[WEConstants.WEX_SDK_VERSION] as? String, let intValue = Int(sdkVersion) {
               systemData[WEConstants.WEX_SDK_VERSION] = intValue
           }
           systemData[WEConstants.WEX_APP_ID] = userDefaultsData[WEConstants.WEX_APP_ID]
           systemData[WEConstants.WEX_EXPERIMENT_ID] = bestAttemptContent?.userInfo[WEConstants.WEX_EXPERIMENT_ID]
           systemData[WEConstants.WEX_NOTIFICATION_ID] = bestAttemptContent?.userInfo[WEConstants.WEX_NOTIFICATION_ID]
           
           body[WEConstants.WEX_SYSTEM_DATA] = systemData
           
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
