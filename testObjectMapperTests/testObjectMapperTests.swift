//
//  testObjectMapperTests.swift
//  testObjectMapperTests
//
//  Created by macbook on 2018/3/31.
//  Copyright © 2018年 HSG. All rights reserved.
//

import XCTest
import ObjectMapper
import Alamofire
import AlamofireObjectMapper
import RxSwift
import RxCocoa
import OHHTTPStubs
import HandyJSON
import SwiftyJSON


@testable import testObjectMapper

class testObjectMapperTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResponse() {
        //model
        let DataJSONContent = "{\"status\":200,\"message\":\"success\",\"data\":{}}"
        let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
        let dict = try? JSON(data: DataJSON)
        XCTAssertTrue(NetworkingHelpers.isValidResponse(dict!, isArray: false))
        
        
        let DataJSONContent2 = "{\"status\":200,\"message\":\"success\",\"data\":{\"hxello2\":null, \"fxoo2\":\"bar\", \"zxero2\": 0}}"
        let DataJSON2 = DataJSONContent2.data(using: String.Encoding.utf8)!
        let dict2 = try? JSON(data: DataJSON2)
        XCTAssertTrue(NetworkingHelpers.isValidResponse(dict2!, isArray: false))
        
        
        let DataJSONContent3 = "{\"status\":200,\"message\":\"success\"}"
        let DataJSON3 = DataJSONContent3.data(using: String.Encoding.utf8)!
        let dict3 = try? JSON(data: DataJSON3)
        XCTAssertFalse(NetworkingHelpers.isValidResponse(dict3!, isArray: false))
        
        //array
        let Array1DataJSONContent = "{\"status\":200,\"message\":\"success\",\"data\":[{\"hello\":null, \"foo\":\"bar\", \"zero\": 0},{\"hello\":null, \"foo\":\"bar\", \"zero\": 0}]}"
        let Array1DataJSON = Array1DataJSONContent.data(using: String.Encoding.utf8)!
        let array = try? JSON(data: Array1DataJSON)
        XCTAssertTrue(NetworkingHelpers.isValidResponse(array!, isArray: true))
        //Array无数据返回格式
        let Array2DataJSONContent = "{\"status\":200,\"message\":\"success\",\"data\":[]}" //返回对应的实例，count为0
        let Array2DataJSON = Array2DataJSONContent.data(using: String.Encoding.utf8)!
        let array2 = try? JSON(data: Array2DataJSON)
        XCTAssertTrue(NetworkingHelpers.isValidResponse(array2!, isArray: true))
        
        let Array3DataJSONContent = "{\"status\":200,\"message\":\"success\"}" //返回对应的实例，count为0
        let Array3DataJSON = Array3DataJSONContent.data(using: String.Encoding.utf8)!
        let array3 = try? JSON(data: Array3DataJSON)
        XCTAssertFalse(NetworkingHelpers.isValidResponse(array3!, isArray: true))
    }
    
    func testRxModelSignalHadNullData() {
        let expectation = self.expectation(description: "model is nil")
        
        let DataJSONContent = "{\"status\":200,\"message\":\"success\",\"data\":{}}"
        let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
        stub(condition: isHost("wwx.xxcocco.com")) { _ in
            return OHHTTPStubsResponse(data: DataJSON, statusCode:200, headers:nil)
        }
        
        NetworkingHelpers.modelSignal(t: Hi.self, url: "http://wwx.xxcocco.com").subscribe(onNext:{ result in
            expectation.fulfill()
            XCTAssert(result == nil)
        },onError:{ reuslt in
            print(reuslt)
        })
        
        waitForExpectations(timeout: 10) { error in
            print("\(String(describing: error))")
        }
    }
    
    
    func testRxModelSignalHadDataNoProperty() {
        let expectation = self.expectation(description: "model is nil")
        
        //let DataJSONContent = "{\"status\":200,\"message\":\"success\",\"data\":{}}"
        let DataJSONContent = "{\"status\":200,\"message\":\"success\",\"data\":{\"hxello2\":null, \"fxoo2\":\"bar\", \"zxero2\": 0}}"
        let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
        stub(condition: isHost("wwx.xxcocco.com")) { _ in
            return OHHTTPStubsResponse(data: DataJSON, statusCode:200, headers:nil)
        }
        
        NetworkingHelpers.modelSignal(t: Hi.self, url: "http://wwx.xxcocco.com").subscribe(onNext:{ result in
            expectation.fulfill()
            XCTAssert(result == nil)
        },onError:{ reuslt in
            print(reuslt)
        })
        
        waitForExpectations(timeout: 10) { error in
            print("\(String(describing: error))")
        }
    }
    
    
    func testRxModelSignalHadModel() {
        let expectation = self.expectation(description: "model is not nil")
        
        let DataJSONContent = "{\"status\":200,\"message\":\"success\",\"data\":{\"hello\":null, \"foo\":\"bar\", \"zero\": 0}}"
        let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
        stub(condition: isHost("wwx.xxcocco.com")) { _ in
            return OHHTTPStubsResponse(data: DataJSON, statusCode:200, headers:nil)
        }
        
        NetworkingHelpers.modelSignal(t: Hi.self, url: "http://wwx.xxcocco.com").subscribe(onNext:{ result in
            expectation.fulfill()
            XCTAssert(result != nil)
            XCTAssertEqual(result!.foo, "bar")
        },onError:{ reuslt in
            print(reuslt)
        })
        
        waitForExpectations(timeout: 10) { error in
            print("\(String(describing: error))")
        }
    }
    
    func testRxArraySignalHadEmptyData() {
        let expectation = self.expectation(description: "array count 0")
        
        let DataJSONContent = "{\"status\":200,\"message\":\"success\",\"data\":[]}"
        let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
        stub(condition: isHost("wwx.xxcocco.com")) { _ in
            return OHHTTPStubsResponse(data: DataJSON, statusCode:200, headers:nil)
        }
        
        NetworkingHelpers.arrayModelSignal(t: Hi.self, url: "http://wwx.xxcocco.com").subscribe(onNext:{ result in
            expectation.fulfill()
            XCTAssertTrue(result.count == 0)
        },onError:{ reuslt in
            print(reuslt)
        })
        
        waitForExpectations(timeout: 10) { error in
            print("\(String(describing: error))")
        }
    }
    
    func testRxArraySignalHadData() {
        let expectation = self.expectation(description: "array has datas")
        
        let DataJSONContent = "{\"status\":200,\"message\":\"success\",\"data\":[{\"hello\":null, \"foo\":\"bar\", \"zero\": 0},{\"hello\":null, \"foo\":\"bar\", \"zero\": 0}]}"
        let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
        stub(condition: isHost("wwx.xxcocco.com")) { _ in
            return OHHTTPStubsResponse(data: DataJSON, statusCode:200, headers:nil)
        }
        
        NetworkingHelpers.arrayModelSignal(t: Hi.self, url: "http://wwx.xxcocco.com").subscribe(onNext:{ result in
            expectation.fulfill()
            XCTAssertTrue(result.count == 2)
        },onError:{ reuslt in
            print(reuslt)
        })
        
        waitForExpectations(timeout: 10) { error in
            print("\(String(describing: error))")
        }
    }
    
    func testRxArraySignalHadNoProperyData() {
        let expectation = self.expectation(description: "array count 0")
        
        let DataJSONContent = "{\"status\":200,\"message\":\"success\",\"data\":[{\"h2ello\":null, \"f2oo\":\"b2ar\", \"z2ero\": 0},{\"h2ello\":null, \"f2oo\":\"b2ar\", \"z2ero\": 0}]}"
        let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
        stub(condition: isHost("wwx.xxcocco.com")) { _ in
            return OHHTTPStubsResponse(data: DataJSON, statusCode:200, headers:nil)
        }
        
        NetworkingHelpers.arrayModelSignal(t: Hi.self, url: "http://wwx.xxcocco.com").subscribe(onNext:{ result in
            expectation.fulfill()
            XCTAssertTrue(result.count == 0)
        },onError:{ reuslt in
            print(reuslt)
        })
        
        waitForExpectations(timeout: 10) { error in
            print("\(String(describing: error))")
        }
        
    }
}
