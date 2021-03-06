//
//  SpinnerViewControllerExtensions.swift
//  statisfy
//
//  Created by Avesta Barzegar on 2021-04-05.
//

import UIKit

enum SpinnerType {
    case basic
    case custom
}

var blocker: UIView?
var customSpinner: ProgressView?
var basicSpinner: UIView?
var spinnerType: SpinnerType?

extension UIViewController {
    
    func showSpinner(onView: UIView, type: SpinnerType = .custom, colors: [UIColor]? = SpinnerColors.normal) {
        spinnerType = type
        let blockerView = UIView()
        blockerView.frame = onView.frame
        blockerView.backgroundColor = .clear
        switch type {
        case .basic:
            let spinnerView = UIView()
            spinnerView.frame = blockerView.frame
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.startAnimating()
            activityIndicator.center = blockerView.center
            DispatchQueue.main.async {
                spinnerView.addSubview(activityIndicator)
                blockerView.addSubview(spinnerView)
                onView.addSubview(blockerView)
            }
            basicSpinner = spinnerView
        case .custom:
            let spinnerView = ProgressView(colors: colors ?? SpinnerColors.normal, lineWidth: 5.0)
            spinnerView.frame.size = CGSize(width: 50, height: 50)
            spinnerView.center = blockerView.center
            DispatchQueue.main.async {
                blockerView.addSubview(spinnerView)
                onView.addSubview(blockerView)
                spinnerView.isAnimating = true
            }
            customSpinner = spinnerView
        }
        blocker = blockerView
    }
    
    func removeSpinner() {
        switch spinnerType {
        case .basic:
            DispatchQueue.main.async {
                basicSpinner?.removeFromSuperview()
                blocker?.removeFromSuperview()
                basicSpinner = nil
                blocker = nil
            }
        case .custom:
            DispatchQueue.main.async {
                customSpinner?.isAnimating = false
                customSpinner?.removeFromSuperview()
                blocker?.removeFromSuperview()
                customSpinner = nil
                blocker = nil
            }
        case .none:
            customSpinner?.isAnimating = false
            customSpinner?.removeFromSuperview()
            blocker?.removeFromSuperview()
            basicSpinner?.removeFromSuperview()
            basicSpinner = nil
            customSpinner = nil
            blocker = nil
            debugPrint("Cannot remove a spinner that does not exist")
        }
        DispatchQueue.main.async {
            spinnerType = nil
        }
    }
}
