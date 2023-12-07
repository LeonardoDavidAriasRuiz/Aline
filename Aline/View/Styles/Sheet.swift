//
//  Sheet.swift
//  Aline
//
//  Created by Leonardo on 07/08/23.
//

import SwiftUI

struct Sheet<Content: View>: View {
    private var title: String?
    @Binding var isLoading: Bool
    private let content: () -> Content
    
    init(section: MenuSubsection = .none, isLoading: Binding<Bool> = .constant(false), @ViewBuilder content: @escaping () -> Content) {
        self.title = section == .none ? nil : section.title
        self._isLoading = isLoading
        self.content = content
    }
    
    var body: some View {
        NavigationStack {
            Loading($isLoading) {
                ScrollView {
                    VStack {
                        if let title = title {
                            content().navigationTitle(title)
                        } else {
                            content()
                        }
                    }
                    .frame(maxWidth: 800)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.background)
            }
        }
    }
}

struct FullSheet<Content: View>: View {
    private let title: String?
    @Binding var isLoading: Bool
    private let content: () -> Content
    
    init(section: MenuSubsection = .none, isLoading: Binding<Bool> = .constant(false), @ViewBuilder content: @escaping () -> Content) {
        self.title = section == .none ? nil : section.title
        self._isLoading = isLoading
        self.content = content
    }
    
    var body: some View {
        NavigationStack {
            Loading($isLoading) {
                ScrollView {
                    VStack {
                        if let title = title {
                            content().navigationTitle(title)
                        } else {
                            content()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.background)
            }
        }
    }
}

struct FullSheetNoScroll<Content: View>: View {
    private let title: String?
    @Binding var isLoading: Bool
    private let content: () -> Content
    
    init(section: MenuSubsection = .none, isLoading: Binding<Bool> = .constant(false), @ViewBuilder content: @escaping () -> Content) {
        self.title = section == .none ? nil : section.title
        self._isLoading = isLoading
        self.content = content
    }
    
    var body: some View {
        NavigationStack {
            Loading($isLoading) {
                VStack {
                    VStack {
                        if let title = title {
                            content().navigationTitle(title)
                        } else {
                            content()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.background)
            }
        }
    }
}
