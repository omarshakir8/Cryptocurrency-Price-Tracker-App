//
//  ViewController.swift
//  FinalProject#1
//
//  Created by Omar Shakir on 4/18/22.
//

import UIKit



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(CryptoTableViewCell.self,
                           forCellReuseIdentifier: CryptoTableViewCell.identifier)
        return tableView
    }()
    
    private var viewModels = [CryptoTableViewCellModel]()
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.allowsFloats = true
        formatter.numberStyle = .currency
        formatter.formatterBehavior = .default
        
        return formatter
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Crypto Tracker"
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        APICaller.shared.getAllCryptoData { [weak self] result in
            switch result {
            case .success(let models):
                self?.viewModels = models.compactMap({ model in
                    
                    let price = model.price_usd ?? 0
                    let formatter = ViewController.numberFormatter
                    let priceString = formatter.string(from: NSNumber(value: price))
                    
                    
                    let iconUrl = URL(
                        string:
                            APICaller.shared.icons.filter({ icon in
                                icon.asset_id == model.asset_id
                            }).first?.url ?? ""
                    )
                    
                    return CryptoTableViewCellModel(
                        name: model.name ?? "N/A",
                        symbol: model.asset_id,
                        price: priceString ?? "N/A",
                        iconUrl: iconUrl
                           
                    )
                })
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Error: \(error) ")
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CryptoTableViewCell.identifier,
            for: indexPath
        ) as? CryptoTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
                                                                                                                                             


}

