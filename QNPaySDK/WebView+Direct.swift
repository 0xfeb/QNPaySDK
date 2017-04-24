//
//  WebView+Direct.swift
//  QNPaySDK
//
//  Created by 王渊鸥 on 2017/4/21.
//  Copyright © 2017年 王渊鸥. All rights reserved.
//

import UIKit

extension UIWebView {
	enum Direct {
		case hide
		case show
		case stop
	}
	
	//此函数用在webView的回调中, rule函数是规则制定者, 返回hide, 则跳到hide的WebView, 返回show, 则跳到show的WebView, 返回nil, 则不跳动
	func redirect(show:UIWebView, hide:UIWebView, request:URLRequest, rule:(URLRequest) -> Direct?) -> Bool {
		guard let direct = rule(request) else { return true }		//返回nil, 不跳动
		
		switch direct {
		case .hide:
			if self == hide { return true }
			
			hide.loadRequest(request)
			return false
		case .show:
			if self == show { return true }
			
			show.loadRequest(request)
			return false
		case .stop:
			return false
		}
	}
}
