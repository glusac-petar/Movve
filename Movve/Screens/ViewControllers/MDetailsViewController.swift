//
//  MDetailsViewController.swift
//  Movve
//
//  Created by Petar Glusac on 25.3.21..
//

import UIKit
import youtube_ios_player_helper

class MDetailsViewController: UIViewController {
    
    let scrollView = MVerticalScrollView()
    let posterImageView = MImageView(placeholder: UIImage(named: "poster-placeholder"))
    let backdropImageView = MImageView()
    let playButton = MPlayButton(isHidden: true)
    let videoPlayer = YTPlayerView()
    let titleLabel = MTitleLabel(textAlignment: .center, font: UIFont.boldSystemFont(ofSize: 30))
    let infoLabel = MBodyLabel(textAlignment: .center, fontSize: 15)
    let overviewLabel = MBodyLabel(textAlignment: .justified, fontSize: 15)
    let ratingView = MRatingStackView()
    let tableView = UITableView(frame: .zero, style: .grouped)
    var tableViewHeight: NSLayoutConstraint!
    
    private var type: MediaType!
    private var id: Int!
    private var detailedResult: Any! { didSet {configureUIElements()}}
    private var trailer: VideoResult? { didSet {configurePlayButton()}}
    private var cast: [CastResult] = []
    private var recommendations: [BasicResult] = []
    
    init(type: MediaType, id: Int) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        self.id = id
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewController()
        configureTableView()
        layoutUI()
        fetchData(loadingScreenAlpha: 1)
    }
    
    private func configureViewController() {
        view.backgroundColor = .mBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(favoriteButtonDidTap))
    }
    
    @objc private func favoriteButtonDidTap() {
        let favorite: Favorite
        if type == .movie {
            let data = detailedResult as! DetailedMovieResult
            favorite = Favorite(type: .movie, id: data.id, title: data.title, posterPath: data.posterPath!)
        }
        else {
            let data = detailedResult as! DetailedShowResult
            favorite = Favorite(type: .tvShow, id: data.id, title: data.name, posterPath: data.posterPath!)
        }
        PersistenceManager.updateWith(favorite: favorite, actionType: .add) { [weak self] (error) in
            guard let self = self else { return }
            
            guard let error = error else {
                self.presentAlert(title: "Success!", message: "\(favorite.title) has been successfully added to your favorites list 🎉.")
                return
            }
            self.presentAlert(title: "Woops!", message: error.rawValue)
        }
    }
    
    private func configureTableView() {
        tableView.register(MCastTableViewCell.self, forCellReuseIdentifier: MCastTableViewCell.reuseID)
        tableView.register(MPosterTableViewCell.self, forCellReuseIdentifier: MPosterTableViewCell.reuseID)
        tableView.register(MTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: MTableViewHeaderFooterView.reuseID)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func configureUIElements() {
        if type == .movie {
            let data = detailedResult as! DetailedMovieResult
            backdropImageView.downloadImage(from: data.backdropPath!)
            backdropImageView.alpha = 0.2
            posterImageView.downloadImage(from: data.posterPath!)
            titleLabel.text = data.title
            configureInfoLabel()
            ratingView.set(rating: data.voteAverage)
            overviewLabel.text = data.overview
        }
        else {
            let data = detailedResult as! DetailedShowResult
            backdropImageView.downloadImage(from: data.backdropPath!)
            backdropImageView.alpha = 0.2
            posterImageView.downloadImage(from: data.posterPath!)
            titleLabel.text = data.name
            configureInfoLabel()
            ratingView.set(rating: data.voteAverage)
            overviewLabel.text = data.overview
        }
    }
    
    private func configureInfoLabel() {
        if type == .movie {
            let data = detailedResult as! DetailedMovieResult
            let dateString = data.releaseDate.convertToDateFormat()
            let genresString = data.genres.prefix(2).map { $0.name }.joined(separator: ", ")
            let runtimeString = data.runtime?.minutesToHoursAndMinutes()
            
            if let runtimeString = runtimeString { infoLabel.text = [dateString, genresString, runtimeString].filter { !$0.isEmpty }.joined(separator: " • ")  }
            else { infoLabel.text = [dateString, genresString].filter { !$0.isEmpty }.joined(separator: " • ") }
        }
        else {
            let data = detailedResult as! DetailedShowResult
            let dateString = data.firstAirDate.convertToDateFormat()
            let genresString = data.genres.prefix(2).map { $0.name }.joined(separator: ", ")
            let seasonsString = "\(data.numberOfSeasons)S"
            
            infoLabel.text = [dateString, genresString, seasonsString].filter { !$0.isEmpty }.joined(separator: " • ")
        }
    }
    
    private func configurePlayButton() {
        playButton.isHidden = trailer == nil ? true : false
        playButton.addTarget(self, action: #selector(playTrailer), for: .touchUpInside)
    }
    
    @objc private func playTrailer() {
        videoPlayer.delegate = self
        videoPlayer.load(withVideoId: trailer!.key)
        videoPlayer.frame = CGRect(x: view.frame.width/2, y: view.frame.height, width: 1, height: 1)
        playButton.disable()
    }

    private func fetchData(loadingScreenAlpha: CGFloat) {
        navigationItem.rightBarButtonItem?.isEnabled = false
        showLoadingScreen(backgroundAlpha: loadingScreenAlpha)
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        fetchDetails { dispatchGroup.leave() }
        dispatchGroup.enter()
        fetchVideos { dispatchGroup.leave() }
        dispatchGroup.enter()
        fetchCast() { dispatchGroup.leave() }
        dispatchGroup.enter()
        fetchRecommendations { dispatchGroup.leave() }
        
        dispatchGroup.notify(queue: .main) {
            self.dismissLoadingScreen()
            self.tableView.reloadData()
            self.tableViewHeight.constant = (self.cast.count > 0 ? 130 : 0) + (self.recommendations.count > 0 ? 180 : 0) + 35
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    private func fetchDetails(completed: @escaping () -> Void) {
        if type == .movie {
            NetworkManager.shared.getMovieDetails(id: id) { [weak self] (data) in
                if let self = self, let data = data {
                    self.detailedResult = data
                    completed()
                }
            }
        }
        else {
            NetworkManager.shared.getTVShowDetails(id: id) { [weak self] (data) in
                if let self = self, let data = data {
                    self.detailedResult = data
                    completed()
                }
            }
        }
    }
    
    private func fetchVideos(completed: @escaping () -> Void) {
        NetworkManager.shared.getTrailer(type: type, id: id) { [weak self] (data) in
            guard let self = self else { return }
            self.trailer = data
            completed()
        }
    }
    
    private func fetchCast(completed: @escaping () -> Void) {
        NetworkManager.shared.getCast(type: type, id: id) { [weak self] (data) in
            if let self = self, let data = data {
                self.cast = data
                completed()
            }
        }
    }
    
    private func fetchRecommendations(completed: @escaping () -> Void) {
        NetworkManager.shared.getRecommendations(type: type, id: id) { [weak self] (data) in
            if let self = self, let data = data {
                self.recommendations = data
                completed()
            }
        }
    }
    
}

extension MDetailsViewController: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { self.playButton.enable() }
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        if state == .ended { playerView.removeFromSuperview() }
    }
    
}

extension MDetailsViewController: MPosterTableViewCellDelegate {
    
    func didSelectItemAt(indexPath: IndexPath) {
        id = recommendations[indexPath.item].id
        fetchData(loadingScreenAlpha: 0.8)
        playButton.enable()
        videoPlayer.removeWebView()
    }
    
}

extension MDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: MCastTableViewCell.reuseID, for: indexPath) as! MCastTableViewCell
            cell.set(data: cast)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: MPosterTableViewCell.reuseID, for: indexPath) as! MPosterTableViewCell
            cell.set(data: recommendations, section: 1, delegate: self)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && cast.count > 0 { return 100 }
        else if indexPath.section == 1 && recommendations.count > 0 { return 160 }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && cast.count > 0 { return 30 }
        else if section == 1 && recommendations.count > 0 { return 25 }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: MTableViewHeaderFooterView.reuseID) as! MTableViewHeaderFooterView
        if section == 0 { view.set(title: "Cast") }
        else { view.set(title: "Recommendations")}
        return view
    }
    
}
