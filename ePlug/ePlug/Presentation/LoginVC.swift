//
//  LoginVC.swift
//  ePlug
//
//  Created by Yusuf Furkan Ayyıldız on 26.02.2024.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

class LoginVC: UIViewController{

    func showAlert(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Tamam", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
    }
    
    let firebaseImageviev: UIImageView = {
       let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.image = UIImage(named: "EplugLogo")
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    
    let stackView: UIStackView = {
        let stckView = UIStackView()
        stckView.translatesAutoresizingMaskIntoConstraints = false
        stckView.axis = .vertical
        stckView.spacing = 10
        return stckView
    }()
    
    let mailTextField: UITextField = {
       let txtField = UITextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.placeholder = "E-Mail Giriniz"
        txtField.font = .systemFont(ofSize: 14, weight: .semibold)
        txtField.borderStyle = .roundedRect
        return txtField
    }()
    
    let passwordTextField: UITextField = {
       let txtField = UITextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.placeholder = "Sifre Giriniz"
        txtField.font = .systemFont(ofSize: 14, weight: .semibold)
        txtField.borderStyle = .roundedRect
        txtField.isSecureTextEntry = true
        return txtField
    }()
    
    let signInButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Giriş Yap", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        btn.backgroundColor = .systemGreen
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    let signUpButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Kayıt Ol", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        btn.backgroundColor = .systemGray
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    let signInWithGoogleButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Google ile Giriş Yap", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    /*let signInWithAppleIdStack: UIStackView = {
        let stckView = UIStackView()
        stckView.translatesAutoresizingMaskIntoConstraints = false
        return stckView
    }()*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "E-Plug Login"
        setLayouts()
        setDelegateAndButtonAction()
    }
    
    func setDelegateAndButtonAction(){
        signInButton.addTarget(self, action: #selector(signInButtonAction), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonAction), for: .touchUpInside)
        signInWithGoogleButton.addTarget(self, action: #selector(signInWithGoogleButtonAction), for: .touchUpInside)
    }
    
    func setLayouts(){
        //let authorizationButton = ASAuthorizationAppleIDButton()
        view.addSubview(stackView)
        view.addSubview(firebaseImageviev)
        stackView.addArrangedSubview(mailTextField)
        stackView.addArrangedSubview(passwordTextField)
        stackView.addArrangedSubview(signInButton)
        stackView.addArrangedSubview(signUpButton)
        stackView.addArrangedSubview(signInWithGoogleButton)
        //stackView.addArrangedSubview(signInWithAppleIdStack)
        //signInWithAppleIdStack.addArrangedSubview(authorizationButton)
        
        NSLayoutConstraint.activate([
            firebaseImageviev.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            firebaseImageviev.heightAnchor.constraint(equalToConstant: 100),
            firebaseImageviev.widthAnchor.constraint(equalToConstant: 250),
            firebaseImageviev.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: firebaseImageviev.bottomAnchor, constant: 30),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 300),
            
            mailTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            signInButton.heightAnchor.constraint(equalToConstant: 50),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            signInWithGoogleButton.heightAnchor.constraint(equalToConstant: 50),
            //signInWithAppleIdStack.heightAnchor.constraint(equalToConstant: 50)

        ])
    }
}

extension LoginVC{
    
    @objc func signUpButtonAction(){
        guard let mailText = mailTextField.text, let passwordText = passwordTextField.text else {return}
        Auth.auth().createUser(withEmail: mailText, password: passwordText){[weak self] authResult,error in
            guard let self = self else {return}
            guard let _ = authResult, error == nil else{
                self.showAlert(title: "hata oluştu", message: "Kullanıcı oluşturulurken hata oluştu. Lütfen bilgileri kontrol ediniz")
                return
            }
            
            self.showAlert(title: "Başarıyla Oluşturuldu", message: "Kullanıcı Oluşturuldu. Giriş Yapabilirsiniz.")
        }
    }
    
    @objc func signInButtonAction(){
        guard let mailText = mailTextField.text, let passwordText = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: mailText, password: passwordText){[weak self] authResult,error in
            guard let self = self else {return}
            guard let _ = authResult, error == nil else{
                self.showAlert(title: "hata oluştu", message: "Kullanıcı bilgileri yanlış. Lütfen doğru bilgileri giriniz")
                return
            }
            
            self.openMainMenuVC()
        }
    }
    
    @objc func signInWithGoogleButtonAction() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let _ = result, error == nil else {return}

          guard let user = result?.user, let idToken = user.idToken?.tokenString else {return}

            _ = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            self?.signInWithGoogle(idToken: idToken, accessToken: user.accessToken.tokenString)
        }
    }
    func signInWithGoogle(idToken: String, accessToken: String){
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            guard let _ = result, error == nil else { return }
            self?.openMainMenuVC()
        }
            
    }
    
    func openMainMenuVC(){
        let vc = MainTabBarController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
