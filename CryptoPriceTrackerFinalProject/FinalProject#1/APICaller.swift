//
//  APIcaller.swift
//  FinalProject#1
//
//  Created by Omar Shakir on 4/18/22.
//

import Foundation
import UIKit

final class APICaller {
    static let shared = APICaller()
    
    private struct Constants {
        static let apiKey = "215B7C7A-221C-4625-B927-5E7B6D3C15CF"
        static let assetsEndpoint = "https://rest.coinapi.io/v1/assets"
    }
    
    private init() {}
    
    public var icons: [Icon] = []
    
    private var whenReadyBlcok: ((Result<[Crypto], Error>) -> Void)?
    
    public func getAllCryptoData(
        completion: @escaping (Result<[Crypto], Error>) -> Void
    ) {
        guard !icons.isEmpty else {
            whenReadyBlcok = completion
            return
        }
        
        guard let url = URL(string: Constants.assetsEndpoint + "?apikey=" + Constants.apiKey) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                
                let cryptos = try JSONDecoder().decode([Crypto].self, from: data)
                completion(.success( cryptos.sorted { first, secodn -> Bool in
                    return first.price_usd ?? 0 > secodn.price_usd ?? 0
                }))
            }
            catch {
                completion(.failure(error))
            }
        
        }
        
        task.resume()
    }
    
    public func getAllIcons() {
        guard let url = URL(string:"https://rest.coinapi.io/v1/assets/icons/55?apikey=215B7C7A-221C-4625-B927-5E7B6D3C15CF")
            else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                
                self?.icons = try JSONDecoder().decode([Icon].self, from: data)
                if let completion = self?.whenReadyBlcok {
                    self?.getAllCryptoData(completion: completion)
                }
                
            }
            catch {
                print(error)
                
            }
        
        }
        
        task.resume()
           
    }
}
