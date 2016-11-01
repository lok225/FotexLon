//
//  Store.swift
//  Min Løn
//
//  Created by Martin Lok on 29/10/2016.
//  Copyright © 2016 Martin Lok. All rights reserved.
//

import UIKit

class Store: NSObject {

    var id: Int!
    var code: String!
    var name: String?
    
    var hasOldLøn: Bool!
    
    var lonPeriodeStart: Int?
    
    var basisLon: Double?
    var aftenTillæg: Double?
    var lørdagTillæg: Double?
    var søndagTillæg: Double?
    
    var oldBasisLon: Double?
    var oldAftenTillæg: Double?
    var oldLørdagTillæg: Double?
    var oldSøndagTillæg: Double?
    
    var lønText: String?
    
    init(id: Int, code: String, hasOldLøn: Bool) {
        super.init()
        
        self.id = id
        self.code = code
        self.hasOldLøn = hasOldLøn
    }
    
    
}
