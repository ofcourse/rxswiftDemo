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

typealias ValidSuccessClosure = (_ data: Data) -> Void
typealias ErrorClosure =  (_ error: NSError) -> Void

public class NetworkingHelpers {
   
    public static func netSignal<T: Mappable>(t:T.Type, url:String)-> Observable<T> {
        return  netSignal(t: t, url: url,parameters:[:])
    }
    
   public static func netSignal<T: Mappable>(t:T.Type, url:String,parameters: Parameters)-> Observable<T> {
        return Observable.create { observer in
            
            let headers: HTTPHeaders = ["Accept": "application/json"]
            let request = Alamofire.request(url, method: .post, parameters:parameters, headers:headers).responseData(queue:DispatchQueue.global(qos: .default)) { (response) in
                if response.error == nil {
                    let dict = try? JSON(data: response.data!)
                    if dict != nil {
                        if isValidResponse(data:response.data!) {
                            let re =  Mapper<T>().map(JSON:dict!["data"].dictionaryObject!)
                            observer.on(.next(re!))
                            observer.on(.completed)
                        } else {
                            if isValidErrorResponse(data: response.data!) {
                                let testError = NSError(domain: "status not 200", code: 2, userInfo: dict!.dictionaryObject)
                                observer.on(.error(testError))
                            } else {
                                //后台返回结构出错
                                let dataStructError = NSError(domain: "data struct error", code: 1, userInfo: dict!.dictionaryObject)
                                observer.on(.error(dataStructError))
                            }
                        }
                    } else {
                        let dataStructError = NSError(domain: "data struct error", code: 1, userInfo: dict!.dictionaryObject)
                        observer.on(.error(dataStructError))
                    }
                } else {
                    //网络异常,请稍后再试
                    //服务异常，请稍后再试
                    observer.on(.error(response.error!))
                }
            }
            return Disposables.create {request.cancel()}
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    public static func netArraySignal<T: Mappable>(t:T.Type, url:String)-> Observable<[T]> {
        return  netArraySignal(t: t, url: url,parameters:[:])
    }
    
    public static func netArraySignal<T: Mappable>(t:T.Type, url:String,parameters: Parameters)-> Observable<[T]> {
        return Observable.create { observer in
            
            let headers: HTTPHeaders = ["Accept": "application/json"]
            let request = Alamofire.request(url, method: .post, parameters:parameters, headers:headers).responseData(queue:DispatchQueue.global(qos: .default)) { (response) in
                if response.error == nil {
                    let dict = try? JSON(data: response.data!)
                    if dict != nil {
                        if isValidResponse(data:response.data!) {
                            let d = dict!["data"].object
                            let re =  Mapper<T>().mapArray(JSONObject:d)
                            observer.on(.next(re!))
                            observer.on(.completed)
                        } else {
                            if isValidErrorResponse(data: response.data!) {
                                let testError = NSError(domain: "status not 200", code: 2, userInfo: dict!.dictionaryObject)
                                observer.on(.error(testError))
                            } else {
                                //后台返回结构出错
                                let dataStructError = NSError(domain: "data struct error", code: 1, userInfo: dict!.dictionaryObject)
                                observer.on(.error(dataStructError))
                            }
                        }
                    } else {
                        let dataStructError = NSError(domain: "data struct error", code: 1, userInfo: dict!.dictionaryObject)
                        observer.on(.error(dataStructError))
                    }
                } else {
                    //网络异常,请稍后再试
                    //服务异常，请稍后再试
                    observer.on(.error(response.error!))
                }
            }
            return Disposables.create {request.cancel()}
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
    }
    
    private static func netHelpe(isArray:Bool, url:String,parameters: Parameters,success:@escaping ValidSuccessClosure,error:@escaping ErrorClosure) -> DataRequest {
        let headers: HTTPHeaders = ["Accept": "application/json"]
        return Alamofire.request(url, method: .post, parameters:parameters, headers:headers).responseData(queue:DispatchQueue.global(qos: .default)) { (response) in
            if response.error == nil {
                let dict = try? JSON(data: response.data!)
                if dict != nil {
                    if isValidResponse(data:response.data!) {
                        success(response.data!)
                    } else {
                        if isValidErrorResponse(data: response.data!) {
                            let statusError = NSError(domain: "status not 200", code: 2, userInfo: dict!.dictionaryObject)
                            //observer.on(.error(testError))
                            error(statusError)
                            
                        } else {
                            //后台返回结构出错
                            let dataStructError = NSError(domain: "data struct error", code: 1, userInfo: dict!.dictionaryObject)
                            error(dataStructError)
                            //observer.on(.error(dataStructError))
                        }
                    }
                } else {
                    let dataStructError = NSError(domain: "data struct error", code: 1, userInfo: dict!.dictionaryObject)
                    //observer.on(.error(dataStructError))
                    error(dataStructError)
                }
            } else {
                //网络异常,请稍后再试
                //服务异常，请稍后再试
                //observer.on(.error(response.error!))
                error(response.error! as NSError)
            }
        }
    }
    
    
    //token过期要特殊处理 status = 304?
    static func isValidErrorResponse(data: Data?) -> Bool {
        guard data != nil  else {
            return false
        }
        
        let dict = try? JSON(data: data!)
        guard dict != nil  else {
            return false
        }
        
        if  dict!["status"].int != 200 {
            return false
        }
        
        if  dict!["message"].string == nil {
            return false
        }
        return true
    }
    
    static func isValidResponse(data: Data?) -> Bool {
        guard data != nil  else {
            return false
        }
        
        let dict = try? JSON(data: data!)
        guard dict != nil  else {
            return false
        }
        
        if  dict!["status"].int != 200 {
            return false
        }
        
        if  dict!["message"].string == nil {
            return false
        }
        
        if  dict!["data"].dictionaryObject == nil && (dict!["data"].arrayObject == nil){
            return false
        }
        return true
    }
}
