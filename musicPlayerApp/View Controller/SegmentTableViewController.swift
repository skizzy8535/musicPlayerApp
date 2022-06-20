//
//  SegmentTableViewController.swift
//  musicPlayerApp
//
//  Created by 林祐辰 on 2022/6/17.
//

import Foundation
import UIKit

class SegmentTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var showContent : [MusicModel] = localMusic
    var downloadContent : [MusicModel]?
    
    let segmentControl : UISegmentedControl = {
        let sc = UISegmentedControl(items:  ["本機檔案","線上音樂"])
        sc.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        sc.selectedSegmentIndex = 0
        return sc
    }()
    
    @objc func segmentChanged(){
        if segmentControl.selectedSegmentIndex == 0{
            showContent = localMusic
            tableView.reloadData()
        }else{
            guard let downloadContent = downloadContent else {
                return
            }
            showContent = downloadContent
            tableView.reloadData()
        }
    }
    

    let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50),
                                style: .plain)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        navigationItem.title = "音樂庫"
        view.addSubview(segmentControl)
        downloadMusic()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SongTableViewCell.self, forCellReuseIdentifier: "tableViewCell")
        
    
 //       view.addSubview(segmentControl)
        
        let stackView = UIStackView(arrangedSubviews: [
            segmentControl, tableView
        ])
        stackView.axis = .vertical
        stackView.spacing = 10
        
        
        view.addSubview(stackView)
        
        // 設定stackView的Auto Layout
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let topAnchorConstraint = NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal,
                                                     toItem: view.safeAreaLayoutGuide, attribute: .top,
                                                     multiplier: 1, constant: 0)
        
        let bottomAnchorConstraint = NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal,
                                                        toItem: view.safeAreaLayoutGuide, attribute: .bottom,
                                                        multiplier: 1, constant: 0)
        
        let leadingAnchorConstraint = NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal,
                                                        toItem: view.safeAreaLayoutGuide, attribute: .leading,
                                                        multiplier: 1, constant: 0)
        
        let trailingAnchorConstraint = NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal,
                                                        toItem: view.safeAreaLayoutGuide, attribute: .trailing,
                                                        multiplier: 1, constant: 0)
        var stackViewCons: [NSLayoutConstraint] = [topAnchorConstraint,bottomAnchorConstraint,leadingAnchorConstraint,trailingAnchorConstraint]
        
        NSLayoutConstraint.activate(stackViewCons)
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showContent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath) as! SongTableViewCell
        let cellContent = showContent[indexPath.row]
        cell.indexLabel.text = "\(indexPath.row + 1)."
        cell.nameLabel.text =  cellContent.trackName
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showPlayer", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPlayer"{
            if let musicPlayerVC = segue.destination as? MusicPlayerViewController,
               let row = tableView.indexPathForSelectedRow?.row{
                musicPlayerVC.songPlaying = showContent[row]
                musicPlayerVC.sendSongs = showContent
            }
        }
    }

    func downloadMusic(){     
        if let downloadLink = URL(string: "https://itunes.apple.com/search?term=持修&media=music&country=TW".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!){
            URLSession.shared.dataTask(with: downloadLink, completionHandler: { data, response, error in
                if let data = data,
                   let musicData = try? JSONDecoder().decode(MusicDownload.self ,from: data){
                    self.downloadContent = musicData.results
                }
            }).resume()
        }
        
    }
        
        
  }
