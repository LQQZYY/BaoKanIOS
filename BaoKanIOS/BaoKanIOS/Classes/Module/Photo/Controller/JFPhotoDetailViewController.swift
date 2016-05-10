//
//  JFPhotoDetailViewController.swift
//  BaoKanIOS
//
//  Created by zhoujianfeng on 16/4/7.
//  Copyright © 2016年 六阿哥. All rights reserved.
//

import UIKit

class JFPhotoDetailViewController: UICollectionViewController {
    
    // MARK: - 属性
    /// 文章详情请求参数
    var photoParam: (classid: String, id: String)? {
        didSet {
            loadPhotoDetail(photoParam!.classid, id: photoParam!.id)
        }
    }
    
    let photoIdentifier = "photoDetail"
    var photoModels = [JFPhotoDetailModel]()
    
    // 导航栏/背景颜色
    let bgColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:1)
    
    init() {
        let myLayout = UICollectionViewFlowLayout()
        myLayout.itemSize = CGSize(width: SCREEN_WIDTH + 10, height: SCREEN_HEIGHT)
        myLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        myLayout.minimumLineSpacing = 0
        super.init(collectionViewLayout: myLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTappedPhotoDetailView(_:)))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = bgColor
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        bottomBgView.removeFromSuperview()
        bottomToolView.removeFromSuperview()
    }
    
    func didTappedRightBarButtonItem(item: UIBarButtonItem) -> Void {
        print("didTappedRightBarButtonItem")
    }
    
    private func prepareUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "top_navigation_more")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(didTappedRightBarButtonItem(_:)))
        
        collectionView?.frame = CGRect(x: 0, y: -64, width: SCREEN_WIDTH + 10, height: SCREEN_HEIGHT + 64)
        collectionView?.pagingEnabled = true
        collectionView?.backgroundColor = bgColor
        collectionView?.registerClass(JFPhotoDetailCell.self, forCellWithReuseIdentifier: photoIdentifier)
        
        UIApplication.sharedApplication().keyWindow?.addSubview(bottomToolView)
        UIApplication.sharedApplication().keyWindow?.addSubview(bottomBgView)
        bottomBgView.addSubview(captionLabel)
        
        bottomToolView.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(44)
        }
        
        bottomBgView.snp_makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.bottom.equalTo(bottomToolView.snp_top)
            make.height.equalTo(20)
        }
        
        captionLabel.snp_makeConstraints { (make) in
            make.left.equalTo(20)
            make.top.equalTo(10)
            make.width.equalTo(SCREEN_WIDTH - 40)
        }
        
        updateBottomBgViewConstraint()
    }
    
    /**
     更新底部详情视图的高度
     */
    private func updateBottomBgViewConstraint() {
        UIApplication.sharedApplication().keyWindow?.layoutIfNeeded()
        
        bottomBgView.snp_updateConstraints { (make) in
            make.height.equalTo(captionLabel.height + 20)
        }
    }
    
    /**
     详情视图界面tap事件，在这隐藏或显示除图片外的UI
     */
    func didTappedPhotoDetailView(tap: UITapGestureRecognizer) -> Void {
        
        let alpha: CGFloat = UIApplication.sharedApplication().statusBarHidden == false ? 0 : 1
        
        UIView.animateWithDuration(0.25) {
            // 状态栏
            UIApplication.sharedApplication().statusBarHidden = !UIApplication.sharedApplication().statusBarHidden
            
            // 导航栏
            self.navigationController?.navigationBar.alpha = alpha
            
            // 底部视图
            self.bottomBgView.alpha = alpha
            self.bottomToolView.alpha = alpha
        }
        
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoModels.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(photoIdentifier, forIndexPath: indexPath) as! JFPhotoDetailCell
        cell.model = photoModels[indexPath.item]
        return cell
    }
    
    // 滚动停止后调用，判断当然显示的第一张图片
    override func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        print(scrollView.contentOffset)
    }
    
    /**
     加载
     
     - parameter classid: 当前子分类id
     - parameter id:      文章id
     */
    func loadPhotoDetail(classid: String, id: String) {
        let parameters = [
            "table" : "news",
            "classid" : classid,
            "id" : id,
            ]
        
        JFNetworkTool.shareNetworkTool.get(ARTICLE_DETAIL, parameters: parameters) { (success, result, error) -> () in
            if success == true {
                if let successResult = result {
                    //                    print(successResult)
                    let morepic = successResult["data"]["content"]["morepic"].arrayValue
                    for picJSON in morepic {
                        let dict = [
                            "title" : picJSON.dictionaryValue["title"]!.stringValue, // 图片标题
                            "picurl" : picJSON.dictionaryValue["url"]!.stringValue,  // 图片url
                            "text" : picJSON.dictionaryValue["caption"]!.stringValue // 图片文字描述
                        ]
                        
                        let model = JFPhotoDetailModel(dict: dict)
                        self.photoModels.append(model)
                    }
                    
                    // 刷新视图
                    self.collectionView?.reloadData()
                }
            } else {
                print("error:\(error)")
            }
        }
    }
    
    // MARK: - 懒加载
    /// 底部文字透明背景视图
    lazy var bottomBgView: UIView = {
        let bottomBgView = UIView()
        bottomBgView.backgroundColor = UIColor(red:0.110,  green:0.102,  blue:0.110, alpha:0.8)
        return bottomBgView
    }()
    
    /// 文字描述
    lazy var captionLabel: UILabel = {
        let captionLabel = UILabel()
        captionLabel.textColor = UIColor(red:0.945,  green:0.945,  blue:0.945, alpha:1)
        captionLabel.numberOfLines = 0
        captionLabel.font = UIFont.systemFontOfSize(15)
        captionLabel.text = "1/25  2016年1月23日“2015年掌阅科技年会暨年度表彰大会”于北京古北水镇旅游度假区盛大启幕。现场汇集了数百名新老员工以及嘉宾，气氛热烈。"
        return captionLabel
    }()
    
    /// 底部工具条
    lazy var bottomToolView: UIView = {
        let bottomToolView = UIView()
        bottomToolView.backgroundColor = self.bgColor
        return bottomToolView
    }()
    
}

