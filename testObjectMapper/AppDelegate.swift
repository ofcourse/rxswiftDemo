//
//  AppDelegate.swift
//  testObjectMapper
//
//  Created by macbook on 2018/3/31.
//  Copyright © 2018年 HSG. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import RxSwift
import RxCocoa
import OHHTTPStubs
import HandyJSON
import SwiftyJSON

class A : CustomDebugStringConvertible,CustomStringConvertible {
    
    init() {
    }
    
    var description: String {
        return "debugA"
    }
    //po中的调试信息
    var debugDescription: String {
        return "debugDescriptionA"
    }
}

public class User: Mappable {
    var name: String?
    
    init(){}
    
    required public init?(map: Map){
        
    }
    
    public func mapping(map: Map){
        name <- map["name"]
    }
}

class Hi: Mappable {
    var hello: String?
    var zero: Int?
    var foo: String?
    
    required init?(map: Map){
        if map.JSON["hello"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        hello <- map["hello"]
        zero <- map["zero"]
        foo <- map["foo"]
    }
}

//let jsonString = "{\"status\":200,\"message\":\"success\",\"data\":{\"hello\":null, \"f2oo\":\"b2ar\", \"z2ero\": 0}}"
class MapResopnseHI: BassResponseMap {
    public var result: Hi?
    required init?(map: Map){
        super.init(map: map)
    }
    override func mapping(map: Map) {
        super.mapping(map: map)
        result <- map["data"]
    }
}

class BassResponseMap: Mappable {
    var status:Int = 200
    var message:String?
    
    required init?(map: Map){
    }
    func mapping(map: Map) {
        status <- map["status"]
        message <- map["message"]
    }
}

//not working
class GenValue<Value> : Mappable {
    public var result: Value?
    var status:Int = 200
    var message:String?
    required init?(map: Map){
    }
    func mapping(map: Map) {
        result <- map["data"]
        status <- map["status"]
        message <- map["message"]
    }
}

class BasicTypes: HandyJSON {
    var int: Int = 2
    var doubleOptional: Double?
    var stringImplicitlyUnwrapped: String!
    
    required init() {}
}





@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //window?.rootViewController?.dismiss(animated: true, completion: nil)
        
//        let a  = A()
//        print("a:\(a)")
       
        //testAlamofireRequestResponse()
        //testAlamofireParameters()
        //testObjetMapper()
        //testRxArrayObject()
//        testRxObject()
//        testHandyJson()
        //testMapRxObject()
        testNormal()
        return true
    }
    
    func testRap2() {
        //http://rap2api.taobao.org/app/mock/25784/example/1533804054000
        
    }

    func testNormal() {
        //result.toJSON()
        
        let DataJSONContent = "{\"status\":200,\"message\":\"success\",\"data\":{\"hello\":null, \"foo\":\"bar\", \"zero\": 0}}"
        
        let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
        stub(condition: isHost("wwx.xxcocco.com")) { _ in
            return OHHTTPStubsResponse(data: DataJSON, statusCode:200, headers:nil)
        }
        
        testNormalRx(t: Hi.self).subscribe(onNext:{ result in
            //print(result.hello)
            print(result)
            print(result.foo)
        },onError:{ reuslt in
            print(reuslt)
        })
        
    }
    
    func testNormalRx<T: Mappable>(t:T.Type)-> Observable<T> {
        // alamorefire错误用的是NSError
        // rxswift senderror Swift.Error
        return Observable.create { observer in
            let Url = "http://wwx.xxcocco.com"
            let request = Alamofire.request(Url, method: .get).responseData { (response) in
                 DispatchQueue.global(qos: .default).async {
                let json = try! JSON(data: response.data!)
                if  json["status"].int != 200 {
                    //Now you got your value
                    let testError = NSError(domain: "status not 200", code: -1, userInfo: nil)
                    observer.on(.error(testError))
                }
                else {
                     let dict = json["data"].dictionaryObject
                     let re =  Mapper<T>().map(JSON:dict!)
                    observer.on(.next(re!))
                    observer.on(.completed)
                  }
                }
                }
            return Disposables.create {request.cancel()}
            }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .default))
                
//                if response.error == nil {
//                    let r = response.result.value?.toJSON()
//                    if r!["status"] as! Int == 200 {
//                        let re = r!["data"]
//                        if let mappedObject = response.result.value {
//                            observer.on(.next(mappedObject))
//                            observer.on(.completed)
//                        } else {
//                            let testError = NSError(domain: "mappedObject nil", code: -1, userInfo: nil)
//                            observer.on(.error(response.error!))
//                        }
//                    } else  {
//                        print("status error not 200")
//                         let testError = NSError(domain: "status error not 200", code: -1, userInfo: nil)
//                         observer.on(.error(response.error!))
//                    }
//
//                } else {
//                    //NSURLErrorDomain
//                    //就算json串没有model中对应的字段也会解析成功，自动生成相应的实例，只不过相关属性全都是nil
//                    let error = response.error! as NSError
//                    switch  error.code {
//                    case  1:
//                        print("no data")
//                        print(error.localizedFailureReason)
//                    case 2:
//                        print("服务异常，返回格式出错")
//                        print(error.localizedFailureReason)
//                    default:
//                        print(error.localizedFailureReason)
//                        print("unknow ")
//                    }
//                    print("error.domain:  \(error.domain)")
//                    if error.domain == "NSURLErrorDomain" {
//                        print("网络异常，请稍后再试")
//                    }
//                    print(error)
//                    observer.on(.error(response.error!))
//                }
                
            //}
//            return Disposables.create {
//                //request.cancel()
//            }
       // }
    }
    
//    func  testMapGenRxObject() {
//        let DataJSONContent = "{\"status\":300,\"message\":\"success\",\"data\":{\"hello\":null, \"foo\":\"bar\", \"zero\": 0}}"
//
//        let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
//        stub(condition: isHost("wwx.xxcocco.com")) { _ in
//            return OHHTTPStubsResponse(data: DataJSON, statusCode:200, headers:nil)
//        }
//
//        testMapRx(t: MapResopnseHI.self,url:"http://wwx.xxcocco.com").subscribe(onNext:{ result in
//            //print(result.hello)
//            print(result)
//            // print(result.result)
//        },onError:{ reuslt in
//            print(reuslt)
//        })
//
//    }
    
    func  testMapRxObject() {
        let DataJSONContent = "{\"status\":300,\"message\":\"success\",\"data\":{\"hello\":null, \"foo\":\"bar\", \"zero\": 0}}"
        
        let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
        stub(condition: isHost("wwx.xxcocco.com")) { _ in
            return OHHTTPStubsResponse(data: DataJSON, statusCode:200, headers:nil)
        }
        
        testMapRx(t: MapResopnseHI.self,url:"http://wwx.xxcocco.com").subscribe(onNext:{ result in
            //print(result.hello)
            print(result)
           // print(result.result)
        },onError:{ reuslt in
            print(reuslt)
        })
        
    }
    
    func testHandyJson() {
        //一个字段都没有，还会解析生成默认对象;
        let jsonString = "{\"doub2leOptional2\":1.1,\"stringI2mplicitlyUnwrapped2\":\"hello2\",\"int2\":1}"
        //let jsonString = "{}" //如果是""解析对象就是nil,如是{},不管有无类属性，返回默认值的解析对象
        
        let d = BasicTypes.deserialize(from: jsonString)
        print(d)
        if let object = d {
            print(object.int)
            print(object.doubleOptional!)
            print(object.stringImplicitlyUnwrapped)
        }
    }
    //让xcode推断出范型的类型
    
    //Typically there are many ways to define generic functions. But they are based on condition that Tmust be used as a parameter, or  //return type
    func testRxObject() {
        //null自动转换属性为nil
        //"",{}抛序列化错误,如果有一个字段，就会解析成功;如果一个字段都没有解析到，就会解析失败
        let DataJSONContent = "{\"hello\":null, \"f2oo\":\"b2ar\", \"z2ero\": 0}" //{\"hello\":null, \"foo\":\"b2ar\", \"z2ero\": 0}
        let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
        stub(condition: isHost("wwx.xxcocco.com")) { _ in
            return OHHTTPStubsResponse(data: DataJSON, statusCode:200, headers:nil)
        }
        
        //testRx<Hi>().subscribe { print($0) }
        
//        let signal :Observable<Hi> =  testRx()
//        signal.subscribe(onNext:{ result in
//            print(result.foo)
//            print(result)
//        })
        testRx(t: Hi.self).subscribe(onNext:{ result in
            print(result.hello)
            print(result)
            
        },onError:{ reuslt in
            print(reuslt)
        })
        //not working
//        testRx<Hi>().subscribe(onNext:{ result in
//            print(result.foo)
//            print(result)
//        })
    }
    
    
    func testRxArrayObject() {
        //let DataJSONContent = "[{\"h2ello\":\"w2orld\", \"f2oo\":\"b2ar0\", \"z2ero\": 0},{\"hello\":\"world\", \"foo\":\"bar\", \"zero\": 0}]"
        let DataJSONContent = "[{\"h2ello\":\"w2orld\", \"f2oo\":\"b2ar0\", \"z2ero\": 0},[{\"h2ello\":\"w2orld\", \"f2oo\":\"b2ar0\", \"z2ero\": 0},"
        let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
        stub(condition: isHost("wwx.xxcocco.com")) { _ in
            return OHHTTPStubsResponse(data: DataJSON, statusCode:200, headers:nil)
        }
        
        //testRx<Hi>().subscribe { print($0) }
        
        let signal :Observable<[Hi]> =  testRxArray()
        signal.subscribe(onNext:{ result in
            print(result)
            print(result[0].foo)
        },onError:{ reuslt in
            print(reuslt)
        })
    }
    
    //Cannot explicitly specialize a generic function
   //https://blog.csdn.net/feifeiwuxian/article/details/79196058
    func testRx<T: Mappable>(t:T.Type)-> Observable<T> {
       // alamorefire错误用的是NSError
       // rxswift senderror Swift.Error
       return Observable.create { observer in
        let Url = "http://wwx.xxcocco.com"
        let request = Alamofire.request(Url, method: .get).responseObject{ (response: DataResponse<T>) in
            
            if response.error == nil {
                if let mappedObject = response.result.value {
                    observer.on(.next(mappedObject))
                    observer.on(.completed)
                } else {
                    print("error2233")
                }
            } else {
                //NSURLErrorDomain
                //就算json串没有model中对应的字段也会解析成功，自动生成相应的实例，只不过相关属性全都是nil
                let error = response.error! as NSError
                switch  error.code {
                    case  1:
                        print("no data")
                        print(error.localizedFailureReason)
                    case 2:
                     print("服务异常，返回格式出错")
                     print(error.localizedFailureReason)
                    default:
                       print(error.localizedFailureReason)
                       print("unknow ")
                }
                print("error.domain:  \(error.domain)")
                if error.domain == "NSURLErrorDomain" {
                    print("网络异常，请稍后再试")
                }
                //These error codes are for NSError objects in the domain NSURLErrorDomain https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes
//                (NSError) $R0 = 0x000060400005b1b0 domain: "NSURLErrorDomain" - code: 18446744073709550613 {
//                    ObjectiveC.NSObject = {
//                        baseNSObject@0 = {
//                            isa = NSURLError
//                        }
//                        _reserved = 0x0000000000000000
//                        _code = -1003
//                        _domain = 0x000000010b0ae7e8 "NSURLErrorDomain"
//                        _userInfo = 0x00006040000e6200 6 key/value pairs
//                    }
//                }
                print(error)
                observer.on(.error(response.error!))
            }
           
        }
         return Disposables.create {
                request.cancel()
            }
        }
    }
    
    
    func testMapRx<T: BassResponseMap>(t:T.Type,url:String) -> Observable<BassResponseMap> {
        //MapResopnse
        return Observable.create { observer in
            let request = Alamofire.request(url, method: .get).responseObject{ (response: DataResponse<T>) in
                
                if response.error == nil {
                    if let mappedObject = response.result.value as BassResponseMap?{
                        if mappedObject.status != 200 {
                            let testError = NSError(domain: "RxAlamofire status eror need toast", code: -1, userInfo: nil)
                            observer.on(.error(testError))
                        } else {
                            observer.on(.next(mappedObject))
                            observer.on(.completed)
                        }
                    } else {
                        let testError = NSError(domain: "RxAlamofire status not have data", code: -1, userInfo: nil)
                        observer.on(.error(testError))
                    }
                } else {
                    //NSURLErrorDomain
                    //就算json串没有model中对应的字段也会解析成功，自动生成相应的实例，只不过相关属性全都是nil
                    let error = response.error! as NSError
                    switch  error.code {
                    case  1:
                        print("no data")
                        print(error.localizedFailureReason)
                    case 2:
                        print("服务异常，返回格式出错")
                        print(error.localizedFailureReason)
                    default:
                        print(error.localizedFailureReason)
                        print("unknow ")
                    }
                    print("error.domain:  \(error.domain)")
                    if error.domain == "NSURLErrorDomain" {
                        print("网络异常，请稍后再试")
                    }
                    //These error codes are for NSError objects in the domain NSURLErrorDomain https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes
                    //                (NSError) $R0 = 0x000060400005b1b0 domain: "NSURLErrorDomain" - code: 18446744073709550613 {
                    //                    ObjectiveC.NSObject = {
                    //                        baseNSObject@0 = {
                    //                            isa = NSURLError
                    //                        }
                    //                        _reserved = 0x0000000000000000
                    //                        _code = -1003
                    //                        _domain = 0x000000010b0ae7e8 "NSURLErrorDomain"
                    //                        _userInfo = 0x00006040000e6200 6 key/value pairs
                    //                    }
                    //                }
                    print(error)
                    observer.on(.error(response.error!))
                }
                
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    // not working
    func testRx<T: Mappable>()-> Observable<T> {
        
        //let myClass: AnyClass = type(of: T)
        return testRx(t: T.self)
    }
    
    func testRxArray<T: Mappable>() -> Observable<[T]> {
        
        return Observable.create { observer in
            let Url = "http://wwx.xxcocco.com"
            let request = Alamofire.request(Url, method: .get).responseArray{ (response: DataResponse<[T]>) in
                if let mappedObject = response.result.value {
                    observer.on(.next(mappedObject))
                    observer.on(.completed)
                } else {
                    let testError = NSError(domain: "RxAlamofire Error", code: -1, userInfo: nil)
                    observer.on(.error(testError))
                }
            }
            return Disposables.create {
                request.cancel()
            }
        }
        
    }
    
    func testObjetMapper()  {
        let name = "Tristan"
        var user = User()
        user.name = name
        
        let JSON = "{\"name\" : nil}"
        user = Mapper<User>().map(JSONString: JSON, toObject: user)
        
        print(user.name)
    }
    
    func testAlamofireParameters() {
        //get
        let paras: Parameters = ["foo": "bar"]
        Alamofire.request("http://www.baidu.com/get?a=2",parameters:paras).response { (response) in
            print("RequestData: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))")
        }
        //post http body
        let parameters: Parameters = [
            "foo": "bar",
            "baz": ["a", 1],
            "qux": [
                "x": 1,
                "y": 2,
                "z": 3
            ]
        ]
        
        // All three of these calls are equivalent
        Alamofire.request("https://httpbin.org/post", method: .post, parameters: parameters).response { (response) in
            print("RequestData: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))")
        }
    }
    
    func testAlamofireRequestResponse() {
        let request  = Alamofire.request("http://www.baidu.com")
        request.responseData { (response) in
            print("RequestData: \(String(describing: response.request))")   // original url request
            print("Response: \(String(describing: response.response))") // http url response
            //print("Result: \(response.result)")
            
            print("Error: \(response.error)")
            debugPrint("All Response Info: \(response)")
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
        }
        
        request.responseString { (response) in
            print("responseString Success: \(response.result.isSuccess)")
            print("Response String: \(response.result.value)")
        }
        
        let uQueue = DispatchQueue.global(qos: .background)
        request.responseString(queue: uQueue) { (_) in
            print("responseString Executing response handler on background queue")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

