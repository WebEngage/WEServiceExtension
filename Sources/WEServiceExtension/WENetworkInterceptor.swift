//
//  WENetworkInterceptor.swift
//  WEServiceExtension
//
//  Created by Shubham Naidu on 28/06/24.
//

import Foundation


@objc public protocol WENetworkInterceptor {
    @objc optional func onRequest(_ request: URLRequest, completionHandler: @escaping (URLRequest) -> Void)
    @objc optional func onResponse(_ response: WENetworkResponse, completionHandler: @escaping (WENetworkResponse) -> Void)
}
