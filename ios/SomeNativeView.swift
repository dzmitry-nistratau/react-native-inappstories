//
//  SomeNativeView.swift
//  Inappstories
//
//  Created by Dzmitry Nistratau on 26/03/2025.
//

import UIKit

protocol SomeNativeViewDelegate: AnyObject {
  func someNativeView(_ view: SomeNativeView, didChangeState state: SomeNativeView.State)
}

class SomeNativeView: UIView {    
    enum State {
        case initial
        case loading
        case loaded(color: UIColor)
    }
    
    weak var delegate: SomeNativeViewDelegate?
    
    var suppressEventsTemporarily = false
    
    private var state: State = .initial {
        didSet {
            updateUI()
            if !suppressEventsTemporarily {
                delegate?.someNativeView(self, didChangeState: state)
            }
        }
    }
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .blue
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let loadedLabel: UILabel = {
        let label = UILabel()
        label.text = "Loaded"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.isHidden = true
        label.textColor = .black
        return label
    }()
    
    override init(frame: CGRect) {
         super.init(frame: frame)
         setupUI()
     }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        // Add activity indicator
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Add loaded label
        addSubview(loadedLabel)
        loadedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadedLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadedLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        // Initialize UI based on current state
        updateUI()
    }
    
    func load(withColor color: UIColor?) {
        // Set state to loading
        state = .loading
        
        // Simulate async loading
        DispatchQueue.global(qos: .background).async {
            // Simulate a delay
            sleep(2)
            
            // Return to main thread to update UI
            DispatchQueue.main.async {
                // Set to loaded state with provided color or default to blue
                let finalColor = color ?? UIColor.blue
                self.state = .loaded(color: finalColor)
            }
        }
    }
  
    func setState(_ newState: State) {
        print("🔄 Setting state to: \(newState) on \(self)")
        self.state = newState
    }
    
    private func updateUI() {
        print("🎨 Updating UI for state: \(state)")
        switch state {
        case .initial:
            backgroundColor = .clear
            activityIndicator.stopAnimating()
            loadedLabel.isHidden = true
            
        case .loading:
            backgroundColor = .clear
            activityIndicator.startAnimating()
            loadedLabel.isHidden = true
            
        case .loaded(let color):
            backgroundColor = color
            activityIndicator.stopAnimating()
            loadedLabel.isHidden = false
        }
        
        #if RCT_NEW_ARCH_ENABLED
        print("🧩 In Fabric: Activity indicator visible = \(!activityIndicator.isHidden), animating = \(activityIndicator.isAnimating)")
        #else
        print("🧩 In Old Arch: Activity indicator visible = \(!activityIndicator.isHidden), animating = \(activityIndicator.isAnimating)")
        #endif
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Ensure subviews are positioned correctly
        if activityIndicator.superview != nil {
            activityIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        
        if loadedLabel.superview != nil {
            loadedLabel.center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        
        #if RCT_NEW_ARCH_ENABLED
        print("📐 Layout performed in Fabric, bounds: \(bounds)")
        #else
        print("📐 Layout performed in Old Arch, bounds: \(bounds)")
        #endif
    }
}

