//
//  ViewController.swift
//  WebsocketSwift
//
//  Created by Cedan Misquith on 10/04/20.
//  Copyright © 2020 Cedan Misquith. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, SocketProtocol {
    func printLog(data: String) {
        if consoleTextView.text != ""{
            consoleTextView.text = "\(consoleTextView.text ?? "")\n-----------------\n \(data)"
            clearConsoleButton.isEnabled = true
        }else{
            consoleTextView.text = data
        }
    }
    
    func socketStatus(status: Bool) {
        if status{
            socketStatusLabel.text = "Socket is Connected"
            animShow()
            animHide()
            socketStatusView.backgroundColor = .green
            sendObjectButton.isEnabled = true
        }else{
            socketStatusLabel.text = "Socket Disconnected"
            animShow()
            animHide()
            socketStatusView.backgroundColor = .red
            sendObjectButton.isEnabled = false
        }
    }

    @IBOutlet weak var socketStatusLabel: UILabel!
    @IBOutlet weak var socketTextField: UITextField!
    @IBOutlet weak var objectTextView: UITextView!
    @IBOutlet weak var connectSocketButton: UIButton!
    @IBOutlet weak var disconnectSocketButton: UIButton!
    @IBOutlet weak var sendObjectButton: UIButton!
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var consoleTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var consoleButton: UIButton!
    @IBOutlet weak var clearConsoleButton: UIButton!
    @IBOutlet weak var socketStatusView: UIView!
    
    var consoleState = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objectTextView.text = "Enter an object to send to socket."
        objectTextView.delegate = self
        
        socketTextField.addTarget(self, action: #selector(ViewController.textDidChange(_:)), for: UIControl.Event.editingChanged)
        
        connectSocketButton.isEnabled = false
        disconnectSocketButton.isEnabled = false
        sendObjectButton.isEnabled = false
        
        SocketManager.sharedInstance.delegate = self
        consoleTextViewHeightConstraint.constant = 0
        clearConsoleButton.isEnabled = false
        
        configureStyling()
    }
    
    @IBAction func clearConsoleButtonAction(_ sender: UIButton) {
        if consoleTextView.text != ""{
            consoleTextView.text = ""
            clearConsoleButton.isEnabled = false
            consoleTextViewHeightConstraint.constant = 0
        }
    }
    
    @IBAction func consoleStateButtonAction(_ sender: UIButton) {
        if consoleState{
            hideConsole()
        }else{
            showConsole()
        }
    }
    
    func hideConsole(){
        consoleTextViewHeightConstraint.constant = 0
        consoleButton.setTitle("Show Console", for: .normal)
        consoleState = false
    }
    
    func showConsole(){
        consoleTextViewHeightConstraint.constant = 150
        consoleButton.setTitle("Hide Console", for: .normal)
        consoleState = true
    }
    
    func configureStyling(){
        socketStatusView.layer.cornerRadius = 6
        socketStatusView.backgroundColor = .red
        
        objectTextView.textColor = .lightGray
        objectTextView.layer.cornerRadius = 6
        objectTextView.layer.borderWidth = 1
        objectTextView.layer.borderColor = UIColor.black.cgColor
        
        consoleTextView.layer.cornerRadius = 6
    }
    
    func animShow(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],
                       animations: {
                        self.socketStatusLabel.center.y -= self.socketStatusLabel.frame.height
                        self.socketStatusLabel.layoutIfNeeded()
        }, completion: nil)
    }
    func animHide(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],
                       animations: {
                        self.socketStatusLabel.center.y += self.socketStatusLabel.frame.height
                        self.socketStatusLabel.layoutIfNeeded()
                        
        },  completion: {(_ completed: Bool) -> Void in
        })
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter an object to send to socket."
            textView.textColor = UIColor.lightGray
        }
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        if textField.text != "" {
            connectSocketButton.isEnabled = true
            disconnectSocketButton.isEnabled = false
        }else{
            connectSocketButton.isEnabled = false
            disconnectSocketButton.isEnabled = true
        }
    }

    @IBAction func connectButtonAction(_ sender: UIButton) {
        if socketTextField.text != "" {
            SocketManager.sharedInstance.connect(url: socketTextField.text ?? "")
            connectSocketButton.isEnabled = false
            disconnectSocketButton.isEnabled = true
            showConsole()
        }
    }
    
    @IBAction func disconnectButtonAction(_ sender: UIButton) {
        SocketManager.sharedInstance.disconnect()
        connectSocketButton.isEnabled = true
        disconnectSocketButton.isEnabled = false
    }
    
    @IBAction func sendObjectButtonAction(_ sender: UIButton) {
        SocketManager.sharedInstance.sendDataToSocket(data: objectTextView.text)
    }
    
    @IBAction func testObjectButtonAction(_ sender: UIButton) {
        objectTextView.becomeFirstResponder()
        objectTextView.text = ""
        let object: Any = [
            "socketType": 1,
            "socketData": [
                "userId": "ABCD123",
                "userDeviceId": "XYZ123"
            ]
        ]
        do {
            let data = try JSONSerialization.data(withJSONObject: object, options: [])
            let objectString = String(decoding: data, as: UTF8.self)
            objectTextView.text = objectString
        } catch let error {
            print("[WEBSOCKET] Error serializing JSON:\n\(error)")
        }
    }
    
    @IBAction func clearButtonAction(_ sender: UIButton) {
        objectTextView.text = "Enter an object to send to socket."
        objectTextView.textColor = UIColor.lightGray
        socketTextField.resignFirstResponder()
        objectTextView.resignFirstResponder()
    }
    
}

