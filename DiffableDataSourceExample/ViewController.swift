//
//  ViewController.swift
//  DiffableDataSourceExample
//
//  Created by Mikalai Zmachynski on 23/09/2021.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: DiffableDataSource<Section, Item>!
    
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
    
    var data: [SectionData<Section, Item>] = [
        SectionData(section: .simple, items: [
            Item(id: 1, title: "first", onSelect: { print("first") }),
            Item(id: 2, title: "second"),
            Item(id: 3, title: "third"),
            Item(id: 4, title: "fourth"),
            Item(id: 5, title: "fifth"),
            Item(id: 6, title: "sixth"),
            Item(id: 7, title: "seventh"),
            Item(id: 8, title: "eightth"),
            Item(id: 9, title: "nineth"),
            Item(id: 10, title: "tenth")
        ])
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ItemCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 50
        tableView.delegate = self
        dataSource = DiffableDataSource(tableView: tableView)
    }

    var counter = 0
    
    @IBAction func shuffle(_ sender: Any) {
        data[0].items.shuffle()
        dataSource.update(with: data)
//        if counter == 0 {
//            counter += 1
//            dataSource.update(with: data)
//        } else {
//            counter += 1
//            var data = self.data
//            data[0].items[2] = Item(id: 3, title: "third reloaded")
//            dataSource.update(with: data)
//        }
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let item = dataSource.item(for: indexPath) else {
            return
        }
        print("select \(item.title)")
        item.onSelect?()
    }
}

//================================================================

protocol DiffableItem: Equatable {
    associatedtype ID: Hashable
    var id: ID { get }
}

struct SectionData<Section: Hashable, Item: DiffableItem> {
    let section: Section
    var items: [Item]
}

class DiffableDataSource<Section: Hashable, Item: DiffableItem>: UITableViewDiffableDataSource<Section, Item.ID> {
    private let dataContainer: DiffableDataSourceDataContainer<Item>
    
    init(tableView: UITableView) {
        let dataContainer = DiffableDataSourceDataContainer<Item>()
        self.dataContainer = dataContainer
        super.init(tableView: tableView, cellProvider: { [dataContainer] tableView, indexPath, id in
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ItemCell
            let item = dataContainer.item(for: id) as! ViewController.Item
            cell.label.text = item.title
            return cell
        })
    }
    
    public func update(with list: [SectionData<Section, Item>], animate: Bool = true) {
        let currentSnapshot = snapshot()
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item.ID>()
        let newDataContainer = DiffableDataSourceDataContainer<Item>()
        list.forEach { data in
            snapshot.appendSections([data.section])
            data.items.forEach { item in
                snapshot.appendItems([item.id], toSection: data.section)
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
