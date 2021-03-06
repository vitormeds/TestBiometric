//
//  ViewController.swift
//  TestBiometric
//
//  Created by Vitor Mendes on 12/09/2018.
//  Copyright © 2018 br.com.sankhya.labs. All rights reserved.
//

import UIKit
import LocalAuthentication
import KeychainAccess

class ViewController: UIViewController {

    var viewBiometric = BiometricView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        view.addSubview(viewBiometric)//adiciona a label na tela
        viewBiometric.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        viewBiometric.topAnchor.constraint(equalTo: view.topAnchor, constant: 16).isActive = true
        viewBiometric.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        viewBiometric.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        
        viewBiometric.biometricButton.addTarget(self, action: #selector(authenticator), for: UIControlEvents.touchDown)
        
        //carrega Keychain desse usuario
        loadKey(account: "Teste")
        
    }
    
    @objc func authenticator()
    {
        //salva os dados de autenticação em uma KeyChain
        saveKey(account: viewBiometric.userField.text!, password: viewBiometric.passwordField.text!)
        //carrega a KeyChain salva
        loadKey(account: viewBiometric.userField.text!)
        
        let localAuthenticationContext = LAContext()
        var authError: NSError?
        let reasonString = "Para autenticar no APP"
        
        //verifica se tem acesso ao Touch ID
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    
                    self.showAlert(message: "Autenticado com sucesso")
                    
                } else {
                    guard let error = evaluateError else {
                        return
                    }
                    self.showAlert(message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
            
            showAlert(message: self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
        }
    }
    
    func saveKey(account: String, password: String) {
        let keychain = Keychain(service: "test")
        keychain[account] = password
    }
    
    func loadKey(account: String) {
        let keychain = Keychain(service: "test")
        authenticateUser(storedPassword: keychain[account]!)
    }
    
    func authenticateUser(storedPassword :  String)
    {
        print(storedPassword)
    }
    
    func showAlert(message: String)
    {
        let alertController = UIAlertController(title: "Autenticação", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "O dispositivo não suporta Touch ID"
                
            case LAError.biometryLockout.rawValue:
                message = "A autenticação não pôde continuar porque o usuário foi bloqueado pela autenticação biométrica, devido à falha na autenticação muitas vezes."
                
            case LAError.biometryNotEnrolled.rawValue:
                message = "Usuario não cadastrado no Touch ID"
                
            default:
                message = "Erro interno"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Muitas tentativas falhas."
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID não disponivel nesse dispositivo"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID não cadastrado nesse dispositivo"
                
            default:
                message = "Erro interno"
            }
        }
        
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "Credenciais invalidas"
            
        case LAError.appCancel.rawValue:
            message = "Autenticação cancelada pela aplicação"
            
        case LAError.invalidContext.rawValue:
            message = "Erro interno"
            
        case LAError.notInteractive.rawValue:
            message = "Sem interação"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Senha não definida no dispositivo"
            
        case LAError.systemCancel.rawValue:
            message = "Autenticação cancelada pelo sistema"
            
        case LAError.userCancel.rawValue:
            message = "Usuario cancelou a autenticação"
            
        case LAError.userFallback.rawValue:
            message = "O usuario trocou o tipo de autenticação"
            
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
    }

}

