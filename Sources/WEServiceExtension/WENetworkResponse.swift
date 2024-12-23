//
//  WENetworkResponse.swift
//  WEServiceExtension
//
//  Created by Shubham Naidu on 25/06/24.
//

import Foundation

@objcMembers
public class WENetworkResponse: NSObject {
    public var data: Data?
    public var response: URLResponse?
    public var error: Error?

    private override init() {
        self.data = nil
        self.response = nil
        self.error = nil
    }

    private init(data: Data?, response: URLResponse?, error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }

    @objc static func create(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) -> WENetworkResponse {
        return WENetworkResponse(data: data, response: response, error: error)
    }
}
