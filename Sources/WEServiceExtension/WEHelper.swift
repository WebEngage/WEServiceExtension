//
//  Helper.swift
//
//
//  Created by Shubham Naidu on 20/10/23.
//

import Foundation

/// Helper methods for working with notifications.
struct WEHelper {
    
    /// Sanitize an object for transit, ensuring it follows a specific format.
    ///
    /// - Parameter obj: The object to sanitize.
    /// - Returns: The sanitized object.
    static func sanitizeForTransit(obj: Any) -> Any {
        if let str = obj as? String {
            if (str.hasPrefix("~") || str.hasPrefix("^") || str.hasPrefix("`")) && !str.hasPrefix("~t") {
                return "~" + str
            }
            
            if str == "null" {
                return NSNull()
            }
        }
        return obj
    }
    
    /// Recursively create a sanitized dictionary of properties.
    ///
    /// - Parameter property: The property to sanitize.
    /// - Returns: The sanitized dictionary of properties.
    static func dictionaryOfProperties(property: Any) -> Any {
        var dict = property as? [String: Any] ?? [:]
        dict.forEach { key, obj in
            var sanitizedObj = sanitizeForTransit(obj: obj)
            if let sanitizedDict = sanitizedObj as? [String: Any] {
                sanitizedObj = dictionaryOfProperties(property: sanitizedDict)
            }
            dict[key] = sanitizedObj
        }
        return dict
    }
    
    /// Get the appropriate category for a notification based on category mappings.
    ///
    /// - Parameters:
    ///   - categories: An array of category strings.
    ///   - currentCategory: The current category string.
    /// - Returns: The mapped category or the current category if no mapping exists.
    static func getCategoryFor(categories: [String]?, currentCategory: String?) -> String? {
        
        if let categories = categories, let currentCategory = currentCategory {
            let categoryMapping: [String: String] = [
                "default": categories[0],      // Default, No buttons
                "19db52de": categories[0],     // Default, No buttons
                "18dfbbcc": categories[1],     // Yes/No - Open App/Dismiss
                "16589g0g": categories[2],     // Yes/No - Dismiss both
                "15ead296": categories[3],     // Accept/Decline - Open/Dismiss
                "17543720": categories[4],     // Accept/Decline - Dismiss both
                "16e66ba8": categories[5],     // Shop Now
                "1c406g7a": categories[6],     // Buy Now
                "1bd2a2g0": categories[7]      // Download Now
            ]
            
            if let category = categoryMapping[currentCategory] {
                return category
            } else {
                return currentCategory
            }
        }
        return nil
    }
}
