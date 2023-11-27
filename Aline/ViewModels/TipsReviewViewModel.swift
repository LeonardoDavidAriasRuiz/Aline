//
//  TipsReviewViewModel.swift
//  Aline
//
//  Created by Leonardo on 21/09/23.
//

import CloudKit
import SwiftUI

class TipsReviewViewModel: PublicCloud {
    private let keys: TipReviewKeys = TipReviewKeys()
    
    func save(_ tip: TipsReview, completion: @escaping (Bool) -> Void) {
        dataBase.save(tip.record) { record, error in
            completion(record != nil)
        }
    }
    
    func fetchTips(for retaurantId: String, completion: @escaping ([TipsReview]?) -> Void) {
        let predicate = NSPredicate(format: "\(keys.restaurantId) == %@", retaurantId)
        let query = CKQuery(recordType: keys.type, predicate: predicate)
        
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            let tipsReviews: [TipsReview] = data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else {completion(.none); return nil }
                return TipsReview(record: record)
            }
            completion(tipsReviews)
        }
    }
    
    func delete(_ tip: TipsReview, completion: @escaping (Bool) -> Void) {
        dataBase.delete(withRecordID: tip.record.recordID) { (recordID, _) in
            completion(recordID != nil)
        }
    }
}
