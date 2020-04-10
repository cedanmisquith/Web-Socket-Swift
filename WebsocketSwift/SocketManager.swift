//
//  SocketManager.swift
//  WebsocketSwift
//
//  Created by Cedan Misquith on 10/04/20.
//  Copyright © 2020 Cedan Misquith. All rights reserved.
//

import Starscream
import SwiftyJSON

protocol SocketProtocol {
    func socketStatus(status: Bool)
    func printLog(data: String)
}

class SocketManager: NSObject, WebSocketDelegate {
    
    static let sharedInstance = SocketManager()
    
    var socket: WebSocket!
    var isConnected = false
    var delegate: SocketProtocol!

    override init() {
        super.init()
    
    }
    
    func sendDataToSocket(data: String) {
        socket.write(string: data) {
            print("Successfully sent data: \n \(data)")
        }
    }
    
    func connect(url: String){
        var request = URLRequest(url: URL(string: url)!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func disconnect(){
        socket.disconnect()
    }
    
    func convertToString(data: Any) -> String{
        var dataStr = ""
        do {
            let data = try JSONSerialization.data(withJSONObject: data, options: [])
            let objectString = String(decoding: data, as: UTF8.self)
            dataStr = objectString
        } catch let error {
            dataStr = "[WEBSOCKET] Error serializing JSON:\n\(error)"
        }
        return dataStr
    }
    
    // MARK: - WebSocketDelegate
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            delegate.printLog(data: convertToString(data: headers))
            delegate.socketStatus(status: isConnected)
        case .disconnected(let reason, let code):
            isConnected = false
            delegate.socketStatus(status: isConnected)
            delegate.printLog(data: "websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            let json = string.data(using: String.Encoding.utf8).flatMap({try? JSON(data: $0)}) ?? JSON(NSNull())
            if let socketType = json["socketType"].int{
                switch socketType {
                case 1:
                    delegate.printLog(data: "Response for SocketType: 1 \n\(json)")
                default:
                    print("Invalid Socket Type")
                    delegate.printLog(data: "Invalid Socket Type, response is: \n\(json)")
                }
            }
        case .binary(let data):
            delegate.printLog(data: "Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viablityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
            delegate.socketStatus(status: isConnected)
        case .error(let error):
            isConnected = false
            delegate.socketStatus(status: isConnected)
            handleError(error)
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            delegate.printLog(data: "websocket encountered an error: \(e.message)")
        } else if let e = error {
            delegate.printLog(data: "websocket encountered an error: \(e.localizedDescription)")
        } else {
            delegate.printLog(data: "websocket encountered an error")
        }
    }

}
