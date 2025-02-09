//
//  ProjectManager - ListViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

final class ListViewController: UIViewController {
    
    var viewModel: ListViewModel?
    private lazy var projectListHeaderStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [toDoHeaderView, doingHeaderView, doneHeaderView])
        stackView.backgroundColor = .systemGray5
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    private lazy var projectListStackView: UIStackView  = {
        let stackView = UIStackView(arrangedSubviews: [projectListHeaderStackView, projectCollectionView])
        stackView.backgroundColor = .systemGray3
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var projectCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.delegate = self
        collectionView.register(ListCollectionViewCell.self,
                                forCellWithReuseIdentifier: ListCollectionViewCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
    }()
    
    private var dataSource: UICollectionViewDiffableDataSource<State, Project>?
    
    private let toDoHeaderView = ListHeaderView(title: Text.toDoTitle,
                                                padding: 4,
                                                frame: .zero)
    private let doingHeaderView = ListHeaderView(title: Text.doingTitle,
                                                 padding: 4,
                                                 frame: .zero)
    private let doneHeaderView = ListHeaderView(title: Text.doneTitle,
                                                padding: 4,
                                                frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUIComponent()
        configureHandler()
        configureLongPressGestureRecognizer()
        configureDataSource()
    }
    
    private func configureUIComponent() {
        configureNavigationBar()
        configureViewHierarchy()
        configureLayoutConstraint()
        configureHeaderView()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = Text.navigationTitle
        navigationItem.rightBarButtonItem = addProjectButton()
    }
    
    private func configureViewHierarchy() {
        view.addSubview(projectListStackView)
    }
    
    private func configureLayoutConstraint() {
        NSLayoutConstraint.activate([
            projectListStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            projectListStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            projectListStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                         constant: -28),
            projectListStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func presentDetailView(viewModel: DetailViewModel?) {
        let projectViewController = DetailViewController()
        projectViewController.viewModel = viewModel
        projectViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: projectViewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
    }
    
    private func configureHeaderView() {
        toDoHeaderView.setCount(number: viewModel?.fetchCount(of: .toDo))
        doingHeaderView.setCount(number: viewModel?.fetchCount(of: .doing))
        doneHeaderView.setCount(number: viewModel?.fetchCount(of: .done))
    }
    
    private func configureHandler() {
        viewModel?.bindToDoList() { [weak self] list in
            self?.toDoHeaderView.setCount(number: list.count)
        }
        
        viewModel?.bindDoingList() { [weak self] list in
            self?.doingHeaderView.setCount(number: list.count)
        }
        
        viewModel?.bindDoneList() { [weak self] list in
            self?.doneHeaderView.setCount(number: list.count)
        }
    }
    
    private func configureLongPressGestureRecognizer() {
        let gestureRecognizer = UILongPressGestureRecognizer(target: self,
                                                             action: #selector(tappedLongPress))
        gestureRecognizer.minimumPressDuration = 0.5
        gestureRecognizer.delegate = self
        gestureRecognizer.delaysTouchesBegan = true
        projectCollectionView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func addPlanAction() -> UIAction {
        let action = UIAction { [weak self] _ in
            let detailViewModel = self?.viewModel?.makeDetailViewModel()
            self?.presentDetailView(viewModel: detailViewModel)
        }
        
        return action
    }
    
    private func addProjectButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(systemItem: .add,
                                     primaryAction: addPlanAction())
        
        return button
    }
    
    private func fetchProject(for indexPath: IndexPath) -> Project? {
        guard let list = fatchList(for: indexPath.section) else {
            return nil
        }
        
        return list[indexPath.item]
    }
    
    private func fatchList(for section: Int) -> [Project]? {
        switch section {
        case 0:
            return viewModel?.fetchList(of: .toDo)
        case 1:
            return viewModel?.fetchList(of: .doing)
        case 2:
            return viewModel?.fetchList(of: .done)
        default:
            return nil
        }
    }
    
    func createLayout() -> UICollectionViewLayout {
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(sectionProvider: {
            (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
            
            let containerGroupFractionalWidth = CGFloat(1.0/3.0)
            let containerGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(containerGroupFractionalWidth),
                                                   heightDimension: .estimated(50)),
                subitems: [item])
            let section = NSCollectionLayoutSection(group: containerGroup)
            section.orthogonalScrollingBehavior = .continuous
            
            return section
            
        }, configuration: config)
        return layout
    }
    
    func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<ListCollectionViewCell, Project> { (cell, indexPath, project) in
            guard let state = State(rawValue: indexPath.section),
                  let isOverdue = self.viewModel?.isOverdue(state: state, index: indexPath.item),
                  let texts = self.viewModel?.fetchTexts(state: state, index: indexPath.item) else {
                return
            }
            switch state {
            case .done:
                cell.configure(title: texts.title,
                               description: texts.description,
                               deadline: texts.deadline)
            default:
                cell.configure(title: texts.title,
                               description: texts.description,
                               deadline: texts.deadline,
                               isOverdue: isOverdue)
            }
        }
        dataSource = UICollectionViewDiffableDataSource<State, Project>(collectionView: projectCollectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, project: Project) -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: project)
        }
        
        configureSnapshot()
    }
    
    private func configureSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<State, Project>()
        snapshot.appendSections([.toDo, .doing, .done])
        snapshot.appendItems(viewModel?.fetchList(of: .toDo) ?? [],
                             toSection: .toDo)
        snapshot.appendItems(viewModel?.fetchList(of: .doing) ?? [],
                             toSection: .doing)
        snapshot.appendItems(viewModel?.fetchList(of: .done) ?? [],
                             toSection: .done)
        dataSource?.apply(snapshot)
    }
}

extension ListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let state = State(rawValue: indexPath.section),
              let list = viewModel?.fetchList(of: state) else {
            return
        }
        let project = list[indexPath.item]
        let detailViewModel = viewModel?.makeDetailViewModel(project: project)
        presentDetailView(viewModel: detailViewModel)
    }
}

extension ListViewController: UIGestureRecognizerDelegate {
    
    @objc func tappedLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
        guard let collectionView = gestureRecognizer.view as? UICollectionView else {
            return
        }
        
        let tappedPoint = gestureRecognizer.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: tappedPoint) else {
            return
        }
        
        switch gestureRecognizer.state {
        case .began:
            presentPopoverMenu(collectionView: collectionView, indexPath: indexPath)
        default:
            return
        }
    }
    
    private func presentPopoverMenu(collectionView: UICollectionView, indexPath: IndexPath) {
        guard let tappedCell = collectionView.cellForItem(at: indexPath),
              let state = State(rawValue: indexPath.section),
              let project = viewModel?.fetchList(of: state)[indexPath.item] else {
            return
        }
        
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        
        let popoverController = alertController.popoverPresentationController
        popoverController?.sourceView = tappedCell
        popoverController?.sourceRect = tappedCell.bounds
        makeMoveActions(project: project).forEach {
            alertController.addAction($0)
        }
        
        present(alertController, animated: true)
    }
    
    private func makeMoveActions(project: Project) -> [UIAlertAction] {
        switch project.state {
        case .toDo:
            return [makeMoveAction(project: project, to: .doing),
                    makeMoveAction(project: project, to: .done),
                    makeDeleteAction(project: project)]
        case .doing:
            return [makeMoveAction(project: project, to: .toDo),
                    makeMoveAction(project: project, to: .done),
                    makeDeleteAction(project: project)]
        case .done:
            return [makeMoveAction(project: project, to: .toDo),
                    makeMoveAction(project: project, to: .doing),
                    makeDeleteAction(project: project)]
        }
    }
    
    private func makeMoveAction(project: Project, to state: State) -> UIAlertAction {
        var project = project
        let title: String
        switch state {
        case .toDo:
            project.state = .toDo
            title = Text.moveToToDo
        case .doing:
            project.state = .doing
            title = Text.moveToDoing
        case .done:
            project.state = .done
            title = Text.moveToDone
        }
        
        return UIAlertAction(title: title, style: .default) { [weak self] _ in
            self?.viewModel?.moveProject(identifier: project.identifier, to: state)
            self?.configureSnapshot()
        }
    }
    
    private func makeDeleteAction(project: Project) -> UIAlertAction {
        return UIAlertAction(title: Text.deleteActionTitle, style: .destructive) { [weak self] _ in
            self?.viewModel?.removeProject(identifier: project.identifier)
            self?.configureSnapshot()
        }
    }
}

extension ListViewController: DetailProjectDelegate {
    
    func detailProject(willSave: (title: String, description: String, deadline: Date, identifier: UUID?)) {
        viewModel?.saveProject(title: willSave.title,
                               description: willSave.description,
                               deadline: willSave.deadline,
                               identifier: willSave.identifier)
        configureSnapshot()
    }
}

extension ListViewController {
    
    enum Text {
        
        static let navigationTitle: String = "Project Manager"
        static let toDoTitle: String = "TODO"
        static let doingTitle: String = "DOING"
        static let doneTitle: String = "DONE"
        static let moveToToDo: String = "Move to TODO"
        static let moveToDoing: String = "Move to DOING"
        static let moveToDone: String = "Move to DONE"
        static let deleteActionTitle: String = "Delete"
    }
}
