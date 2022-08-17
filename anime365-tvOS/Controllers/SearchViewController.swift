//
//  SearchViewController.swift
//  anime365-tvOS
//
//  Created by Илья Козырев on 16.08.2022.
//

import UIKit

class SearchViewController: UIViewController {

    private let searchController: UISearchController
    private let searchContainerViewController: UISearchContainerViewController
    private let searchResultController: CatalogViewController

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {

        self.searchResultController = AllControlles.getCatalogViewController()
        self.searchController = UISearchController(searchResultsController: searchResultController)
        self.searchContainerViewController = UISearchContainerViewController(searchController: searchController)

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.searchResultController.delegate = self
    }

    required init?(coder: NSCoder) {
        
        self.searchResultController = AllControlles.getCatalogViewController()
        self.searchController = UISearchController(searchResultsController: searchResultController)
        self.searchContainerViewController = UISearchContainerViewController(searchController: searchController)

        super.init(coder: coder)
        self.searchResultController.delegate = self
    }
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChild(searchContainerViewController)
        searchContainerViewController.view.frame = view.bounds
        view.addSubview(searchContainerViewController.view)
        searchContainerViewController.didMove(toParent: self)
        searchController.searchBar.delegate = self
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchString = searchController.searchBar.text else { return }
        searchResultController.loadData(searchString: searchString)
    }
    
}

extension SearchViewController: CatalogViewControllerDelegate {
    func showChildView(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
}
