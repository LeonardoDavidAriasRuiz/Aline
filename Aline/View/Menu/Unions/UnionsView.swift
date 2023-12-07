//
//  UnionsView.swift
//  Aline
//
//  Created by Leonardo on 30/11/23.
//

import SwiftUI
import Algorithms
import UniformTypeIdentifiers

struct UnionsView: View {
    @State private var unionsFirstMonth: [FortnightSection] = [
        FortnightSection(section: "Cheques", fortnight: 1, color: Color.blue),
        FortnightSection(section: "Cheques", fortnight: 2, color: Color.blue),
        FortnightSection(section: "Tips", fortnight: 1, color: Color.orange),
        FortnightSection(section: "Tips", fortnight: 2, color: Color.orange)
    ]
    @State private var unionsSeconfMonth: [FortnightSection] = [
        
    ]
    @State private var isLoading: Bool = false
    
    var body: some View {
        FullSheetNoScroll(isLoading: $isLoading) {
            VStack(spacing: 30) {
                HStack {
                    MonthUnion(fortnights: $unionsFirstMonth, title: "Mes 1")
                        .dropDestination(for: FortnightSection.self) { droppedFortnight, location in
                            withAnimation {
                                drop(droppedFortnights: droppedFortnight)
                                let fortnights = unionsFirstMonth + droppedFortnight
                                unionsFirstMonth = Array(fortnights.uniqued())
                                sorthSections()
                                return true
                            }
                        }
                    MonthUnion(fortnights: $unionsSeconfMonth, title: "Mes 2")
                        .dropDestination(for: FortnightSection.self) { droppedFortnight, location in
                            withAnimation {
                                drop(droppedFortnights: droppedFortnight)
                                let fortnights = unionsSeconfMonth + droppedFortnight
                                unionsSeconfMonth = Array(fortnights.uniqued())
                                sorthSections()
                                return true
                            }
                        }
                }
            }.foregroundStyle(.white)
        }
    }
    
    private func drop(droppedFortnights: [FortnightSection], location: CGPoint = CGPoint()) {
        for fortnight in droppedFortnights {
            unionsSeconfMonth.removeAll(where: {$0 == fortnight})
            unionsFirstMonth.removeAll(where: {$0 == fortnight})
        }
    }
    
    private func sorthSections() {
        unionsSeconfMonth.sort()
        unionsFirstMonth.sort()
    }
}

struct MonthUnion: View {
    @Binding var fortnights: [FortnightSection]
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
            HStack {
                ForEach(fortnights, id: \.self) { union in
                    Text("\(union.section): \(union.fortnight)")
                        .padding(10)
                        .frame(minWidth: 50, minHeight: 50)
                        .background(union.color)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .draggable(union)
                }
            }
            .frame(minWidth: 100, minHeight: 100)
            .padding(.horizontal, 10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.horizontal, 10)
        }
        .frame(minWidth: 200, minHeight: 200)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}

struct FortnightSection: Codable, Transferable, Hashable, Comparable, Equatable {
    var id: String = UUID().uuidString
    let section: String
    let fortnight: Int
    let color: Color
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .fortnightSection)
    }
    
    static func < (lhs: FortnightSection, rhs: FortnightSection) -> Bool {
        "\(lhs.section): \(lhs.fortnight)" < "\(rhs.section): \(rhs.fortnight)"
    }
    
    static func ==(lhs: FortnightSection, rhs: FortnightSection) -> Bool {
        lhs.id == rhs.id
    }
}

extension UTType {
    static let fortnightSection = UTType(exportedAs: "co.lIOException.fornightSection")
}

extension Color: Codable {
    private enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case alpha
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)

        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let components = UIColor(self).components
        try container.encode(components.red, forKey: .red)
        try container.encode(components.green, forKey: .green)
        try container.encode(components.blue, forKey: .blue)
        try container.encode(components.alpha, forKey: .alpha)
    }
}

extension UIColor {
    var components: (red: Double, green: Double, blue: Double, alpha: Double) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (Double(red), Double(green), Double(blue), Double(alpha))
    }
}

