//
//  WEDebugger.swift
//  WEServiceExtension
//
//  Created by Shubham Naidu on 25/03/25.
//

import Foundation

/// A debugger utility for making network calls.
struct WEDebugger {
    
    /// Sends events to the server via POST request
    /// - Parameters:
    ///   - events: Array of event dictionaries to send
    ///   - urlString: Server URL string
    ///   - headers: Optional headers
    ///   - completion: Completion handler with status code and optional error
    func sendEvents(_ events: [[String: Any]],
                    urlString: String,
                    headers: [String: String]? = nil,
                    completion: @escaping (Int, Error?) -> Void) {
        
        guard let url = URL(string: urlString) else {
            completion(-1, NSError(domain: "WEDNetwork", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add headers
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Convert events array to JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: events, options: [])
            request.httpBody = jsonData
        } catch {
            completion(-1, error)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(-1, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode, nil)
            } else {
                completion(-1, NSError(domain: "WEDNetwork", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Response"]))
            }
        }
        
        task.resume()
    }
    
}
