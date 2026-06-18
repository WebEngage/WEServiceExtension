//
//  WEDTagBuilder.swift
//  WEServiceExtension
//
//  Fluent builder for constructing debug tag arrays.
//

import Foundation

// MARK: - Tag Builder

class WEDTagBuilder {
    
    private var tags: [[String: Any]] = []
    
    static func create() -> WEDTagBuilder {
        return WEDTagBuilder()
    }
    
    /// Adds a tag. If a tag with the same name exists, merges its metadata.
    @discardableResult
    func addTag(_ name: String, metadata: [String: Any]) -> WEDTagBuilder {
        if let index = tags.firstIndex(where: { $0["tag"] as? String == name }) {
            if var existing = tags[index]["metadata"] as? [String: Any] {
                existing.merge(metadata) { _, new in new }
                tags[index] = ["tag": name, "metadata": existing]
            }
        } else {
            tags.append(["tag": name, "metadata": metadata])
        }
        return self
    }
    
    func build() -> [[String: Any]] {
        return tags
    }
}
