import UIKit

protocol TableViewDataSource: AnyObject {
    func numberOfRowInTableView(_ tableView: TableView) -> Int
    func tableView(_ tableView: TableView, textForRow row: Int) -> String
}

class TableView: UIScrollView {
    override var frame: CGRect {
        didSet {
            updateData()
        }
    }

    private static let TABLE_ROW_HEIGHT: CGFloat = 40
    private static let VISIBILITY_COEFFICIENT: CGFloat = 3

    private var activeTableCells = [TableCell]()
    private var totalNumberOfRows: Int = .zero
    private var totalYShift: CGFloat = .zero

    weak var dataSource: TableViewDataSource? {
        didSet {
            updateData()
        }
    }

    override var contentOffset: CGPoint {
        didSet {
            totalYShift += contentOffset.y - oldValue.y
            var numberOfCellsToTransfer: Int = Int(abs(totalYShift) / TableView.TABLE_ROW_HEIGHT)
            guard numberOfCellsToTransfer != .zero else {
                return
            }

            let isScrollDown = totalYShift > .zero
            let diffY = TableView.TABLE_ROW_HEIGHT * CGFloat(numberOfCellsToTransfer)
            totalYShift += isScrollDown ? -diffY : diffY
            if numberOfCellsToTransfer > activeTableCells.count {
                recountFrames()
                return
            }

            var index: Int
            if isScrollDown {
                index = (activeTableCells.last?.index ?? .zero) + 1
            }
            else {
                index = (activeTableCells.first?.index ?? .zero) - 1
            }
            while numberOfCellsToTransfer > .zero {
                let tableCell = isScrollDown ? activeTableCells.removeFirst() : activeTableCells.removeLast()

                updateCell(tableCell, withIndex: index)

                if isScrollDown {
                    activeTableCells.append(tableCell)
                    index += 1
                }
                else {
                    activeTableCells.insert(tableCell, at: .zero)
                    index -= 1
                }

                numberOfCellsToTransfer -= 1
            }
        }
    }

    private func recountFrames() {
        var index: Int = Int(contentOffset.y / TableView.TABLE_ROW_HEIGHT) - activeTableCells.count / 2
        for tableCell in activeTableCells {
            updateCell(tableCell, withIndex: index)
            index += 1
        }
    }

    private func updateCell(_ cell: TableCell, withIndex index: Int) {
        cell.index = index
        cell.frame.origin.y = CGFloat(index) * TableView.TABLE_ROW_HEIGHT
        cell.frame = cell.frame.integral
        cell.update(text: dataSource?.tableView(self, textForRow: index) ?? "")
        cell.isHidden = index < .zero || index > totalNumberOfRows - 1
    }

    private func updateData() {
        activeTableCells.forEach({ $0.removeFromSuperview() })
        activeTableCells.removeAll()
        if let dataSource = dataSource {
            let numberOfActiveRows = Int(frame.height * TableView.VISIBILITY_COEFFICIENT / TableView.TABLE_ROW_HEIGHT)
            guard numberOfActiveRows > .zero else {
                return
            }

            totalNumberOfRows = dataSource.numberOfRowInTableView(self)
            contentSize = CGSize(width: frame.width,
                                 height: TableView.TABLE_ROW_HEIGHT * CGFloat(totalNumberOfRows))

            let tableCellFrame = CGRect(origin: .zero, size: CGSize(width: frame.width, height: TableView.TABLE_ROW_HEIGHT))
            for _ in 0...numberOfActiveRows {
                let tableCell = TableCell(frame: tableCellFrame)
                addSubview(tableCell)
                activeTableCells.append(tableCell)
            }
            recountFrames()
        } else {
            contentSize = .zero
        }
    }

}
