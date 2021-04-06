//
//  Contacts.swift
//  proj4
//
//  Created by Joseph Ham on 4/5/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import SwiftUI
import MessageUI
import mailgun
import CoreData


/// Contacts View
struct ContactViewMain: View {

    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Contact_.allContactsFetchRequest()) var contactList: FetchedResults<Contact_>

    @State private var text = ""

    var body: some View {
        NavigationView {
            List{
            Section(header: Text("Contacts")) {
                ForEach(self.contactList) { con in
                     NavigationLink(destination: EditView(contact: con)) {
                         VStack(alignment: .leading) {
                            Text(con.email ?? "")
                                 .font(.headline)
                         }
                     }
                 }
                 .onDelete { (indexSet) in // Delete gets triggered by swiping left on a row
                     // ❇️ Gets the BlogIdea instance out of the blogIdeas array
                     // ❇️ and deletes it using the @Environment's managedObjectContext
                     let toDelete = self.contactList[indexSet.first!]
                     self.managedObjectContext.delete(toDelete)
                     
                     do {
                         try self.managedObjectContext.save()
                     } catch {
                         print(error)
                     }
                 }
             }
             .font(.headline)
        }
         .listStyle(GroupedListStyle())
         .navigationBarTitle(Text("Contact List"))
         .navigationBarItems(trailing: EditButton())
        }

    }

}

struct ContactViewMain_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContactViewMain()
        }
    }
}







