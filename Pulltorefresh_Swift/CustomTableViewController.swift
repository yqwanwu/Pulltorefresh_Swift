//
//  CustomTableViewController.swift
//  reuseTest
//
//  Created by wanwu on 2017/4/10.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class CustomTableViewController: UITableViewController {
    
    private var kRefreshHeight: CGFloat = 200.0
    
    var p: PullToRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        p = PullToRefreshControl(scrollView: tableView).addDefaultHeader(config: { (header) in
            header.titleLabel.textColor = UIColor.red
        }).addDefaultFooter()
        
//        p = PullToRefreshControl(scrollView: tableView).addGifHeader(config: { (gifHeader) in
//            gifHeader.gifFrame = CGRect(x: 40, y: 20, width: 100, height: 60)
//            var imgArr = [UIImage]()
//            for i in 1...8 {
//                imgArr.append(UIImage(named: "timg\(i)")!)
//            }
//            gifHeader.setImgArr(state: .pulling, imgs: imgArr)
//            gifHeader.setImgArr(state: .refreshing, imgs: imgArr, animationTime: 2.0)
//        }).addGifFooter(config: { (gifFooter) in
//            let url = Bundle.main.url(forResource: "luufy", withExtension: "gif")
//            let data = try! Data(contentsOf: url!)
//            gifFooter.setGifData(state: .pulling, gifData: data)
//            let url1 = Bundle.main.url(forResource: "timg", withExtension: "gif")
//            let data1 = try! Data(contentsOf: url1!)
//            gifFooter.setGifData(state: .refreshing, gifData: data1)
//            
//        })
        
        p.header?.addAction(with: .refreshing, action: { [unowned self] _ in
            //模拟数据请求
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                self.p.header?.endRefresh()
                self.counter = 2
                self.tableView.reloadData()
            })
        }).addAction(with: .end, action: { 
            print("那啥 结束了都")
        })
        
        p.footer?.addAction(with: .refreshing, action: { [unowned self] _ in
            //模拟数据请求
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
                self.p.footer?.endRefresh()
                self.tableView.reloadData()
                if self.counter > 40 {
                    self.p.footer?.state = .noMoreData
                }
            })
        }).addAction(with: .end, action: { 
            print("加载完了")
        })
        
        
    }
    @IBAction func ac_down(_ sender: Any) {
        p.header?.beginRefresh()
    }
    
    @IBAction func ac_close(_ sender: Any) {
        p.footer?.autoLoadWhenIsBottom = !(p.footer?.autoLoadWhenIsBottom ?? false)
    }

    @IBAction func ac_up(_ sender: Any) {
        p.footer?.beginRefresh()
    }
    var counter = 2
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        counter += 5
        return counter
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "第 \(indexPath.row) 行"
        return cell
    }
    
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        refreshView.scrollViewDidScroll(scrollView)
    }
    
    

}
