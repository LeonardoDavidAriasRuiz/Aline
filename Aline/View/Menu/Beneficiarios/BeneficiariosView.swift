//
//  Beneficiarios.swift
//  Aline
//
//  Created by Leonardo David Arias Ruiz on 29/03/23.
//

import SwiftUI
import WebKit
import UIKit

struct BeneficiariosView: View {
    @EnvironmentObject private var restaurantM: RestaurantPickerManager
    @EnvironmentObject private var alertVM: AlertViewModel
    @EnvironmentObject private var userVM: UserViewModel
    
    @State private var beneficiaries: [Beneficiary] = []
    @State private var isLoading: Bool = false
    
    var body: some View {
        Sheet(isLoading: $isLoading) {
            WhiteArea {
//                PDFCreator(pdfData: $pdfData)
                
                Divider()

                

            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                NewRecordToolbarButton(destination: NewBeneficiaryView())
            }
        }
        .overlay {
            if beneficiaries.isEmpty, !isLoading {
                ContentUnavailableView(label: {
                    Label(
                        title: { Text("Sin beneficiarios") },
                        icon: { Image(systemName: "person.line.dotted.person.fill").foregroundStyle(Color.green) }
                    )
                }, description: {
                    Text("Los nuevos beneficiarios se mostrarán aquí.")
                })
            }
        }
    }
}

let htmlString = """
    <!DOCTYPE html>
    <html>
        <head>
            <meta charset="UTF-8">
                <style>
                    @media (prefers-color-scheme: light) {
                        body {
                            background-color: #ffffff;
                            color: #333333;
                        }
                    }
                    @media (prefers-color-scheme: dark) {
                        body {
                            background-color: #333333;
                            color: #ffffff;
                        }
                    }
                    .container {
                        width: 80%;
                        margin: 0 auto;
                        padding: 20px;
                    }
                    .header {
                        text-align: center;
                        padding: 10px;
                        background-color: #ADD15F;
                        color: #ffffff;
                        border-radius: 100px;
                    }
                    .content {
                        padding: 30px;
                        text-align: center;
                    }
                    .footer {
                        text-align: center;
                        padding: 10px;
                        background-color: #EB785F;
                        color: #ffffff;
                        border-radius: 100px;
                    }
                    .verification-code {
                        color: #79BC9F;
                    }
                </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h1>Bienvenido a Aline</h1>
                </div>
                <div class="content">
                    <p>¡Estás invitado a </p>
                    <p>Tu nivel de usuario sería:</p>
                    <h2 class="verification-code"><strong></strong></h2>
                    <p>Por favor, acepta la invitación en la sección Cuenta.</p>
                </div>
                <div class="footer">
                    <p>Gracias por elegir Aline.</p>
                </div>
            </div>
        </body>
    </html>
    """


func convertHTMLStringToPDFData(htmlString: String, completion: @escaping (Data?) -> Void) {
    // Crea un formato de renderer con el tamaño de página que desees
    let format = UIGraphicsPDFRendererFormat()
    
    // Crea un renderer de PDF
    let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
    let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
    
    // Renderiza el HTML en PDF
    let pdfData = renderer.pdfData { context in
        context.beginPage()
        let attributes: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSAttributedString(data: Data(htmlString.utf8), options: attributes, documentAttributes: nil) {
            attributedString.draw(in: pageRect)
        }
    }
    
    completion(pdfData)
}

class WebViewNavigationDelegate: NSObject, WKNavigationDelegate {
    var didFinishLoading: (() -> Void)?

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinishLoading?()
    }
}

struct PDFCreator: UIViewRepresentable {
    @Binding var pdfData: Data

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: uiView.bounds)
        self.pdfData = pdfRenderer.pdfData { context in
            context.beginPage()
            uiView.layer.render(in: context.cgContext)
        }
    }
}
