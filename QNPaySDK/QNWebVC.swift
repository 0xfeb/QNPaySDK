//
//  QNWebVC.swift
//  QNPaySDK
//
//  Created by 王渊鸥 on 2017/4/21.
//  Copyright © 2017年 王渊鸥. All rights reserved.
//

import UIKit
import Coastline

public class QNWebVC: UIViewController {
	var showWebView:UIWebView!
	var hideWebView:UIWebView!

    override public func viewDidLoad() {
        super.viewDidLoad()

		setupShowWebView()
		setupHideWebView()
		setupCloseButton()
    }

}

extension QNWebVC {
	func load(url:URL) {
		showWebView.loadRequest(URLRequest(url: url))
	}
	
	func setupShowWebView() {
		showWebView = UIWebView()
		view.addSubview(showWebView)
		
		let cTop = NSLayoutConstraint(item: showWebView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
		let cBottom = NSLayoutConstraint(item: showWebView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
		let cLeft = NSLayoutConstraint(item: showWebView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0.0)
		let cRight = NSLayoutConstraint(item: showWebView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0.0)
		showWebView.translatesAutoresizingMaskIntoConstraints = false
		view.addConstraints([cTop, cBottom, cLeft, cRight])
		
		showWebView.delegate = self
	}
	
	func setupHideWebView() {
		hideWebView = UIWebView()
		view.addSubview(hideWebView)
		hideWebView.isHidden = true
		
		hideWebView.delegate = self
		
		//---for debug
//		hideWebView.isHidden = false
//		hideWebView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
		//---for debug
	}
	
	func setupCloseButton() {
		let close = UIButton(type: .custom)
		
		if let closeImage = QNPay.shareInstance.closeButton {
			close.frame = CGRect(origin: CGPoint(x:20, y:30), size: CGSize(width:closeImage.size.width / UIScreen.main.scale, height:closeImage.size.height / UIScreen.main.scale))
			close.setImage(closeImage, for: .normal)
		} else {
			close.frame = CGRect(origin: CGPoint(x:20, y:30), size: CGSize(width:20, height:20))
			let layer = CAShapeLayer()
			let path = UIBezierPath()
			path.move(to: close.bounds.leftTop)
			path.addLine(to: close.bounds.rightBottom)
			path.move(to: close.bounds.rightTop)
			path.addLine(to: close.bounds.leftBottom)
			path.lineWidth = 2.0
			path.lineCapStyle = .round
			layer.path = path.cgPath
			layer.strokeColor = UIColor.darkGray.cgColor
			close.layer.addSublayer(layer)
		}
		
		close.addTarget(self, action: #selector(closeVC), for: .touchUpInside)
		self.view.addSubview(close)
	}
	
	func closeVC() {
		self.dismiss(animated: true, completion: nil)
	}
	
	func checkShemeCanOpen(scheme:String) -> Bool {
		guard let allowSchemes = UIApplication.shared.config("LSApplicationQueriesSchemes") as? [String] else { return false }
		if allowSchemes.contains(scheme) == false { return false }
		guard let url = (scheme+"://").url else { return false }
		return UIApplication.shared.canOpenURL(url)
	}
}

extension QNWebVC : UIWebViewDelegate {
	public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
		print(request.url?.absoluteString ?? "")
		
		return webView.redirect(show: showWebView, hide: hideWebView, request: request) { (request) -> UIWebView.Direct? in
			
			if let scheme = request.url?.scheme, scheme != "http", scheme != "https" {
				if checkShemeCanOpen(scheme: scheme) {
					UIApplication.shared.openURL(request.url!)
					self.dismiss(animated: true, completion: nil)
					return .stop
				} else {
					return .show
				}
			}
			
			return nil
		}
	}
}
