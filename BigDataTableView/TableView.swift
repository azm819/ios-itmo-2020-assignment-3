import UIKit

protocol TableViewDataSource: AnyObject {
    func numberOfRowInTableView(_ tableView: TableView) -> Int
    func tableView(_ tableView: TableView, textForRow row: Int) -> String
}

class TableView: UIScrollView {
    weak var dataSource: TableViewDataSource?
}
