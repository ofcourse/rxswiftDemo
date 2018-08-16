//
//  NetworkingHelpers.swift
//  testObjectMapper
//
//  Created by macbook on 2018/8/14.
//  Copyright © 2018年 HSG. All rights reserved.
//

import Foundation

import HandyJSON
import SwiftyJSON
import ObjectMapper
import Alamofire
import RxSwift

typealias ValidSuccessClosure = (_ data: JSON) -> Void
typealias ErrorClosure =  (_ error: NSError) -> Void

public class NetworkingHelpers {
    
    public static func modelSignal<T: BaseMuateMappable>(t:T.Type, url:String)-> Observable<T?> {
        return  modelSignal(t: t, url: url,parameters:[:])
    }
    
    public static func modelSignal<T: BaseMuateMappable>(t:T.Type, url:String,parameters: Parameters)-> Observable<T?> {
        
        return Observable.create { observer in
                let request = netRequestHelper(url: url, parameters: parameters, success: { (response) in
                    let data = response["data"].dictionaryObject
                    if data?.keys.count == 0 {
                        observer.on(.next(nil))
                    } else {
                        let result = Mapper<T>().map(JSONObject:data)
                        observer.on(.next(result!))
                    }
                    observer.on(.completed)
                }, error: { (dataError) in
                    observer.on(.error(dataError))
                })
               return Disposables.create {request.cancel()}
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    public static func netArraySignal<T: Mappable>(t:T.Type, url:String)-> Observable<[T]> {
        return  arrayModelSignal(t: t, url: url,parameters:[:])
    }
    
    public static func arrayModelSignal<T: Mappable>(t:T.Type, url:String,parameters: Parameters)-> Observable<[T]> {
        return Observable.create { observer in
                let request = netRequestHelper(url: url, parameters: parameters, success: { (response) in
                    let data = response["data"].object
                    let result = Mapper<T>().mapArray(JSONObject:data)
                    observer.on(.next(result!))
                    observer.on(.completed)
                }, error: { (dataError) in
                    observer.on(.error(dataError))
                })
               return Disposables.create {request.cancel()}
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    private static func netRequestHelper(url:String,parameters: Parameters,success:@escaping ValidSuccessClosure,error:@escaping ErrorClosure) -> DataRequest {
        let headers: HTTPHeaders = ["Accept": "application/json"]
        return Alamofire.request(url, method: .post, parameters:parameters, headers:headers).responseData(queue:DispatchQueue.global(qos: .default)) { (response) in
            if response.error == nil {
                let dict = try? JSON(data: response.data!)
                if dict != nil {
                    if isValidResponse(dict!) {
                        success(dict!)
                    } else {
                        if isValidErrorResponse(dict!) {
                            let statusError = NSError(domain: "status not 200", code: 2, userInfo: dict!.dictionaryObject)
                            error(statusError)
                        } else {
                            //后台返回结构出错
                            let dataStructError = NSError(domain: "data struct error", code: 1, userInfo: dict!.dictionaryObject)
                            error(dataStructError)
                        }
                    }
                } else {
                    let dataStructError = NSError(domain: "data struct error", code: 1, userInfo: dict!.dictionaryObject)
                    error(dataStructError)
                }
            } else {
                //网络异常,请稍后再试
                //服务异常，请稍后再试
                error(response.error! as NSError)
            }
        }
    }
    
    //token过期要特殊处理 status = 304?
  public  static func isValidErrorResponse(_ dict: JSON) -> Bool {
        if  dict["status"].int != 200 {
            return false
        }
        
        if  dict["message"].string == nil {
            return false
        }
        return true
    }
    
  public  static func isValidResponse(_ dict: JSON) -> Bool {
        if  dict["status"].int != 200 {
            return false
        }
        
        if  dict["message"].string == nil {
            return false
        }
        
    if dict["data"].dictionaryObject == nil && dict["data"].arrayObject == nil && (dict["data"].dictionaryObject?.keys.count)! > 0 {
            return false
        }
        return true
    }
}
