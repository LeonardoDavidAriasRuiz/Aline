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
    func send(to: User, subject: String, body: String, action: @escaping () -> Void, ifNot: @escaping () -> Void, alwaysDo: @escaping () -> Void) {
        sendEmail(name: to.name, email: to.email, subject: subject, body: body, data: nil, fileName: "") { sent in
            if sent {
                action()
            } else {
                ifNot()
            }
            alwaysDo()
        }
    }
    
    func send(name: String, email: String, subject: String, body: String, action: @escaping () -> Void, ifNot: @escaping () -> Void, alwaysDo: @escaping () -> Void) {
        sendEmail(name: name, email: email, subject: subject, body: body, data: nil, fileName: "") { sent in
            if sent {
                action()
            } else {
                ifNot()
            }
            alwaysDo()
        }
    }
    
    func send(name: String, email: String, subject: String, body: String, data: Data, fileName: String, action: @escaping () -> Void, ifNot: @escaping () -> Void, alwaysDo: @escaping () -> Void) {
        sendEmail(name: name, email: email, subject: subject, body: body, data: data, fileName: fileName) { sent in
            if sent {
                action()
            } else {
                ifNot()
            }
            alwaysDo()
        }
    }
    
    private func sendEmail(name: String, email: String, subject: String, body: String, data: Data?, fileName: String, completion: @escaping (Bool) -> Void) {
        // Crear el mensaje utilizando MCOMessageBuilder
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: name, mailbox: email)!]
        builder.header.from = MCOAddress(displayName: "Aline", mailbox: "alineapplication@icloud.com")
        builder.header.subject = subject
        builder.htmlBody = body
        if let data = data {
            builder.addAttachment(MCOAttachment(data: data, filename: fileName))
        }

        // Obtener los datos del mensaje como Data
        guard let data = builder.data() else {
            print("No se pudo obtener los datos del mensaje como Data")
            completion(false)
            return
        }
        
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
            completion(error == nil)
        }
    }
}


