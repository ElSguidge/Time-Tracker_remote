//
//  UserDetailView.swift
//  Time Tracker
//
//  Created by Mark McKeon on 10/1/2023.
//

import SwiftUI

struct UserDetailView: View {
    
    var user: UserProfile
    
    var body: some View {
        Text(user.fullName)
    }
}
