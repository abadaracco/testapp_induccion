//
//  ListViewController.swift
//  testsearchapp
//
//  Created by Alvaro Badaracco on 4/21/20.
//  Copyright © 2020 Mercado Libre. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreData

struct SearchResultModel: Codable {
    var site: String
    var query: String
    var results: [ItemModel]?
    
    private enum CodingKeys: String, CodingKey {
        case site = "site_id"
        case query
        case results
    }
}

struct ItemModel: Codable {
    let title: String
    let price: Double
    let thumbnail: String
    let id: String
}

enum ListMode {
    case search
    case history
}

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var items:[ItemModel] = []
    var history:[String] = []
    var selectedRow:Int?
    public var query: String = ""
    public var mode: ListMode = .search
    var favorites: [NSManagedObject] = []
    static let HISTORY_KEY = "HISTORY-KEY"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if (self.mode == .search) {
            searchItems()
        } else if (self.mode == .history){
            fetchHistory()
        }

    }
    
    func searchItems() {
        saveSearchToHistory()
        
        AF.request("https://api.mercadolibre.com/sites/MLA/search?q=\(self.query)",
                   method: .get).responseDecodable(of: SearchResultModel.self) { response in
          
          // response tiene JSON con data de respuesta
                    if let searchResults = response.value?.results {
                        self.items = searchResults
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.title = response.value?.site
                        }
                    }
                    
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if (self.mode == .search) {
            guard let selected = selectedRow, let detailVC = segue.destination as? DetailViewController else {
                return
            }
            
            detailVC.selectedItem = items[selected]
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.mode == .search) {
            return items.count
        } else {
            return history.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.mode == .search) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomCellView
            cell.titleLabel.text = items[indexPath.row].title
            cell.priceLabel.text = "$\(String(Int(items[indexPath.row].price)))"
            AF.request(items[indexPath.row].thumbnail).responseImage { response in
                if case .success(let image) = response.result {
                    cell.thumbnail.image = image
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") as! HistoryCellView
            cell.titleLabel.text = history[indexPath.row]
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (self.mode == .search) {
            self.selectedRow = indexPath.row
            self.performSegue(withIdentifier: "detalle", sender: nil)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let listVC = storyboard.instantiateViewController(withIdentifier: "listViewController") as! ListViewController
            listVC.query = history[indexPath.row]
            self.navigationController?.pushViewController(listVC, animated: true)
        }
        
    }

    func fetchHistory() {
        history = UserDefaults.standard.stringArray(forKey: ListViewController.HISTORY_KEY) ?? []
    }
    
    func saveSearchToHistory() {
        guard self.mode == .search else {
            return
        }
        
        guard self.query.count > 0 else {
            return
        }
        
        var history = UserDefaults.standard.stringArray(forKey: ListViewController.HISTORY_KEY) ?? []
        history.insert(self.query, at: 0)
        UserDefaults.standard.set(history, forKey: ListViewController.HISTORY_KEY)
    }

}


