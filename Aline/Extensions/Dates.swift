//
//  Dates.swift
//  Aline
//
//  Created by Leonardo on 11/09/23.
//

import Foundation

extension [Sale] {
    var groupByWeek: [Sale] {
        return groupBy { sale in
            let calendar = Calendar.current
            let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: sale.date)
            return "\(components.yearForWeekOfYear!)-\(components.weekOfYear!)"
        }
    }
    
    var groupByMonth: [Sale] {
        return groupBy { sale in
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: sale.date)
            return "\(components.year!)-\(components.month!)"
        }
    }
    
    private func groupBy(keySelector: (Sale) -> String) -> [Sale] {
        var grouped: [String: Sale] = [:]
        
        for sale in self {
            let key = keySelector(sale)
            
            if var existingSale = grouped[key] {
                existingSale.rtonos += sale.rtonos
                existingSale.vequipo += sale.vequipo
                existingSale.carmenTRJTA += sale.carmenTRJTA
                existingSale.depo += sale.depo
                existingSale.dscan += sale.dscan
                existingSale.doordash += sale.doordash
                existingSale.online += sale.online
                existingSale.grubhub += sale.grubhub
                existingSale.tacobar += sale.tacobar
                grouped[key] = existingSale
            } else {
                grouped[key] = sale
            }
        }
        
        return Array(grouped.values)
    }
}
