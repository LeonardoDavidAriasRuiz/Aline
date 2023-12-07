//
//  EmptySalesView.swift
//  Aline
//
//  Created by Leonardo on 21/10/23.
//

import SwiftUI

struct EmptySalesView: View {
    var body: some View {
        ContentUnavailableView {
            Label(
                title: { Text("Sin ventas") },
                icon: { Image(systemName: "chart.bar.xaxis").foregroundStyle(Color.green) }
            )
        }
    }
}

struct EmptyDepositsView: View {
    var body: some View {
        ContentUnavailableView {
            Label(
                title: { Text("Sin depositos") },
                icon: { Image(systemName: "tray.full.fill").foregroundStyle(Color.blue) }
            )
        }
    }
}

struct EmptyRestaurantsView: View {
    var body: some View {
        ContentUnavailableView {
            Label(
                title: { Text("Sin restaurantes") },
                icon: { Image(systemName: "building.2.fill").foregroundStyle(Color.green) }
            )
        }
    }
}

struct EmptyEmployeesView: View {
    var body: some View {
        ContentUnavailableView {
            Label(
                title: { Text("Sin empleados") },
                icon: { Image(systemName: "person.3.fill").foregroundStyle(Color.orange) }
            )
        }
    }
}

struct EmptyEmployeesCashOutView: View {
    var body: some View {
        ContentUnavailableView {
            Label(
                title: { Text("Sin empleados") },
                icon: { Image(systemName: "person.3.fill").foregroundStyle(Color.red) }
            )
        }
    }
}

struct EmptySpendingsView: View {
    var body: some View {
        ContentUnavailableView {
            Label(
                title: { Text("Sin gastos") },
                icon: { Image(systemName: "creditcard.fill").foregroundStyle(Color.red) }
            )
        }
    }
}

struct EmptyBeneficiariesView: View {
    var body: some View {
        ContentUnavailableView {
            Label(
                title: { Text("Sin beneficiarios") },
                icon: { Image(systemName: "person.line.dotted.person.fill").foregroundStyle(Color.green) }
            )
        }
    }
}

struct EmptyPayrollView: View {
    var body: some View {
        ContentUnavailableView {
            Label(
                title: { Text("Sin Worksheets") },
                icon: { Image(systemName: "doc.richtext.fill").foregroundStyle(Color.red) }
            )
        }
    }
}

struct EmptyPDFView: View {
    var body: some View {
        ContentUnavailableView {
            Label(
                title: { Text("No PDF") },
                icon: { Image("custom.doc.text.image.badge.exclamationmark").foregroundStyle(Color.red) }
            )
        }
    }
}

struct EmptyWorkSheetSettingsView: View {
    var body: some View {
        ContentUnavailableView {
            Label(
                title: { Text("Configura los datos primero") },
                icon: { Image("payroll.settings").foregroundStyle(Color.red) }
            )
        }
    }
}

struct EmptyTipsView: View {
    var body: some View {
        ContentUnavailableView {
            Label(
                title: { Text("Sin empleados") },
                icon: { Image(systemName: "person.3.fill").foregroundStyle(Color.orange) }
            )
        }
    }
}

struct EmptyEmployeesChecksView: View {
    var body: some View {
        ContentUnavailableView {
            Label(
                title: { Text("Sin empleados") },
                icon: { Image(systemName: "person.3.fill").foregroundStyle(Color.blue) }
            )
        }
    }
}
