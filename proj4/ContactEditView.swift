//
//  ContactEditView.swift
//  proj4
//
//  Created by Sam Spohn on 11/2/20.
//  Copyright © 2020 Sam Spohn. All rights reserved.
//

import Foundation
import SwiftUI

struct EditView: View {
    // ❇️ Core Data property wrappers
    @Environment(\.managedObjectContext) var managedObjectContext
    
    // ℹ️ This is used to "go back" when 'Save' is tapped
    @Environment(\.presentationMode) var presentationMode

    var contact: Contact_
    
    // ℹ️ Temporary in-memory storage for updating the title and description values of a Blog Idea
    @State var updatedContact: String = ""
    
    var body: some View {
        VStack {
            VStack {
                TextField("Contact:", text: $updatedContact)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onAppear {
                        // ℹ️ Set the text field's initial value when it appears
                        self.updatedContact = self.contact.email ?? ""
                }
        
            }
            
            VStack {
                Button(action: ({
                    // ❇️ Set the blog idea's new values from the TextField's Binding and save
                    self.contact.email = self.updatedContact
                    
                    do {
                        try self.managedObjectContext.save()
                    } catch {
                        print(error)
                    }
                    
                    self.presentationMode.wrappedValue.dismiss()
                })) {
                    Text("Save")
                }
            .padding()
            }
        }
    }
}

