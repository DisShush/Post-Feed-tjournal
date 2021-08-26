//
//  PostTableViewController.swift
//  PostFeed
//
//  Created by Владислав Шушпанов on 24.08.2021.
//

import UIKit

class PostTableViewController: UITableViewController {
    
    let networkManager = NetworkManager()
    let imageService = ImageService()
    var postData: PostData?
    private var loadingMore: Bool = false
    var contentOffset = CGPoint(x: 0, y: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        networkManager.request { postData in
            guard let data = postData else { return }
            self.postData = data
            self.tableView.reloadData()
        }
    }
    
    @objc func handleTap2(_ sender: UITapGestureRecognizer) {
        
        if let viewWithTag = self.view.viewWithTag(100), let view2 = self.view.viewWithTag(101) {
            viewWithTag.removeFromSuperview()
            view2.removeFromSuperview()
        }
    
     }
    
    
    @objc func handleTap( _ sender: UITapGestureRecognizer) {
        let imageView = sender.view as? UIImageView
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        let viewGray = UIView(frame: CGRect(origin: contentOffset, size: (window?.bounds.size)!))
        viewGray.backgroundColor = .black
        viewGray.alpha = 0.8
        guard let image = imageView?.image else { return }
        var width = image.size.width
        var height = image.size.height
        let relation = width / 400
        width /= relation
        height /= relation

        let imageViewNew = UIImageView.init(frame: CGRect(x: 0, y: contentOffset.y + 200, width: width, height: height))
        imageViewNew.image = image
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap2))

        viewGray.addGestureRecognizer(tap)
        viewGray.isUserInteractionEnabled = true

        
        viewGray.tag = 100
        imageViewNew.tag = 101
        
        self.tableView.addSubview(viewGray)
        self.tableView.addSubview(imageViewNew)
     }
    
    
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        contentOffset = scrollView.contentOffset

    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return postData?.result.items.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as! PostCell
        
        cell.headerPost.text = postData?.result.items[indexPath.section].data.title
        cell.textPost.text = postData?.result.items[indexPath.section].data.blocks.first?.data.text
        cell.author.text = postData?.result.items[indexPath.section].data.author.name
        cell.commentCount.text = postData?.result.items[indexPath.section].data.counters.comments.description
        cell.likeCount.text = postData?.result.items[indexPath.section].data.likes.counter.description
        cell.newsType.text = postData?.result.items[indexPath.section].data.subsite.name
        let newsUUID = postData?.result.items[indexPath.section].data.subsite.avatar.data.uuid
        if let newsUuid = newsUUID {
            let newsURL = "https://leonardo.osnova.io/\(newsUuid)"
            print(newsURL)
            self.imageService.get(urlString: newsURL, completion: { im in
                DispatchQueue.main.async {
                    cell.newsImage.image = im
                }
            })
        }
        
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        cell.imagePost.addGestureRecognizer(tapImage)
        cell.imagePost.isUserInteractionEnabled = true
        
        cell.imagePost.translatesAutoresizingMaskIntoConstraints = true
        let uuid = findUUID(postData: postData, index: indexPath.section)
        if uuid == "" {
            cell.imagePost.frame.size.height = 0
        } else {
            cell.imagePost.frame.size.height = 350
            let url = "https://leonardo.osnova.io/\(uuid)"
            
            self.imageService.get(urlString: url, completion: { image in
                DispatchQueue.main.async {
                    cell.imagePost.image = image
                }
            })
            
        }
        return cell
    }
    
    func findUUID(postData: PostData?, index: Int) -> String {
        guard let blocks = postData?.result.items[index].data.blocks else { return "" }
        if blocks.count == 1 {
            let type = blocks[0].type
            if type == .media {
                guard let items = blocks[0].data.items else { return "" }
                switch items {
                case .itemsClass(_):
                    break
                case .unionArray(let array):
                    switch array.first! {
                    case .itemItem(let item):
                        return item.image.data.uuid
                    case .string(_):
                        break
                    }
                }
            }
        }
        if blocks.count > 1 {
            let type = blocks[1].type
            
            if type == .media {
                guard let items = blocks[1].data.items else { return "" }
                switch items {
                case .itemsClass(_):
                    break
                case .unionArray(let array):
                    
                    switch array.first! {
                    case .itemItem(let item):
                        return item.image.data.uuid
                    case .string(_):
                        break
                    }
                }
            }
        }
        return ""
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(20)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset
        if deltaOffset < CGFloat(-30) && deltaOffset > CGFloat(-100) && !loadingMore  {
            loadingMore = true
            
            guard let lastId = postData?.result.lastId, let lastSortingValue = postData?.result.lastSortingValue else { return }
            networkManager.request(lastId: lastId, lastSortingValue: lastSortingValue) { postData in
                guard let item = postData?.result.items else { return }
                self.postData?.result.items.append(contentsOf: item)
                self.postData?.result.lastId = postData?.result.lastId ?? 0
                self.postData?.result.lastSortingValue = postData?.result.lastSortingValue ?? 0
                self.tableView.reloadData()
                self.loadingMore = false
            }
        }
    }
}
