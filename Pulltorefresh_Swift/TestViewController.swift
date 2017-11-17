//
//  TestViewController.swift
//  Pulltorefresh_Swift
//
//  Created by wanwu on 2017/5/18.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var p: PullToRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 500, right: 50)
        
        tableView.dataSource = self
        p = PullToRefreshControl(scrollView: tableView).addDefaultHeader(config: { (header) in
            header.titleLabel.textColor = UIColor.red
        }).addDefaultFooter()
        p.footer?.autoLoadWhenIsBottom = false
        
        p.header?.addAction(with: .refreshing, action: { [weak self] in
            //模拟数据请求
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                self?.p.header?.endRefresh()
            })
        }).addAction(with: .end, action: {
            print("那啥 结束了都")
        })
        
        p.footer?.addAction(with: .refreshing, action: { [unowned self] in
            //模拟数据请求
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                self.p.footer?.endRefresh()
            })
        }).addAction(with: .end, action: {
            print("加载完了")
        })
    }

    @IBAction func ac_test(_ sender: Any) {
        self.p.header?.beginRefresh()
    }
    
    @IBAction func ac_test1(_ sender: Any) {
        self.p.footer?.beginRefresh()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    }

}
