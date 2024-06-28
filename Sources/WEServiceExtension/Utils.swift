//
//  Utils.swift
//
//
//  Created by Shubham Naidu on 19/10/23.
//

import Foundation

/// Utility functions for the service extension..
struct Utils {
    
    /// The version of the service extension.
    static let WEX_SERVICE_EXTENSION_VERSION = "1.1.0"
    static var PROXY_URL : String?
    static var weNetworkInterceptor: AnyObject?
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
    static func getDataFromSharedUserDefaults() -> [String : String]? {
        guard let defaults = getSharedUserDefaults() else {
            return nil
        }
        
        var data = [String: String]()
        data["license_code"] = defaults.string(forKey: "license_code")
        data["interface_id"] = defaults.string(forKey: "interface_id")
        if let sdkVersion = defaults.string(forKey: "sdk_version"), let intValue = Int(sdkVersion) {
            data["sdk_version"] = String(intValue)
        }
        data["app_id"] = defaults.string(forKey: "app_id")
        data["proxy_url"] = defaults.string(forKey: "proxy_url")
        if let proxyURL = data["proxy_url"]{
            PROXY_URL = proxyURL
        }
       
        
        print("Environment: \(defaults.string(forKey: "environment") ?? "")")
        data["environment"] = defaults.string(forKey: "environment") ?? ""
        return data
    }
    
    /// Get the shared user defaults.
    ///
    /// - Returns: The shared user defaults instance or nil if it couldn't be initialized.
    static func getSharedUserDefaults() -> UserDefaults? {
        var appGroup = Bundle.main.object(forInfoDictionaryKey: "WEX_APP_GROUP") as? String
        
        if appGroup == nil {
            var bundle = Bundle.main
            
            if bundle.bundleURL.pathExtension == "appex" {
                bundle = Bundle(url: bundle.bundleURL.deletingLastPathComponent().deletingLastPathComponent())!
            }
            
            let bundleIdentifier = bundle.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String
            
            appGroup = "group.\(bundleIdentifier ?? "").WEGNotificationGroup"
        }
        
        if let appGroup = appGroup {
            if let defaults = UserDefaults(suiteName: appGroup) {
                return defaults
            } else {
                print("Shared User Defaults could not be initialized. Ensure Shared App Groups have been enabled on Main App & Notification Service Extension Targets.")
            }
        }
        
        return nil
    }
    
    /// Set default values for the service extension.
    static func setExtensionDefaults() {
        let sharedDefaults = getSharedUserDefaults()
        
        if sharedDefaults?.value(forKey: "WEG_ServiceToApp") == nil {
            sharedDefaults?.setValue("WEG", forKey: "WEG_ServiceToApp")
            sharedDefaults?.synchronize()
        }
        
        // for SPM Code it will be saved under : WEServiceExtension_version
        // for WebEngageBannerPush it will be saved under : WEG_Service_Extension_Version
        sharedDefaults?.setValue(WEX_SERVICE_EXTENSION_VERSION, forKey: "WEServiceExtension_version")
        sharedDefaults?.synchronize()
    }
    
    static func setProxyURL(urlrequest:inout URLRequest){
        if let urlStr = urlrequest.url?.absoluteString,
           let proxy = PROXY_URL,proxy != "",
           !urlStr.contains(proxy){
            if let encodedUrl = urlStr.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed),
               let newURL = URL(string: "\(proxy)?url=\(encodedUrl)") {
                urlrequest.url = newURL
            }
        }
    }
    
    static func getInterceptedRequest(request: URLRequest, completionHandler: @escaping (URLRequest)->Void){
        if let interceptor = Utils.weNetworkInterceptor{
            interceptor.onRequest(request){ _modifiedRequest in
                 completionHandler(_modifiedRequest)
            }
        }
    }
    
    static func getInterceptedResponse(taskResponse: WENetworkResponse, completionHandler: @escaping (WENetworkResponse)->Void) {
        if let interceptor = Utils.weNetworkInterceptor{
            interceptor.onResponse(taskResponse){ _modifiedResponse in
                completionHandler(_modifiedResponse)
            }
        }
    }
}

