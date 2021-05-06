//
//  Disclaimer.swift
//  proj4
//
//  Created by Joseph Ham on 5/6/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import SwiftUI

struct Disclaimer: View {
    var body: some View {
        VStack{
            Text("[Legal Disclaimer Here]\n\n©2021 The Smart Apples and Alcor, \nAll Rights Reserved.")
                .font(.title2)
            .multilineTextAlignment(.center)

        }
    }
}

struct Disclaimer_Previews: PreviewProvider {
    static var previews: some View {
        Disclaimer()
    }
}
