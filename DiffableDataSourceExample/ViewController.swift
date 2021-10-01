//
//  ViewController.swift
//  DiffableDataSourceExample
//
//  Created by Mikalai Zmachynski on 23/09/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: DiffableDataSource<Section>!
    
    enum Section {
        case simple
    }
    struct Item: DiffableItem {
        let id: Int
        var title: String
        var onSelect: (() -> ())?
        
        static func == (lhs: Item, rhs: Item) -> Bool {
            return lhs.id == rhs.id && lhs.title == rhs.title
        }
    }
    
    var data: [SectionModel<Section>] = [
        SectionModel(model: .simple, items: [
            AnyDiffableItem(Item(id: 1, title: "first", onSelect: { print("first") })),
            AnyDiffableItem(Item(id: 2, title: "second")),
            AnyDiffableItem(Item(id: 3, title: "third")),
            AnyDiffableItem(Item(id: 4, title: "fourth")),
            AnyDiffableItem(Item(id: 5, title: "fifth")),
            AnyDiffableItem(Item(id: 6, title: "sixth")),
            AnyDiffableItem(Item(id: 7, title: "seventh")),
            AnyDiffableItem(Item(id: 8, title: "eightth")),
            AnyDiffableItem(Item(id: 9, title: "nineth")),
            AnyDiffableItem(Item(id: 10, title: "tenth"))
        ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ItemCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 50
        tableView.delegate = self
        dataSource = DiffableDataSource<Section>(tableView: tableView)
    }

    var counter = 0
    
    @IBAction func shuffle(_ sender: Any) {
//        data[0].items.shuffle()
//        dataSource.update(with: data)
        if counter == 0 {
            counter += 1
            dataSource.update(with: data)
        } else {
            counter += 1
            var data = self.data
            data[0].items[2] = AnyDiffableItem(Item(id: 3, title: "third reloaded"))
            dataSource.update(with: data)
        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.item(for: indexPath)?.base as? Item else {
            return
        }
        print("select \(item.title)")
        item.onSelect?()
    }
}

//================================================================

class DiffableDataSource<Section: Hashable>: UITableViewDiffableDataSource<Section, String> {
    private let dataContainer: DiffableDataSourceDataContainer
    
    init(tableView: UITableView) {
        let dataContainer = DiffableDataSourceDataContainer()
        self.dataContainer = dataContainer
        super.init(tableView: tableView, cellProvider: { [dataContainer] tableView, indexPath, id in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemCell
            let item = dataContainer.item(for: id)!.base as! ViewController.Item
            cell.label.text = item.title
            return cell
        })
    }
    
    public func update(with list: [SectionModel<Section>], animate: Bool = true) {
        let currentSnapshot = snapshot()
        var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
        let newDataContainer = DiffableDataSourceDataContainer()
        list.forEach { data in
            snapshot.appendSections([data.model])
            data.items.forEach { item in
                snapshot.appendItems([item.id], toSection: data.model)
                newDataContainer.add(item: item)
            }
        }
        let currentItems = Set(currentSnapshot.itemIdentifiers)
        let items = Set(snapshot.itemIdentifiers)
        let commonItems = currentItems.intersection(items).filter { id in
            return newDataContainer.item(for: id) != dataContainer.item(for: id)
        }
        snapshot.reloadItems(Array(commonItems))
        dataContainer.replace(with: newDataContainer.data)
        apply(snapshot, animatingDifferences: animate)
    }
    
    public func item(for indexPath: IndexPath) -> AnyDiffableItem? {
        guard let id = itemIdentifier(for: indexPath) else {
            return nil
        }
        return dataContainer.item(for: id)
    }
}

class DiffableDataSourceDataContainer {
    public private(set) var data: [String: AnyDiffableItem] = [:]
    
    public func item(for id: String) -> AnyDiffableItem? {
        return data[id]
    }
    
    public func add(item: AnyDiffableItem) {
        data[item.id] = item
    }
    
    public func replace(with data: [String: AnyDiffableItem]) {
        self.data = data
    }
}

//================================================================

public protocol DiffableItem: Equatable, Identifiable {}

public struct SectionModel<Section> where Section: Hashable {
    public let model: Section
    public var items: [AnyDiffableItem]
}

public struct AnyDiffableItem: DiffableItem {
    // MARK: - Variables
    let equatable: AnyEquatable
    public let id: String
    
    public var base: Any {
        equatable.base
    }
    
    // MARK: - Methods
    init<H>(_ base: H) where H: DiffableItem {
        equatable = .init(base)
        id = "\(H.self)_\(base.id)"
    }
}

extension AnyDiffableItem: Equatable {
    public static func == (lhs: AnyDiffableItem, rhs: AnyDiffableItem) -> Bool {
        lhs.equatable == rhs.equatable
    }
}

