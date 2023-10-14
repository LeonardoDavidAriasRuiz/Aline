//
//  TipsReviewView.swift
//  Aline
//
//  Created by Leonardo on 22/09/23.
//

import SwiftUI

struct TipsReviewView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var alertVM: AlertViewModel
    
    @State private var employees: [Employee] = []
    @State private var employeesWithTips: [(employee: Employee, tip: Tip?)] = []
    
    @Binding var tipsReviews: [TipsReview]
    let tipsReview: TipsReview
    
    @State private var isLoading: Bool = false
    
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
                Text("\(tipsReview.from.time) - \(tipsReview.to.time)")
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
            ForEach(employees) { employee in
                HStack {
                    Text(employee.fullName)
                        .foregroundStyle(employee.isActive ? .primary : Color.red)
                    Text(employee.isActive ? "" : " Empleado inactivo")
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(tipsReview.quantityForEach.comasTextWithDecimals)
                        .foregroundStyle(.secondary)
                }
                if employee != employees.last {
                    Divider()
                }
            }
        }
    }
    
    private func saveTips() {
        isLoading = true
        for index in employeesWithTips.indices {
            if var tip = employeesWithTips[index].tip {
                tip.quantity += tipsReview.quantityForEach
                TipViewModel().save(tip) { saved in
                    if !saved {
                        alertVM.show(.crearingError)
                    }
                    if employeesWithTips[index] == employeesWithTips.last! {
                        isLoading = false
                        declineTips()
                    }
                }
            } else {
                var tip = Tip()
                tip.date = tipsReview.from
                tip.employeeId = employeesWithTips[index].employee.id
                tip.quantity = tipsReview.quantityForEach
                TipViewModel().save(tip) { saved in
                    if !saved {
                        alertVM.show(.crearingError)
                    }
                    if employeesWithTips[index] == employeesWithTips.last! {
                        isLoading = false
                        declineTips()
                    }
                }
            }
        }
    }
    
    private func declineTips() {
        TipsReviewViewModel().delete(tipsReview) { deleted in
            if deleted {
                DispatchQueue.main.async {
                    withAnimation {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }
            } else {
                self.alertVM.show(.decliningError)
            }
        }
    }
    
    private func getTotal() -> Double {
        let employeesNumber = Double(tipsReview.employeesIds.count)
        return tipsReview.quantityForEach * employeesNumber
    }
    
    private func getEmployees() {
        isLoading = true
        EmployeeViewModel().fetch(employeesIds: tipsReview.employeesIds) { employees in
            if let employees = employees {
                self.employees = employees
                employeesWithTips = employees.map({($0, nil)})
            } else {
                alertVM.show(.dataObtainingError)
            }
            for index in employeesWithTips.indices {
                TipViewModel().fetchTip(for: employeesWithTips[index].employee, date: tipsReview.from) { tip in
                    employeesWithTips[index] = (employeesWithTips[index].employee, tip)
                    if employeesWithTips[index] == employeesWithTips.last! {
                        isLoading = false
                    }
                }
            }
        }
    }
}
