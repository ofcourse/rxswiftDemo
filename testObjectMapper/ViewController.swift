//
//  ViewController.swift
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

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

   
    @IBAction func testTokenLost(_ sender: Any) {
        let DataJSONContent = "{\"status\":304,\"message\":\"success\",\"data\":[{\"h2ello\":null, \"f2oo\":\"b2ar\", \"z2ero\": 0},{\"h2ello\":null, \"f2oo\":\"b2ar\", \"z2ero\": 0}]}"
        let DataJSON = DataJSONContent.data(using: String.Encoding.utf8)!
        stub(condition: isHost("wwx.xxcocco.com")) { _ in
            return OHHTTPStubsResponse(data: DataJSON, statusCode:200, headers:nil)
        }
        
        NetworkingHelpers.arrayModelSignal(t: Hi.self, url: "http://wwx.xxcocco.com").subscribe(onNext:{ result in
             print(result)
        },onError:{ result in
            print(result)
        })
        
    }
}

