//
//  Contact.swift
//  proj4
//
//  Created by Sam Spohn on 10/29/20.
//  Copyright © 2020 Sam Spohn. All rights reserved.
//

import Foundation
import CoreData



// ❇️ BlogIdea code generation is turned OFF in the xcdatamodeld file
public class Contact_: NSManagedObject, Identifiable {
    @NSManaged public var email: String?
}

extension Contact_ {
    // ❇️ The @FetchRequest property wrapper in the ContentView will call this function
    static func allContactsFetchRequest() -> NSFetchRequest<Contact_> {
        let request: NSFetchRequest<Contact_> = Contact_.fetchRequest() as! NSFetchRequest<Contact_>
        
        // ❇️ The @FetchRequest property wrapper in the ContentView requires a sort descriptor
        request.sortDescriptors = [NSSortDescriptor(key: "email", ascending: true)]
          
        return request
    }
}
