//
//  QNQuery.swift
//  QNPaySDK
//
//  Created by 王渊鸥 on 2017/4/21.
//  Copyright © 2017年 王渊鸥. All rights reserved.
//

import Foundation
import Coastline

public class QNQuery {
	public static var shareInstance:QNQuery = { QNQuery() }()
	
	init() {}
	
	enum QueryError : Error {
		case canNotGetUrl
		case canNotParseJSON
	}
	
	func jsonDataToBase64(dict:[AnyHashable:Any]) -> String? {
		guard let data = try? JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions()) else { return nil }
		return data.string
	}
	
	func mixUrl(params:[AnyHashable:Any], action:String) -> String {
		let data = jsonDataToBase64(dict: params)?.base64Enc ?? ""
		let t = Int(Date().timeIntervalSince1970 * 1000)
		let sign = (data + QNPay.shareInstance.appKey + "\(t)").md5
		
		var fullUrl = QNPay.shareInstance.baseUrl + action
		fullUrl += "?sign=" + (sign.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ??  sign)
		fullUrl += "&data=" + (data.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? data)
		fullUrl += "&signType=md5"
		fullUrl += "&t=\(t)"
		return fullUrl
	}
	
	func query(action:String, params:[AnyHashable:Any], method:String, resp:@escaping ([AnyHashable:Any]?, Error?)->()) {
		let data = jsonDataToBase64(dict: params)?.base64Enc ?? ""
		let t = Int(Date().timeIntervalSince1970 * 1000)
		let sign = (data + QNPay.shareInstance.appKey + "\(t)").md5
		
		var fullUrl = QNPay.shareInstance.baseUrl + action
		var body:Data?
		if method == "GET" {
			fullUrl += "?sign=" + (sign.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ??  sign)
			fullUrl += "&data=" + (data.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? data)
			fullUrl += "&signType=md5"
			fullUrl += "&t=\(t)"
		} else {
			let jsonObj:[String:Any] = ["data":data, "sign":sign, "signType":"md5", "t":t]
			body = try? JSONSerialization.data(withJSONObject: jsonObj, options: JSONSerialization.WritingOptions())
		}
		
		guard let url = URL(string: fullUrl) else {
			resp(nil, QueryError.canNotGetUrl)
			return
		}
		
		if method == "GET" {
			print("GET ----->", url.absoluteString)
			
			let request = url.request
			NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue(), completionHandler: { (response, data, error) in
				if let d = data?.prettyJsonString {
					print("==", d)
				}
		
				if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) {
					resp(json as? [AnyHashable:Any], nil)
				} else {
					resp(nil, error ?? QueryError.canNotParseJSON)
				}
			})
		} else {
			print("POST ----->", url.absoluteString)
			
			let request = NSMutableURLRequest(url: url)
			request.httpMethod = method
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			request.httpBody = body
			
			NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue(), completionHandler: { (response, data, error) in
				if let d = data?.prettyJsonString {
					print("==", d)
				}
				
				if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) {
					resp(json as? [AnyHashable:Any], nil)
				} else {
					resp(nil, error ?? QueryError.canNotParseJSON)
				}
			})
		}
	}
}

extension QNQuery {
	public func orderNew(appId:Int, originOrderId:String, uid:String, data:String, price:Int, payType:[String]?, resp:@escaping ([AnyHashable:Any]?, Error?)->()) {
		var dict:[String:Any] = ["app_id":appId, "origin_order_id":originOrderId, "uid":uid, "data":data, "price":price]
		if let payType = payType, payType.count > 0 {
			dict["pay_type"] = payType
		}
		
		query(action: "/order/new", params: dict, method: "POST", resp: resp)
	}
	
	public func orderPay(content:String, payType:String, receipt:String?, resp:@escaping ([AnyHashable:Any]?, Error?)->()) {
		var dict:[String:Any] = ["content":content, "pay_type":payType]
		if let receipt = receipt {
			dict["receipt"] = receipt
		}
		
		query(action: "/order/pay", params: dict, method: "POST", resp: resp)
	}
	
	public func trustUrl(trust:String, payType:String) -> String {
		return mixUrl(params: ["trust":trust, "pay_type":payType], action: "/order/trust_pay")
	}
	
	public func checkUrl(orderId:String) -> String {
		return mixUrl(params: ["order_id":orderId], action: "/order/check")
	}
	
	public func orderCheck(orderId:String, resp:@escaping ([AnyHashable:Any]?, Error?)->()) {
		let dict:[String:Any] = ["order_id":orderId]
		query(action: "/order/check", params: dict, method: "GET", resp: resp)
	}
}
