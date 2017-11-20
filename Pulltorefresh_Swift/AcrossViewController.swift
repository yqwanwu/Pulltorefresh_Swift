//
//  AcrossViewController.swift
//  Pulltorefresh_Swift
//
//  Created by wanwu on 2017/11/17.
//  Copyright © 2017年 wanwu. All rights reserved.
//

import UIKit

class AcrossViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    var p: PullToRefreshControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        if let fl = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            fl.itemSize = CGSize(width: 100, height: 200)
        }
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        p = PullToRefreshControl(scrollView: collectionView)
            .addDefaultHorizontalHeader(config: nil)
            .addDefaultHorizontalFooter()
        p.header?.addAction(with: .refreshing, action: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self?.p.header?.endRefresh()
            })
        })
        
        var counter = 0
        p.footer?.addAction(with: .refreshing, action: { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                self?.p.footer?.endRefresh()
                counter += 1
                if counter % 3 == 0 {
                    print("没有更多数据开启")
                    self?.p.footer?.state = .noMoreData
                }
            })
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.contentView.backgroundColor = UIColor(red: CGFloat(arc4random() & 255) / 255.0, green: CGFloat(arc4random() & 255) / 255.0, blue: CGFloat(arc4random() & 255) / 255.0, alpha: 1)
        return cell
    }

}
