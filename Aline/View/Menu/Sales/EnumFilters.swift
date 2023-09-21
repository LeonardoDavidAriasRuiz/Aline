//
//  EnumFilters.swift
//  Aline
//
//  Created by Leonardo on 11/09/23.
//

import Foundation

enum TotalBy: String {
    case day = "Día"
    case week = "Semana"
    case month = "Mes"
}

enum RangeIn: String {
    case currentWeek = "Semana actual"
    case currentMonth = "Mes actual"
    case currentYear = "Año actual"
    case customRange = "Personalizado"
}
