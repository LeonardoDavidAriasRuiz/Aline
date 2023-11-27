//
//  WorksheetViewModel.swift
//  Aline
//
//  Created by Leonardo on 16/10/23.
//

import Foundation
import CloudKit

class WorksheetViewModel: PublicCloud {
    private let keys: WorksheetKeys = WorksheetKeys()
    
    func fetch(for restaurantId: String, completion: @escaping ([Worksheet]?) -> Void) {
        let predicate = NSPredicate(format: "\(keys.restaurantId) == %@", restaurantId)
        let query = CKQuery(recordType: keys.type, predicate: predicate)
        dataBase.fetch(withQuery: query) { result in
            guard case .success(let data) = result else { completion(.none); return }
            let worksheets: [Worksheet] = data.matchResults.compactMap { _, result in
                guard case .success(let record) = result else {completion(.none); return nil }
                return Worksheet(record: record)
            }
            completion(worksheets)
        }
    }
}
