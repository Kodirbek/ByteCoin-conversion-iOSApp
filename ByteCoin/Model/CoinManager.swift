//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoin(_ coinManager: CoinManager, coin: CoinModel)
    func didFailWithError(error: Error)
}

func getAPI() -> String {
  var key: NSDictionary?
  var coinApi = ""
  if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
        key = NSDictionary(contentsOf: URL(fileURLWithPath: path))
    }
    
  if let dict = key {
    coinApi = dict["CoinApi"] as? String ?? ""
    }
  return coinApi
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = getAPI()
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","KRW","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let coin = parseJSON(safeData) {
                        delegate?.didUpdateCoin(self, coin: coin)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON (_ coinData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do{
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            
            let rate = decodedData.rate
            let coin = CoinModel(selectedRate: rate)
            return coin
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
}
