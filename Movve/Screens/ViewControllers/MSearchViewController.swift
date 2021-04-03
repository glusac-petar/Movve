//
//  MSearchViewController.swift
//  Movve
//
//  Created by Petar Glusac on 28.3.21..
//

import UIKit

class MSearchViewController: UIViewController {
    
    let searchBar = MSearchBar()
    let tableView = UITableView()
    
    private var query: String!
    private var data: [SearchResult] = []
    private var hasMore: Bool = true
    private var page: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTableView()
        layoutUI()
    }
    
    private func configureViewController() {
        view.backgroundColor = .mBackground
        navigationItem.titleView = searchBar
        searchBar.delegate = self
    }
    
    private func configureTableView() {
        tableView.register(MSearchTableViewCell.self, forCellReuseIdentifier: MSearchTableViewCell.reuseID)
        tableView.backgroundColor = .mBackground
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.removeExcessCells()
    }
    
    private func fetchData() {
        guard hasMore else { return }
        showLoadingScreen(backgroundAlpha: 0.8)
        
        NetworkManager.shared.multipleSearch(query: query, page: page) { [weak self] (data) in
            guard let self = self, let data = data else { return }
            
            if data.count > 0 {
                self.data.append(contentsOf: data)
                self.page += 1
                self.tableView.reloadDataOnMainThread()
            } else { self.hasMore = false }
            
            self.dismissLoadingScreen()
        }
    }
    
}

extension MSearchViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        dismissKeyboard(sender: searchBar)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        dismissKeyboard(sender: searchBar)
        
        query = searchBar.text!.replacingOccurrences(of: " ", with: "%20")
        hasMore = true
        data = []
        page = 1
        tableView.reloadDataOnMainThread()
        fetchData()
    }
    
}

extension MSearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { data.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MSearchTableViewCell.reuseID, for: indexPath) as! MSearchTableViewCell
        cell.set(data: data[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 105 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type: MediaType = data[indexPath.row].mediaType == "movie" ? .movie : .tvShow
        navigationController?.pushViewController(MDetailsViewController(type: type, id: data[indexPath.row].id), animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard hasMore else { return }
            page += 1
            fetchData()
        }
    }

}
