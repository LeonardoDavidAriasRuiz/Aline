//
//  WorksheetSettingsViewModel.swift
//  Aline
//
//  Created by Leonardo on 15/10/23.
//

import Foundation
import CloudKit

class WorksheetSettingsViewModel: PublicCloud {
    private let keys: WorksheetSettingsKeys = WorksheetSettingsKeys()
    
    func fetch(for restaurantId: String, completion: @escaping ([WorksheetSettings]?) -> Void) {
        let predicate = NSPredicate(format: "\(keys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: keys.type, predicate: predicate)
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            let spendingType: [WorksheetSettings] = data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else {completion(.none); return nil }
                return WorksheetSettings(record: record)
            }
            completion(spendingType)
        }
    }
}
