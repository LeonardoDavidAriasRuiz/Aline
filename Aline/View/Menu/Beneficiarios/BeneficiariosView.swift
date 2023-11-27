//
//  Beneficiarios.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI
import WebKit
import UIKit

struct BeneficiariosView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var beneficiaries: [Beneficiary] = []
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet(isLoading: $isLoading) {
            WhiteArea {
                
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                NewRecordToolbarButton(destination: NewBeneficiaryView())
            }
        }
        .overlay { if beneficiaries.isEmpty, !isLoading { EmptyBeneficiariesView() } }
    }
}
