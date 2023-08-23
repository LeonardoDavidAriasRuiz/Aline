//
//  SignInView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 30/03/23.
//

import SwiftUI
import LocalAuthentication
import CloudKit

struct SignInView: View {
    
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var alert = false
    @State private var authButtonIcon: String = "faceid"
    @State private var authButtonColor: Color = Color.blue
    @State private var authButtonCornerRadius: CGFloat = 25
    @State private var timerCount = 0
    
    var body: some View {
        VStack {
            Button(action: authenticateUser, label: {
                Image(systemName: authButtonIcon)
                    .foregroundStyle(Color.white)
                    .font(.system(size: 80))
                    .frame(width: 150, height: 150)
                    .background(authButtonColor)
                    .clipShape(RoundedRectangle(cornerRadius: authButtonCornerRadius))
                    .contentTransition(.symbolEffect(.replace))
            })
            .onReceive(timer) { second in
                withAnimation(.easeIn(duration: 0.4)) {
                    timerCount += 1
                    authButtonIcon = timerCount % 2 == 0 ? "faceid" : "touchid"
                    authButtonColor = timerCount % 2 == 0 ? Color.blue : Color.green
                    authButtonCornerRadius = timerCount % 2 == 0 ? 25 : 75
                }
            }
        }
        .onAppear(perform: authenticateUser)
        .alertInfo(.signingInError, showed: $alert)
    }
    
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Identifícate para acceder a tu cuenta."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { authenticated, error in
                DispatchQueue.main.async {
                    if authenticated {
                        self.userVM.loginStatus = .signedIn
                    } else {
                        self.alert = true
                    }
                }
            }
        } else {
            self.alert = true
        }
    }
    
}
