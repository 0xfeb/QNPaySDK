//
//  QNPay.swift
//  QNPaySDK
//
//  Created by 王渊鸥 on 2017/4/21.
//  Copyright © 2017年 王渊鸥. All rights reserved.
//

import Foundation
import Coastline

public class QNPay {
	public static var shareInstance:QNPay = { QNPay() }()
	
	public var closeButton:UIImage?
	public var baseUrl = "http://laaaa.6655.la:1288"
	public var appKey = "c4ca4238a0b923820dcc509a6f75849b"
	public var appId = 1
	public var originUserId = "1"
	
	var notiBag:CLNotificationBag = CLNotificationBag()
	
	public func registerQueue(notify: @escaping (Bool, QNOrder)->()) {
		let q = QNOrderQueue.shareInstance
		q.check()
		
		NotificationCenter.received(Notification.Name.orderQueueFaild) { (order) in
			//收到订单正确的信息
			notify(true, QNOrder(dict: order as! [String : Any])!)
		}.addBag(notiBag)
		
		_ = NotificationCenter.received(Notification.Name.orderQueueFaild) { (order) in
			//收到订单错误的信息
			notify(false, QNOrder(dict: order as! [String : Any])!)
		}.addBag(notiBag)
	}
}

public enum QNPayError  : Error{
	case hasNotTrust
	case payChannelNotExists
}

public extension Notification.Name {
	public static let orderQueueSuccess = "orderQueueSuccess"
	public static let orderQueueFaild = "orderQueueFaild"
}
