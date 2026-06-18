//
//  WEDEventQueue.swift
//  WEServiceExtension
//
//  Manages event batching and network delivery for the debugger.
//

import Foundation

// MARK: - Event Queue & Network

struct WEDEventQueue {
    
    private static var queue: [[String: Any]] = []
    private static let batchSize = 5
    private static let lock = NSLock()
    
    // MARK: - Public API
    
    /// Adds an event to the queue. Automatically flushes when batch size is reached.
    static func enqueue(_ event: [String: Any]) {
        lock.lock()
        defer { lock.unlock() }
        
        queue.append(event)
        
        if queue.count >= batchSize {
            let batch = queue
            queue.removeAll()
            send(batch)
        }
    }
    
    /// Sends all queued events immediately. Call before extension terminates.
    static func flush() {
        lock.lock()
        defer { lock.unlock() }
        
        guard !queue.isEmpty else { return }
        
        let batch = queue
        queue.removeAll()
        send(batch)
    }
    
    // MARK: - Network
    
    private static func send(_ events: [[String: Any]]) {
        guard let defaults = Utils.getSharedUserDefaults(),
              let urlString = defaults.string(forKey: WEDConstants.KEY_DEBUGGER_EVENT_SYNC_URL),
              let token = defaults.string(forKey: WEDConstants.KEY_DEBUGGER_AUTH_TOKEN),
              let url = URL(string: urlString) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/transit+json", forHTTPHeaderField: "Content-Type")
        
        guard let body = try? JSONSerialization.data(withJSONObject: events, options: []) else {
            return
        }
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Check if server signaled stop
            if let data = data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let signal = json["data"] as? String,
               signal == "stop" || signal == "error" {
                defaults.removeObject(forKey: WEDConstants.KEY_DEBUGGER_EVENT_SYNC_URL)
                defaults.removeObject(forKey: WEDConstants.KEY_DEBUGGER_AUTH_TOKEN)
                defaults.synchronize()
            }
        }.resume()
    }
}
