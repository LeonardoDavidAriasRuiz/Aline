//
//  TipsReviewView.swift
//  Aline
//
//  Created by Leonardo on 22/09/23.
//

import SwiftUI

struct TipsReviewView: View {
    @EnvironmentObject private var employeeVM: EmployeeViewModel
    @EnvironmentObject private var alertVM: AlertViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var employees: [Employee] = []
    @State private var employeesWithTips: [(employee: Employee, tip: Tip?)] = []
    @State private var isLoading: Bool = false
    
    @Binding var tipsReviews: [TipsReview]
    
    private let tipVM = TipViewModel()
    private let tipReviewVM = TipsReviewViewModel()
    let tipsReview: TipsReview
    
    init(_ tipsReview: TipsReview, tipsReviews: Binding<[TipsReview]>) {
        self.tipsReview = tipsReview
        self._tipsReviews = tipsReviews
    }
    
    var body: some View {
        Sheet(section: .tipsReview, isLoading: $isLoading) {
            infoArea
            employeesList
            SaveButtonWhite(action: saveTips)
            DeclineButtonWhite(action: declineTips)
        }
        .onAppear(perform: getEmployees)
    }
    
    private var infoArea: some View {
        WhiteArea(spacing: 8) {
            HStack {
                Text(tipsReview.from.shortDate)
                Spacer()
                Text("\(tipsReview.from.hour) - \(tipsReview.to.hour)")
                    .foregroundStyle(.secondary)
            }
            Divider()
            HStack {
                Text("Total:")
                Spacer()
                Text(getTotal().comasTextWithDecimals)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var employeesList: some View {
        WhiteArea(spacing: 8) {
            ForEach(employeesWithTips, id: \.employee) { employeeWithTip in
                if employeeWithTip != employeesWithTips.last ?? employeeWithTip {
                    Divider()
                }
                HStack {
                    Text(employeeWithTip.employee.fullName)
                        .foregroundStyle(employeeWithTip.employee.isActive ? .primary : Color.red)
                    Text(employeeWithTip.employee.isActive ? "" : " Empleado inactivo")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(tipsReview.quantityForEach.comasTextWithDecimals)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
    
    private func saveTips() {
        isLoading = true
        for index in employeesWithTips.indices {
            var tip = employeesWithTips[index].tip ?? Tip(employee: employeesWithTips[index].employee, date: tipsReview.from)
            tip.quantity += tipsReview.quantityForEach
            tipVM.save(tip.record) {} ifNot: {
                alertVM.show(.crearingError)
            } alwaysDo: {
                if employeesWithTips[index] == employeesWithTips.last! {
                    declineTips()
                }
            }
        }
    }
    
    private func declineTips() {
        tipReviewVM.delete(tipsReview.record) {
            DispatchQueue.main.async { dismiss() }
        } ifNot: {
            self.alertVM.show(.decliningError)
        }
    }
    
    private func getTotal() -> Double {
        tipsReview.quantityForEach * Double(tipsReview.employeesIds.count)
    }
    
    private func getEmployees() {
        isLoading = true
        
        employeesWithTips = []
        employeesWithTips = employeeVM.employees.compactMap({ employee in
            tipsReview.employeesIds.contains(employee.id) ? (employee, nil) : nil
        })
        
        for index in employeesWithTips.indices {
            tipVM.fetchTip(for: employeesWithTips[index].employee, date: tipsReview.from) { tip in
                print(employeesWithTips[index].employee.fullName)
                employeesWithTips[index] = (employeesWithTips[index].employee, tip)
                print(employeesWithTips[index].employee.fullName)
                if employeesWithTips[index] == employeesWithTips.last! {
                    isLoading = false
                }
            }
        }
    }
}
