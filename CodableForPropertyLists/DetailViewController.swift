//
//  DetailViewController.swift
//  CodableForPropertyLists
//
//  Created by Laibit on 2018/7/24.
//  Copyright © 2018年 Laibit. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    var tablePrinterStructs = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //DetailModel.sharedInstance.setDetailValue()
        
        DetailModel.sharedInstance.getDetailValue()
        
        tablePrinterStructs = PlistModel.sharedInstance.constructTablePrinterSetting()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DetailViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tablePrinterStructs.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titleTemp = tablePrinterStructs[section].name
        return titleTemp
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tablePrinterStructs[section].plistSettings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tablePrinterStructs[indexPath.section].plistSettings[indexPath.row].title
        return cell
    }
    
    
}

