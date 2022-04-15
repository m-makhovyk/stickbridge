//
//  StickBridgeApp.swift
//  StickBridge
//
//  Created by Mike Makhovyk on 14.03.2022.
//

import SwiftUI

@main
struct StickBridgeApp: App {
    
    init() {
        #if DEBUG
            Logger.enabled = true
        #else
            Logger.enabled = false
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            GameFieldView()
        }
    }
}
