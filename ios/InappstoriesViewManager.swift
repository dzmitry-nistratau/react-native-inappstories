//
//  InappstoriesSomeNativeViewManager.swift
//  Inappstories
//
//  Created by Dzmitry Nistratau on 26/03/2025.
//

import Foundation
import UIKit
import React

@objc(InappstoriesViewManager)
class InappstoriesViewManager: RCTViewManager, SomeNativeViewDelegate {
    
    // Store association between views and their React tags
    var viewToTagMap = NSMapTable<SomeNativeView, NSNumber>.weakToStrongObjects()
  
    private var pendingViews = NSHashTable<SomeNativeView>.weakObjects()

    // Add this property to track if we've already initialized
    private var hasCheckedRegistry = false

    override func view() -> UIView! {
        let view = SomeNativeView(frame: .zero)
        view.delegate = self
        
        // Add to pending views that need tags
        pendingViews.add(view)
        print("📱 Created new view, awaiting tag: \(view)")
        
        // Set initial state but suppress sending events
        view.suppressEventsTemporarily = true
        view.setState(.initial)
        view.suppressEventsTemporarily = false
        
        #if RCT_NEW_ARCH_ENABLED
        // For Fabric, we need to schedule a check after the view is mounted
        // The best we can do is schedule a check shortly after creation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self, weak view] in
            guard let self = self, let view = view else { return }
            
            // Try to get the React tag from the view
            if let reactTag = (view as UIView).reactTag {
                print("🏷️ Fabric: Found React tag \(reactTag) for view")
                self.viewToTagMap.setObject(reactTag, forKey: view)
                self.pendingViews.remove(view)
            } else {
                print("⚠️ Fabric: Failed to get React tag for view")
            }
        }
        #else
        // For old architecture, we use our existing mechanism
        scheduleViewTagCheck()
        #endif
        
        return view
    }

    private func scheduleViewTagCheck() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.checkForViewTags()
        }
    }
  
    // New method to ensure we can access the view registry in either architecture
    private func ensureViewRegistryAccess() {
        if hasCheckedRegistry {
            return
        }
        
        hasCheckedRegistry = true
        
        #if RCT_NEW_ARCH_ENABLED
        // For Fabric (New Architecture), we need a different approach
        // Schedule a check after the component is mounted
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.checkForViewTags()
        }
        #else
        // For Old Architecture, use the approach with multiple attempts
        // Use a local recursive function instead
        func attemptCheck(_ attempt: Int) {
            guard attempt < 10 else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2 * Double(attempt)) { [weak self] in
                guard let self = self else { return }
                
                print("🔄 Attempt \(attempt) to check view registry")
                
                // Try to get the view registry through the UIManager
                if let registry = self.getViewRegistry(), !registry.isEmpty {
                    print("✅ View registry is available with \(registry.count) views")
                    self.checkForViewTags()
                } else if attempt < 9 { // Don't schedule after last attempt
                    attemptCheck(attempt + 1)
                } else {
                    print("❌ Failed to find view registry after \(attempt) attempts")
                }
            }
        }
        
        // Start the checking process
        attemptCheck(1)
        #endif
    }

    // Helper method to get view registry that works with both architectures
    private func getViewRegistry() -> [NSNumber: UIView]? {
        #if RCT_NEW_ARCH_ENABLED
        // For New Architecture (Fabric) on iOS, we can't access the registry directly
        // In Fabric on iOS, there's no direct equivalent to RCTFabricUIManagergetViewRegistry
        print("⚠️ View registry not directly accessible in iOS Fabric")
        return nil
        #else
        // For Old Architecture (Bridge)
        return self.bridge?.uiManager.value(forKey: "viewRegistry") as? [NSNumber: UIView]
        #endif
    }
  
    private func checkForViewTags() {
        guard let registry = getViewRegistry() else {
            print("⚠️ No view registry available")
            return
        }
        
        print("📋 Checking tags for \(pendingViews.count) pending views")
        
        // For each pending view, try to find its tag
        let pending = pendingViews.allObjects
        for view in pending {
            if let entry = registry.first(where: { $0.value === view }) {
                print("✅ Found tag \(entry.key) for pending view \(view)")
                viewToTagMap.setObject(entry.key, forKey: view)
                pendingViews.remove(view)
            } else {
                print("❓ No tag found for pending view \(view)")
            }
        }
        
        print("📊 Remaining pending views: \(pendingViews.count)")
    }
  
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc func load(_ reactTag: NSNumber, color: String?) {
        print("Load called with reactTag: \(reactTag)")
        
        // Print all views we're tracking
        print("Currently tracking \(viewToTagMap.count) views:")
        let allObjects = viewToTagMap.objectEnumerator()
        while let tag = allObjects?.nextObject() as? NSNumber {
            print("  - Tag: \(tag)")
        }
        
        #if RCT_NEW_ARCH_ENABLED
        // For Fabric on iOS, we still need to use bridge APIs to find views
        // The approach is similar to old architecture but with different implementations
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Try to find the view directly if possible
            if let view = self.bridge?.uiManager.view(forReactTag: reactTag) as? SomeNativeView {
                print("✅ Found Fabric view with tag \(reactTag)")
                
                // Store tag association
                self.viewToTagMap.setObject(reactTag, forKey: view)
                
                // Load with color
                let uiColor: UIColor? = color != nil ? self.hexStringToUIColor(hex: color!) : nil
                view.load(withColor: uiColor)
            } else {
                // Try our own map as a fallback
                let foundView = self.findSomeNativeViewInMapByTag(reactTag)
                
                if let view = foundView {
                    print("✅ Found view with tag \(reactTag) in our own map")
                    let uiColor: UIColor? = color != nil ? self.hexStringToUIColor(hex: color!) : nil
                    view.load(withColor: uiColor)
                } else {
                    print("❌ No view found with tag \(reactTag) in Fabric")
                }
            }
        }
        #else
        // For Old Architecture (Bridge)
        self.bridge?.uiManager.addUIBlock { [weak self] (uiManager, viewRegistry) in
            // Debug: Print all view registry entries for debugging
            print("View registry contains \(viewRegistry?.count ?? 0) views")
            
            // Analyze all views in registry for debugging
            if let registry = viewRegistry {
                for (tag, view) in registry {
                    print("Registry has view with tag \(tag), type: \(type(of: view))")
                }
            }
            
            if let view = viewRegistry?[reactTag] {
                print("Found view with tag \(reactTag), type: \(type(of: view))")
                
                // Check if the view is actually our custom view or a container
                if let someNativeView = view as? SomeNativeView {
                    print("✅ Successfully cast to SomeNativeView")
                    
                    // Store tag association
                    self?.viewToTagMap.setObject(reactTag, forKey: someNativeView)
                    
                    // Load with color
                    let uiColor: UIColor? = color != nil ?
                        self?.hexStringToUIColor(hex: color!) : nil
                    someNativeView.load(withColor: uiColor)
                }
                else {
                    print("❌ View is not a SomeNativeView, searching subviews...")
                    
                    // Try to find SomeNativeView in the view hierarchy
                    func findSomeNativeView(in view: UIView) -> SomeNativeView? {
                        if let someView = view as? SomeNativeView {
                            return someView
                        }
                        
                        for subview in view.subviews {
                            if let found = findSomeNativeView(in: subview) {
                                return found
                            }
                        }
                        
                        return nil
                    }
                    
                    if let foundView = findSomeNativeView(in: view) {
                        print("✅ Found SomeNativeView in subview hierarchy")
                        self?.viewToTagMap.setObject(reactTag, forKey: foundView)
                        
                        let uiColor: UIColor? = color != nil ?
                            self?.hexStringToUIColor(hex: color!) : nil
                        foundView.load(withColor: uiColor)
                    } else {
                        print("❌ No SomeNativeView found in view hierarchy")
                    }
                }
            } else {
                print("❌ No view found with tag \(reactTag) in registry")
            }
        }
        #endif
    }
  
    @objc func setInitialTag(_ initialTag: NSNumber) {
        // This method is called on the view manager, not the view
        // We need to get the current view and store the tag association
      if let lastView = self.bridge?.uiManager.view(forReactTag: initialTag) as? SomeNativeView {
            print("Registering view with initialTag: \(initialTag)")
            viewToTagMap.setObject(initialTag, forKey: lastView)
        } else {
            print("Warning: Could not find view with tag \(initialTag)")
        }
    }
    
    // MARK: - SomeNativeViewDelegate
    
    func someNativeView(_ view: SomeNativeView, didChangeState state: SomeNativeView.State) {
        // Try different ways to find the tag
        if case .initial = state {
              print("Skipping initial state event - view likely doesn't have a tag yet")
              return
          }
          
          // Try different ways to find the tag
          let reactTag: NSNumber?
          
          // First try our map
          if let tag = viewToTagMap.object(forKey: view) {
              reactTag = tag
              print("Found tag in viewToTagMap: \(tag)")
          }
          // Then try the view's reactTag property
          else if let uiView = view as? UIView, let tag = uiView.reactTag {
              reactTag = tag
              print("Using view's reactTag property: \(tag)")
          }
          // Finally try to find the view in the registry
          else if let registry = self.bridge?.uiManager.value(forKey: "viewRegistry") as? [NSNumber: UIView],
                    let entry = registry.first(where: { $0.value === view }) {
              reactTag = entry.key
              print("Found tag by searching viewRegistry: \(entry.key)")
              // Cache this for future use
              viewToTagMap.setObject(reactTag!, forKey: view)
          }
          else {
              print("Error: Cannot find reactTag for view using any method")
              return
          }
        
        // Rest of your method remains the same
        guard let module = self.bridge?.module(forName: "Inappstories") as? Inappstories else {
            print("Error: Cannot find Inappstories module")
            return
        }
        
        // Prepare basic event data
        let stateString: String
        
        switch state {
        case .initial:
            stateString = "initial"
            // Send a simple event without data for initial state
            let eventBody: [String: Any] = [
                "viewTag": reactTag,
                "state": stateString
            ]
            module.sendEvent(withName: "nativeViewStateChange", body: eventBody)
            
        case .loading:
            stateString = "loading"
            // Send a simple event without data for loading state
            let eventBody: [String: Any] = [
                "viewTag": reactTag,
                "state": stateString
            ]
            module.sendEvent(withName: "nativeViewStateChange", body: eventBody)
            
        case .loaded(let color):
               stateString = "loaded"
               let hexColor = safeColorToHex(color: color)
               let dataDict: [String: String] = ["color": hexColor]
               let eventBody: [String: Any] = [
                   "viewTag": reactTag,
                   "state": stateString,
                   "data": dataDict
               ]
          
          print("Sending loaded state event: \(eventBody)")
          module.sendEvent(withName: "nativeViewStateChange", body: eventBody)
      }
    }
    
    // MARK: - Helper methods
    
    private func findReactTag(for view: SomeNativeView) -> NSNumber? {
        // Use our map to find the tag
        return viewToTagMap.object(forKey: view)
    }
    
    private func hexStringToUIColor(hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        // Make sure the string is a valid hex color
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return .blue // Default if the hex string is invalid
        }
        
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
      
    private func safeColorToHex(color: UIColor) -> String {
        // Default value in case everything fails
        let defaultColor = "#000000"
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        // Try to get RGB components directly
        if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
            // Successfully got RGB components
        } else {
            // If the color isn't in RGB colorspace, try to get components
            guard let components = color.cgColor.components, components.count >= 3 else {
                return defaultColor
            }
            
            r = components[0]
            g = components[1]
            b = components[2]
        }
        
        // Convert to hex
        let red = Int(max(0, min(r * 255, 255)))
        let green = Int(max(0, min(g * 255, 255)))
        let blue = Int(max(0, min(b * 255, 255)))
        
        let hexString = String(format: "#%02x%02x%02x", red, green, blue)
        
        // Double-check we got a valid string
        return hexString.count == 7 ? hexString : defaultColor
    }

    // Helper method to find views in our map by tag
    private func findSomeNativeViewInMapByTag(_ reactTag: NSNumber) -> SomeNativeView? {
        for case let view as SomeNativeView in viewToTagMap.keyEnumerator().allObjects {
            if let tag = viewToTagMap.object(forKey: view), tag == reactTag {
                return view
            }
        }
        return nil
    }
}
