//
//  ViewAssistant.swift
//  Pixel Nodes
//
//  Created by Hexagons on 2017-12-05.
//  Copyright © 2017 Hexagons. All rights reserved.
//

import UIKit

class ViewAssistant {
    
    static let shared = ViewAssistant()
    
    var vc: UIViewController? {
        return UIApplication.shared.keyWindow!.rootViewController
    }
    
//    var view_bounds: CGRect?
    
    // MARK: Alert
    
    struct AlertAction {
        let title: String
        let style: UIAlertAction.Style
        let handeler: ((UIAlertAction) -> ())?
    }
    
    func alert(_ title: String? = nil, _ message: String? = nil, actions: [AlertAction] = [], sheet_view: UIView? = nil, dismiss: String? = "Dismiss", present_completion: (() -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: sheet_view != nil ? .actionSheet : .alert)
        if sheet_view != nil {
            alert.popoverPresentationController!.sourceView = sheet_view!
            alert.popoverPresentationController!.sourceRect = sheet_view!.bounds
        }
        if !actions.isEmpty {
            for action in actions {
                alert.addAction(UIAlertAction(title: action.title, style: action.style, handler: action.handeler))
            }
        }
        if dismiss != nil {
            alert.addAction(UIAlertAction(title: dismiss!, style: .cancel, handler: nil))
        }
        self.vc!.present(alert, animated: true, completion: present_completion)
    }

}
