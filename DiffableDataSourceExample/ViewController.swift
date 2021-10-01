//
//  ViewController.swift
//  DiffableDataSourceExample
//
//  Created by Mikalai Zmachynski on 23/09/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: DiffableDataSource<Section, AnyDiffableItem>!
    
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
    
    var data: [SectionModel<Section, AnyDiffableItem>] = [
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
        dataSource = DiffableDataSource<Section, AnyDiffableItem>(tableView: tableView)
    }

    var counter = 0
    
    @IBAction func shuffle(_ sender: Any) {
        // reload all
//        data[0].items.shuffle()
//        dataSource.update(with: data)
        
        // raload one
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

class DiffableDataSource<Section: Hashable, Item: DiffableItem>: UITableViewDiffableDataSource<Section, Item.ID> {
    private let dataContainer: DiffableDataSourceDataContainer<Item>
    
    init(tableView: UITableView) {
        let dataContainer = DiffableDataSourceDataContainer<Item>()
        self.dataContainer = dataContainer
        super.init(tableView: tableView, cellProvider: { [dataContainer] tableView, indexPath, id in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemCell
            let item = (dataContainer.item(for: id) as! AnyDiffableItem).base as! ViewController.Item
            cell.label.text = item.title
            return cell
        })
    }
    
    public func update(with list: [SectionModel<Section, Item>], animate: Bool = true) {
        let currentSnapshot = snapshot()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item.ID>()
        let newDataContainer = DiffableDataSourceDataContainer<Item>()
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
    
    public func item(for indexPath: IndexPath) -> Item? {
        guard let id = itemIdentifier(for: indexPath) else {
            return nil
        }
        return dataContainer.item(for: id)
    }
}

class DiffableDataSourceDataContainer<Item: DiffableItem> {
    public private(set) var data: [Item.ID: Item] = [:]
    
    public func item(for id: Item.ID) -> Item? {
        return data[id]
    }
    
    public func add(item: Item) {
        data[item.id] = item
    }
    
    public func replace(with data: [Item.ID: Item]) {
        self.data = data
    }
}
//================================================================

public protocol DiffableItem: Equatable, Identifiable {}

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
    
    public static func == (lhs: AnyDiffableItem, rhs: AnyDiffableItem) -> Bool {
        lhs.equatable == rhs.equatable
    }
}

//================================================================

public struct SectionModel<Section: Hashable, Item: DiffableItem> {
    public let model: Section
    public var items: [Item]
}
