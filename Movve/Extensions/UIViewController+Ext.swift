//
//  UIViewController+Ext.swift
//  Movve
//
//  Created by Petar Glusac on 28.3.21..
//

import UIKit

fileprivate var containerView: UIView!

extension UIViewController {
    
    func showLoadingScreen(backgroundAlpha: CGFloat = 1) {
        containerView = UIView(frame: view.frame)
        containerView.backgroundColor = .mBackground
        containerView.alpha = backgroundAlpha
        view.addSubview(containerView)
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.safeAreaLayoutGuide.layoutFrame.height * 0.25),
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
        
        activityIndicator.startAnimating()
    }
    
    func dismissLoadingScreen() {
        DispatchQueue.main.async {
            containerView.removeFromSuperview()
            containerView = nil
        }
    }
    
    func dismissKeyboard(sender: UIView) {
        sender.resignFirstResponder()
    }
    
    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default))
        
        present(alertController, animated: true)
    }
    
}
