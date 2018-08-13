//
//  testObjectMapperTests.swift
//  testObjectMapperTests
//
//  Created by macbook on 2018/3/31.
//  Copyright © 2018年 HSG. All rights reserved.
//

import XCTest
import ObjectMapper
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
    
    func testExample() {
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testJsonToUser() {
//        let JSON : [String: Any] = {"value": "1234"}
//        let mapper = Mapper<User>(JSON:JSON);
        let s = "ss"
        s.count
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

class User: Mappable {
    var value: Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        value <- map["value"]
    }
}
