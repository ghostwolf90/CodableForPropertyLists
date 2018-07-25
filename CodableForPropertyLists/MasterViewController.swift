//
//  MasterViewController.swift
//  CodableForPropertyLists
//
//  Created by Laibit on 2018/7/24.
//  Copyright © 2018年 Laibit. All rights reserved.
//

import UIKit

class MasterViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    
    let preferencesTitles = ["桌邊","內場","標籤機","藍芽讀卡機"]
    let preferencesSegueIdentifier = ["seguePrinterSetting","segueKitchenSetting","segueLabelSetting","segueBleSetting"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        self.performSegue(withIdentifier: "seguePrinterSetting", sender: nil)
    }
    
    func initView(){
        // navigationbar 設定 隱藏底部線
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width:360 , height: 8))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MasterViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return preferencesTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = preferencesTitles[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: preferencesSegueIdentifier[indexPath.row], sender: nil)
    }
}

