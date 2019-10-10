//
//  Customers.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/10/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import Foundation


struct GetListCutomersData: Codable {
    var data:CustomerData?
    var message:String?
}
struct CustomerData:Codable {
    var current_page:Int?
    var data:[Customer] = []
    var first_page_url:String?
    var from:Int?
    var last_page:Int?
    var last_page_url:String?
    var next_page_url:String?
    var path:String?
    var per_page:Int?
    var prev_page_url:String?
    var to:Int?
    var total:Int?
}

struct Customer: Codable {
    var id:Int?
    var code:String?
    var photo:String?
    var name:String?
    var gender:Int?
    var birthday:String?
    var address:String?
    var job:String?
    var phone:String?
    var deleted_at:String?
    var created_at:String?
    var updated_at:String?
    var notes:[Note] = [];
}
struct Note: Codable{
    var id:Int?
    var note:String?
    var customer_id:Int?
    var deleted_at:String?
    var created_at:String?
    var updated_at:String?
    
}

struct Photo {
    var id:Int?
    var customer_id:Int?
    var imageUrlStr:String?
    
    init(id:Int?, customerId:Int?, imageUrl:String?) {
        self.id = id;
        self.customer_id = customerId;
        self.imageUrlStr = imageUrl;
    }
}
