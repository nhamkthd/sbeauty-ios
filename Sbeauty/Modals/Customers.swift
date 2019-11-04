//
//  Customers.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/10/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import Foundation
import UIKit;

//customers list
struct GetListCutomersData: Codable {
    var data:Customers?
    var message:String?
}
struct Customers:Codable {
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
    var avatar:String?
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

//customer photos
struct PhotoData: Codable {
    var data:Photos?
    var message:String?
}

struct UploadPhotoResponse: Codable {
    var data:String?
    var message:String?
}

struct Photos: Codable {
    var current_page:Int?
    var data:[Photo] = []
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

struct Photo: Codable{
    var id:Int!;
    var customer_id: Int?;
    var image:String!;
    var created_at:String?;
    var updated_at:String?;
    var deleted_at:String?;
}

// customer detail
struct CustomerDetailData: Codable {
    var data:customerDetail?
    var message:String?
}

struct customerDetail: Codable {
    var id:Int
    var code:String
    var photo:String?
    var name:String?
    var gender:Int?
    var birthday:String?
    var address:String?
    var job:String?
    var phone:String?
    var deleted_at:String?
    var created_at:String
    var updated_at:String?
    var avatar:String?
    var treatment_count:Int
    var detail_service_avaiables:[Services?]
    var profiles:[Profile?]
    var payment:Wellet?

}


struct Services: Codable {
    var quantity:Int;
    var use_quantity:Int;
    var commodity_id:Int;
    var name:String;
}

struct Profile: Codable{
    var id:Int;
    var customer_id:Int;
    var status:String?
    var history:String?
    var request:String?
    var skin_type:String?
    var created_at:String;
    var updated_at:String?
    var deleted_at:String?
}

struct Wellet: Codable {
    var id:Int;
    var customer_id:Int;
    var balance:String;
    var balance_type:String?;
    var deleted_at:String?;
    var created_at:String;
    var updated_at:String?
}
