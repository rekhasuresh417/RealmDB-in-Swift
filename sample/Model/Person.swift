//
//  Person.swift
//  sample
//
//  Created by PQC India iMac-2 on 30/06/23.
//

import RealmSwift

class PersonDetails: Object{
    @objc dynamic var avatar: Data?
    @objc dynamic var firstName: String?
    @objc dynamic var lastName: String?
    @objc dynamic var email: String?
    @objc dynamic var userId: String?
}

