//
//  SomeNativeSingleton.swift
//  Inappstories
//
//  Created by Dzmitry Nistratau on 26/03/2025.
//

import Foundation

@objc(RCTSomeNativeSingleton)
class SomeNativeSingleton: NSObject {
    
    // Make the protocol compatible with Objective-C
    @objc protocol Delegate: NSObjectProtocol {
        func someDelegateFunction()
    }
    
    @objc static let shared = SomeNativeSingleton()
    
    // Now this will work since Delegate conforms to NSObjectProtocol
    @objc weak var delegate: Delegate?
    
    private override init() {
        super.init()
    }
    
    @objc func someNativeFunction(_ completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            // Non-blocking delay for 2 seconds
            sleep(2)
            
            DispatchQueue.main.async {
                // Calls the completion on the main thread.
                completion()
                
                // Report to delegate about this event as well.
                self.delegate?.someDelegateFunction()
            }
        }
    }

    @objc class func debugInfo() -> String {
        let shared = SomeNativeSingleton.shared
        let className = NSStringFromClass(type(of: shared))
        
        // Get methods
        var methodCount: UInt32 = 0
        let methodList = class_copyMethodList(type(of: shared), &methodCount)
        defer { free(methodList) }
        
        var methods = ""
        for i in 0..<Int(methodCount) {
            let method = methodList![i]
            let selector = method_getName(method)
            methods += "- \(NSStringFromSelector(selector))\n"
        }
        
        return "SomeNativeSingleton Debug:\nClass: \(className)\nMethods:\n\(methods)"
    }
}
