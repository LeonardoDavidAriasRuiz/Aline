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
    @EnvironmentObject private var alertVM: AlertViewModel
    
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var authButtonIcon: String = "faceid"
    @State private var authButtonColor: Color = Color.blue
    @State private var authButtonCornerRadius: CGFloat = 25
    @State private var timerCount = 0
    
    @Binding var signedIn: Bool
    
    var body: some View {
        VStack {
            Button(action: authenticateUser) {
                Image(systemName: authButtonIcon)
                    .foregroundStyle(Color.white)
                    .font(.system(size: 80))
                    .frame(width: 150, height: 150)
                    .background(authButtonColor)
                    .clipShape(RoundedRectangle(cornerRadius: authButtonCornerRadius))
                    .contentTransition(.symbolEffect(.replace))
            }
            .onReceive(timer) { time in
                withAnimation(.easeIn(duration: 0.4)) {
                    if time.seconds % 2 == 0 {
                        authButtonIcon = "faceid"
                        authButtonColor = Color.blue
                        authButtonCornerRadius = 25
                    } else {
                        authButtonIcon = "touchid"
                        authButtonColor = Color.green
                        authButtonCornerRadius = 75
                    }
                }
            }
        }
        .onAppear(perform: authenticateUser)
    }
    
    private func authenticateUser() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Identifícate para acceder a tu cuenta."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { authenticated, _ in
                DispatchQueue.main.async {
                    if authenticated {
                        signedIn = true
                    } else {
                        alertVM.show(.signingInError)
                    }
                }
            }
        } else {
            alertVM.show(.signingInError)
        }
    }
    
}
