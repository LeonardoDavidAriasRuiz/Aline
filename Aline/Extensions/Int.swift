//
//  Int.swift
//  Aline
//
//  Created by Leonardo on 11/09/23.
//

import Foundation

extension Int {
    var convertExcelDateToSwiftDate: Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
    
        // Fecha base de Excel (1 de enero de 1900)
        if let baseDate = dateFormatter.date(from: "1900/01/01") {
    
            // Configurar el calendario y los componentes de la fecha
            var dateComponents = DateComponents()
            dateComponents.day = self - 2 // Excel cuenta de manera diferente, por lo que ajustamos en -2 días
    
            // Calendario
            let calendar = Calendar.current
    
            // Calcular la nueva fecha
            if let newDate = calendar.date(byAdding: dateComponents, to: baseDate) {
                return newDate
            }
        }
        return nil
    }
}
