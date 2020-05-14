//
//  DetailViewController.swift
//  testsearchapp
//
//  Created by Alvaro Badaracco on 4/22/20.
//  Copyright © 2020 Mercado Libre. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

struct Picture: Codable {
    var id: String
    var secure_url: String
}

struct ItemDetailModel : Codable {
    let id: String
    let title: String
    let price: Double
    var pictures: Array<Picture>
}

class DetailViewController: UIViewController {
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    
    var selectedItem: ItemModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        detailLabel.text = selectedItem?.title
        
        AF.request("https://api.mercadolibre.com/items?id=\(selectedItem?.id ?? "1234")",
                         method: .get).responseDecodable(of: ItemDetailModel.self) { response in
                  
                            self.detailLabel.text = response.value?.title
                            self.priceLabel.text = "$ \(String(Int(response.value!.price)))"
                            
                            AF.request(response.value!.pictures[0].secure_url).responseImage { imgResponse in
                                if case .success(let img) = imgResponse.result {
                                    DispatchQueue.main.async {
                                        self.image.image = img
                                    }
                                }
                            }
                            
                    }
                }
}
