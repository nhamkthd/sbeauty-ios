//
//  Treatments.swift
//  Sbeauty
//
//  Created by Aries on 11/14/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import Foundation

struct TreatmentsData: Codable {
    var data:Treatments;
    var message:String?
}

struct Treatments: Codable {
    var current_page:Int?
    var data:[Treatment] = []
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


struct Treatment: Codable {
    var id:Int;
    var customer_id:Int;
    var services:[TreatmentService];
    var deleted_at:String?
    var created_at:String?
    var updated_at:String?
    var main_service_id:Int;
    var status:Int;
    var customer:TreatmentCustomer?;
    var commisions:[Commission?];
}


struct TreatmentService: Codable {
    var service_id: Int;
    var service_name:String;
    var service_type:Int;
    var employee_id:String?;
    var employee_name:String?;
    var bonus:Double?
    
    enum CodingKeys:String, CodingKey {
        case service_id = "service_id"
        case service_name = "service_name"
        case service_type = "service_type"
        case employee_id = "employee_id"
        case employee_name = "employee_name"
        case bonus = "bonus"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        service_id = try values.decodeIfPresent(Int.self, forKey: .service_id)!;
        service_name = try values.decodeIfPresent(String.self, forKey: .service_name)!;
        service_type = try values.decodeIfPresent(Int.self, forKey: .service_type)!;
        employee_id = try values.decodeIfPresent(String.self, forKey: .employee_id);
        employee_name = try values.decodeIfPresent(String.self, forKey: .employee_name);
        if let bonusDb = try? values.decodeIfPresent(Double.self, forKey: .bonus) {
            bonus = bonusDb;
        } else if let bonusStr = try? values.decodeIfPresent(String.self, forKey: .bonus) {
            bonus = Double(bonusStr);
        } else {
            bonus = 0.0;
        }
        
    }
}

struct TreatmentCustomer: Codable {
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
}

struct Commission: Codable {
    var id:Int;
    var employee_id:Int?;
    var service_id:Int?;
    var treatment_activity_id: Int?;
    var percentage:String;
    var status:Int;
    var created_at:String;
    var updated_at:String?;
    var deleted_at:String?;
    var employee:Employee;
    var service:Service;
}

struct Employee: Codable {
    var id:Int;
    var name:String;
    var phone: String;
    var email:String;
    var created_at:String;
    var updated_at:String?;
    var deleted_at:String?;
    var avatar:String?;
    
}
struct Service: Codable {
    var id: Int;
    var name: String;
    var parent_id: Int;
    var type: Int;
    var order_display: Int;
    var description: String?
    var deleted_at: String?
    var created_at: String;
    var updated_at: String?
    var status: Int;
    var quantity_default: Int;
    var discount_default: String;
    var commission_default: String;
    
}
