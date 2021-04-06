//
//  MainView.swift
//  proj4
//
//  Created by Joseph Ham on 4/5/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {

            ContentView()
                .tabItem{ Label("SOS", systemImage:"heart.circle")}
            ContactViewMain()
                .tabItem{ Label("Contacts", systemImage:"list.dash")}
            OptionsMenu()
                .tabItem { Label("Options", systemImage:"gear")
                }
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
