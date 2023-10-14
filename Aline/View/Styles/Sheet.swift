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
    
    init(section: MenuSubsection, isLoading: Binding<Bool> , @ViewBuilder content: @escaping () -> Content) {
        self.title = section.title
        self._isLoading = isLoading
        self.content = content
    }
    
    init(section: MenuSubsection, @ViewBuilder content: @escaping () -> Content) {
        self.title = section.title
        self._isLoading = .constant(false)
        self.content = content
    }
    
    init(isLoading: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.title = nil
        self._isLoading = isLoading
        self.content = content
    }
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.title = nil
        self._isLoading = .constant(false)
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
    
    init(section: MenuSubsection, isLoading: Binding<Bool> , @ViewBuilder content: @escaping () -> Content) {
        self.title = section.title
        self._isLoading = isLoading
        self.content = content
    }
    
    init(isLoading: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) {
        self.title = nil
        self._isLoading = isLoading
        self.content = content
    }
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.title = nil
        self._isLoading = .constant(false)
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
