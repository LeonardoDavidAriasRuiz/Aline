//
//  TipsView.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI
import MobileCoreServices

struct TipsView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    
    @State private var tipsReviews: [TipsReview] = []
    
    @State private var isLoading: Bool = false
    
    var body: some View {
        FullSheet(isLoading: $isLoading) {
            tipsReviews.isNotEmpty ? tipsReviewsList : nil
        }
        .onAppear(perform: onAppear)
    }
    
    private var tipsReviewsList: some View {
        VStack(alignment: .leading){
            Header("Tips para revisar")
            WhiteArea {
                ForEach(tipsReviews) { tipsReview in
                    NavigationLink(destination: TipsReviewView(tipsReviews: $tipsReviews, tipsReview: tipsReview)) {
                        HStack {
                            Text("\(tipsReview.from.shortDateTime) - \(tipsReview.to.time)")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }.padding(.vertical, 8)
                    }
                    if tipsReview != tipsReviews.last {
                        Divider()
                    }
                }
            }
        }.padding(.bottom, 30)
    }
    
    private func onAppear() {
        isLoading = true
        TipsReviewViewModel().fetchTips(for: restaurantM.currentId) { tipsReviews in
            if let tipsReviews = tipsReviews {
                self.tipsReviews = tipsReviews
            } else {
                alertVM.show(.dataObtainingError)
            }
            isLoading = false
        }
    }
}


