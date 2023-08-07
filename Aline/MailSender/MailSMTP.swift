//
//  MailSMTP.swift
//  Aline
//
//  Created by Leonardo on 27/07/23.
//

import Foundation
import MessageUI
import Network
import MailCore
import UIKit

struct MailSMTP {
    
    func send(to: User, subject: String, body: String) {
        let name = to.name
        let email = to.email
        let subject = subject
        let body = body
        sendEmail(name: name, email: email, subject: subject, body: body)
    }
    
    func send(name: String, email: String, subject: String, body: String) {
        let name = name
        let email = email
        let subject = subject
        let body = body
        sendEmail(name: name, email: email, subject: subject, body: body)
    }
    
    private func sendEmail(name: String, email: String, subject: String, body: String) {
        // Crear el mensaje utilizando MCOMessageBuilder
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: name, mailbox: email)!]
        builder.header.from = MCOAddress(displayName: "Aline", mailbox: "alineapplication@icloud.com")
        builder.header.subject = subject
        builder.htmlBody = body

        // Obtener los datos del mensaje como Data
        guard let data = builder.data() else {
            print("Error al obtener los datos del mensaje")
            return
        }
        
        print("Si se obtuvieron los datos")
        // Configurar la sesión SMTP
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.mail.me.com"
        smtpSession.port = 587
        smtpSession.username = "alineapplication@icloud.com"
        smtpSession.password = "ruiy-bnjj-czox-fkcc"
        smtpSession.connectionType = .startTLS
        // Enviar el mensaje utilizando la sesión SMTP
        let operation = smtpSession.sendOperation(with: data)
        operation?.start { error in
            if let error = error {
                print("Error al enviar el mensaje: \(error.localizedDescription)")
            } else {
                print("Mensaje enviado con éxito")
            }
        }
    }
}
