//
//  Bid.swift
//  AuctionApp
//

import UIKit
import Parse

class Bid: PFObject, PFSubclassing {
    
    @NSManaged var email: String
    @NSManaged var name: String
    @NSManaged var telephone: String
    
    var maxBid: Int {
        get {
            return self["maxBid"] as! Int
        }
        set {
            self["maxBid"] = newValue
        }
    }
    
    var itemId: String {
        get {
            return self["item"] as! String
        }
        set {
            self["item"] = newValue
        }
    }

    var winner: Bool {
        get {
            return (self["winner"] as? Bool)!
        }
    }

    //Needed
    override init(){
        super.init()
    }
    
    init(email: String, name: String, telephone: String, maxBid: Int, itemId: String) {
        super.init()
        self.email = email
        self.name = name
        self.telephone = telephone
        self.maxBid = maxBid
        self.itemId = itemId
    }
    
    class func parseClassName() -> String {
        return "NewBid"
    }
}

enum BidType {
    case extra(Int)
    case custom(Int)
}
