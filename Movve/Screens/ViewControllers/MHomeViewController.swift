//
//  MHomeViewController.swift
//  Movve
//
//  Created by Petar Glusac on 23.3.21..
//

import UIKit

class MHomeViewController: UIViewController {
    
    let titleLabel = MTitleLabel(textAlignment: .center, font: UIFont.systemFont(ofSize: 30, weight: .black))
    let tableView = UITableView(frame: .zero, style: .grouped)
    
    private var popular: BasicResult?
    private var upcomingMovies: [BasicResult] = []
    private var popularMovies: [BasicResult] = []
    private var popularTVShows: [BasicResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTitleLabel()
        configureTableView()
        layoutUI()
        fetchData()
    }

    private func configureViewController() {
        view.backgroundColor = .mBackground
        navigationItem.titleView = titleLabel
    }
    
    private func configureTitleLabel() {
        let firstPart = NSMutableAttributedString(string: "Mov", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        let secondPart = NSAttributedString(string: "ve", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])
        firstPart.append(secondPart)
        titleLabel.attributedText = firstPart
    }
    
    private func configureTableView() {
        tableView.register(MHomeHeaderTableViewCell.self, forCellReuseIdentifier: MHomeHeaderTableViewCell.reuseID)
        tableView.register(MPosterTableViewCell.self, forCellReuseIdentifier: MPosterTableViewCell.reuseID)
        tableView.register(MTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: MTableViewHeaderFooterView.reuseID)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func pushDetailsViewController(type: MediaType, id: Int) {
        let detailsVC = MDetailsViewController(type: type, id: id)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    private func fetchData() {
        showLoadingScreen()
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        fetchPopular { dispatchGroup.leave() }
        dispatchGroup.enter()
        fetchUpcoming { dispatchGroup.leave() }
        dispatchGroup.enter()
        fetchPopularMovies { dispatchGroup.leave() }
        dispatchGroup.enter()
        fetchPopularTVShows { dispatchGroup.leave() }
        
        dispatchGroup.notify(queue: .main) {
            self.tableView.reloadData()
            self.dismissLoadingScreen()
        }
    }
    
    private func fetchPopular(completed: @escaping () -> Void) {
        NetworkManager.shared.getPopular { [weak self] (data) in
            if let self = self, let data = data {
                self.popular = data
                completed()
            }
        }
    }
    
    private func fetchUpcoming(completed: @escaping () -> Void) {
        NetworkManager.shared.getUpcoming { [weak self] (data) in
            if let self = self, let data = data {
                self.upcomingMovies = data
                completed()
            }
        }
    }
    
    private func fetchPopularMovies(completed: @escaping () -> Void) {
        NetworkManager.shared.getPopular(type: .movie) { [weak self] (data) in
            if let self = self, let data = data {
                self.popularMovies = data
                completed()
            }
        }
    }
    
    private func fetchPopularTVShows(completed: @escaping () -> Void) {
        NetworkManager.shared.getPopular(type: .tvShow) { [weak self] (data) in
            if let self = self, let data = data {
                self.popularTVShows = data
                completed()
            }
        }
    }
    
}

extension MHomeViewController: MPosterTableViewCellDelegate {
    
    func didSelectItemAt(indexPath: IndexPath) {
        if indexPath.section == 1 { pushDetailsViewController(type: .movie, id: upcomingMovies[indexPath.item].id) }
        else if indexPath.section == 2 { pushDetailsViewController(type: .movie, id: popularMovies[indexPath.item].id) }
        else { pushDetailsViewController(type: .tvShow, id: popularTVShows[indexPath.item].id) }
    }
    
}

extension MHomeViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int { return 4 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MHomeHeaderTableViewCell.reuseID, for: indexPath) as! MHomeHeaderTableViewCell
            if let data = popular { cell.set(data: data) }
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MPosterTableViewCell.reuseID, for: indexPath) as! MPosterTableViewCell
            if indexPath.section == 1 { cell.set(data: upcomingMovies, section: 1, delegate: self) }
            else if indexPath.section == 2 { cell.set(data: popularMovies, section: 2, delegate: self) }
            else if indexPath.section == 3 { cell.set(data: popularTVShows, section: 3, delegate: self) }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return indexPath.section == 0 ? 180 : 160 }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return section == 0 ? 0 : 20 }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: MTableViewHeaderFooterView.reuseID) as! MTableViewHeaderFooterView
        if section == 1 { view.set(title: "Coming Soon") }
        else if section == 2 { view.set(title: "Popular Movies") }
        else if section == 3 { view.set(title: "Popular TV Shows") }
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 { pushDetailsViewController(type: .movie, id: popular!.id) }
    }
    
}
