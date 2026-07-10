//
//  Utils.swift
//
//
//  Created by Shubham Naidu on 19/10/23.
//

import Foundation

/// Utility functions for the service extension..
struct Utils {
    // MARK: - Variables
    
    static var PROXY_URL: String?
    static var weNetworkInterceptor: AnyObject?
    
    // MARK: - Methods

    /// Get the current time in a formatted string.
    ///
    /// - Returns: A formatted date and time string.
    static func getCurrentFormattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "'~t'yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.locale = Locale(identifier: "en_GB")
        return formatter.string(from: Date())
    }
    
    /// Get data from shared user defaults.
    ///
    /// - Returns: A dictionary with data from shared user defaults.
    static func getDataFromSharedUserDefaults() -> [String: Any]? {
        guard let defaults = getSharedUserDefaults() else {
            return nil
        }
        
        var data = [String: Any]()
        data[WEConstants.WEX_LICENSE_CODE] = defaults.string(forKey: WEConstants.WEX_LICENSE_CODE)
        data[WEConstants.WEX_INTERFACE_ID] = defaults.string(forKey: WEConstants.WEX_INTERFACE_ID)
        
        if let sdkVersion = defaults.string(forKey: WEConstants.WEX_SDK_VERSION), let intValue = Int(sdkVersion) {
            data[WEConstants.WEX_SDK_VERSION] = String(intValue)
        }
        
        data[WEConstants.WEX_APP_ID] = defaults.string(forKey: WEConstants.WEX_APP_ID)
        data[WEConstants.WEX_PROXY_URL] = defaults.string(forKey: WEConstants.WEX_PROXY_URL)
        
        if let proxyURL = data[WEConstants.WEX_PROXY_URL] as? String {
            PROXY_URL = proxyURL
        }
        
        data[WEConstants.WEX_TRACK_IP_LOCATION] = defaults.bool(forKey: WEConstants.WEX_TRACK_IP_LOCATION)
        
        print("Environment: \(defaults.string(forKey: WEConstants.WEX_ENVIRONMENT) ?? "")")
        data[WEConstants.WEX_ENVIRONMENT] = defaults.string(forKey: WEConstants.WEX_ENVIRONMENT) ?? ""
        
        return data
    }
    
    /// Get the shared user defaults.
    ///
    /// - Returns: The shared user defaults instance or nil if it couldn't be initialized.
    static func getSharedUserDefaults() -> UserDefaults? {
        guard let appGroup = getAppGroup() else {
            ALog("WebEngage App Group not configured in Service Extension")
            return nil
        }
        
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) {
            print("WebEngage App Group configured in Service Extension")
        } else {
            ALog("WebEngage App Group not configured in Service Extension")
        }
        
        return UserDefaults(suiteName: appGroup)
    }
    
    /// Set default values for the service extension.
    static func setExtensionDefaults() {
        let sharedDefaults = getSharedUserDefaults()
        
        if sharedDefaults?.value(forKey: "WEG_ServiceToApp") == nil {
            sharedDefaults?.setValue("WEG", forKey: "WEG_ServiceToApp")
        }
        
        // for SPM Code it will be saved under : WEServiceExtension_version
        // for WebEngageBannerPush it will be saved under : WEG_Service_Extension_Version
        sharedDefaults?.setValue(WEConstants.WEX_SERVICE_EXTENSION_VERSION, forKey: "WEServiceExtension_version")
    }
    
    /// Modifies the given URLRequest to route through a proxy URL if applicable.
    ///
    /// - Parameter urlrequest: The request to be modified.
    static func configureProxyURL(urlrequest: inout URLRequest) {
        if let urlStr = urlrequest.url?.absoluteString,
           let proxy = PROXY_URL, proxy != "",
           !urlStr.contains(proxy) {
            if let encodedUrl = urlStr.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed),
               let newURL = URL(string: "\(proxy)?url=\(encodedUrl)") {
                urlrequest.url = newURL
            }
        }
    }

    /// Intercepts and modifies a network request using a registered network interceptor.
    ///
    /// - Parameters:
    ///   - request: The original network request.
    ///   - completionHandler: A closure returning the modified request.
    static func getInterceptedRequest(request: URLRequest, completionHandler: @escaping (URLRequest) -> Void) {
        if let interceptor = Utils.weNetworkInterceptor {
            interceptor.onRequest(request) { _modifiedRequest in
                completionHandler(_modifiedRequest)
            }
        }
    }

    /// Intercepts and modifies a network response using a registered network interceptor.
    ///
    /// - Parameters:
    ///   - taskResponse: The original network response.
    ///   - completionHandler: A closure returning the modified response.
    static func getInterceptedResponse(taskResponse: WENetworkResponse, completionHandler: @escaping (WENetworkResponse) -> Void) {
        if let interceptor = Utils.weNetworkInterceptor {
            interceptor.onResponse(taskResponse) { _modifiedResponse in
                completionHandler(_modifiedResponse)
            }
        }
    }

    /// Adds an `x-geo-ignore` header to the request if IP tracking is disabled.
    ///
    /// - Parameter request: The request to be modified.
    static func trackIPLocation(request: inout URLRequest) {
        guard let userDefaultsData = Utils.getDataFromSharedUserDefaults() else {
            return
        }
        if let trackIP = userDefaultsData[WEConstants.WEX_TRACK_IP_LOCATION] as? Bool {
            // Add x-geo-ignore flag to the request headers if IP tracking is disabled
            if !trackIP {
                request.setValue("1", forHTTPHeaderField: "x-geo-ignore")
            }
        }
    }

    /// Checks if an app group is properly configured.
    ///
    /// - Returns: `true` if the app group is configured, otherwise `false`.
    static func isAppGroupConfigured() -> Bool {
        guard let appGroup = getAppGroup() else {
            return false
        }
        
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) {
            return true
        } else {
            return false
        }
    }

    /// Retrieves the app group identifier from the app's `Info.plist`.
    ///
    /// - Returns: The app group identifier if available, otherwise a default group identifier.
    static func getAppGroup() -> String? {
        if let appGroup = Bundle.main.object(forInfoDictionaryKey: "WEX_APP_GROUP") as? String {
            return appGroup
        }
        
        // Continue with the default logic if appGroup is not found
        var bundle = Bundle.main
        if bundle.bundleURL.pathExtension == "appex" {
            bundle = Bundle(url: bundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent()) ?? bundle
        }
        
        if let bundleIdentifier = bundle.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String {
            return "group.\(bundleIdentifier).WEGNotificationGroup"
        }
        
        return nil
    }

    /// Logs an error message with the file name, function, and line number.
    ///
    /// - Parameters:
    ///   - message: The error message to log.
    ///   - file: The file where the log is called (default: `#file`).
    ///   - function: The function where the log is called (default: `#function`).
    ///   - line: The line number where the log is called (default: `#line`).
    static func ALog(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        NSLog("%@ [Line %d] ERROR: %@", (function as NSString).lastPathComponent, line, message)
    }
    
    // Header is only added when proxy is set; not sent as "false" otherwise to avoid unnecessary overhead on every request
    static func appendCustomProxyHeader(request: inout URLRequest) {
        if let proxy = PROXY_URL, !proxy.isEmpty {
            request.setValue("true", forHTTPHeaderField: "X-Custom-Proxy")
        }
    }


    
}
