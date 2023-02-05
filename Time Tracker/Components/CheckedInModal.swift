//
//  CheckedInModalView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 4/2/2023.
//

import SwiftUI

struct CheckedInModal: View {
    var body: some View {
        ZStack {
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.pink, .purple]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .cornerRadius(20)
                        .shadow(radius: 20)
                    
                    VStack {
//                        Image("your-image")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 200, height: 200)
                        
                        Text("Card Title")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text("Some Description")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                    }
                    .padding()
                }
    }
}

//struct CheckedInModalView_Previews: PreviewProvider {
//    static var previews: some View {
//        CheckedInModalView()
//    }
//}
