//
//  ExportSalesEmail.swift
//  Aline
//
//  Created by Leonardo on 02/10/23.
//

import Foundation

struct ExportSalesEmail {
    let subject: String = "Archivo solicitado"
    
    func body() -> String {
        return """
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
                    <p>¡La información que pediste está aquí!</p>
                    <p>Se agregó un archivo con la información.</p>
                </div>
                <div class="footer">
                    <p>Gracias por elegir Aline.</p>
                </div>
            </div>
        </body>
    </html>
    """
    }
}
