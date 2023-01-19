//
//  Constant.swift
//  ProjectManager
//
//  Created by GUNDY on 2023/01/12.
//

import CoreGraphics
import UIKit

enum Constant {

    enum Number {

        static let maxCount: Int = 99
        static let descriptionLimit: Int = 1000
    }

    enum Text {

        static let navigationTitle: String = "Project Manager"
        static let plusButton: String = "+"
        static let doneButton: String = "Done"
        static let editButton: String = "Edit"
        static let cancelButton: String = "Cancel"
        static let toDoTitle: String = "TODO"
        static let doingTitle: String = "DOING"
        static let doneTitle: String = "DONE"
        static let deleteSwipeTitle: String = "Delete"
        static let moveToToDo: String = "Move to TODO"
        static let moveToDoing: String = "Move to DOING"
        static let moveToDone: String = "Move to DONE"
        static let titlePlaceHolder: String = "Title"
        static let overCount: String = "\(Number.maxCount)+"
        static let invalidDeadlineMessage: String = "기한은 과거일 수 없습니다."
        static let invalidDescriptionMessage: String = "본문은 \(Number.descriptionLimit)자를 넘을 수 없습니다."
        static let cellTitleDefaultValue: String = "제목없음"
        static let cellDescriptionDefaultValue: String = "본문없음"
    }

    enum Style {

        static let stackViewSpacing: CGFloat = 8
        static let listCellSpacing: CGFloat = 8
        static let stackViewBottomInset: CGFloat = -28
        static let listTitleMargin: CGFloat = 8
        static let circleViewWidthPadding: CGFloat = 16
        static let circleViewHeightPadding: CGFloat = 4
        static let detailStackViewSpacing: CGFloat = 20
        static let detailStackViewTopAnchor: CGFloat = 4
        static let detailStackViewLeadingAnchor: CGFloat = 12
        static let detailStackViewBottomAnchor: CGFloat = -20
        static let detailStackViewTrailingAnchor: CGFloat = -12
        static let shadowOpacity: Float = 0.5
        static let shadowOffset: CGSize = CGSize(width: 0, height: 4)
        static let detailTextViewBoderWidth: CGFloat = 2
        
    }

    enum Color {

        static let mainBackground: UIColor = .systemBackground
        static let listViewSpacing: UIColor = .systemGray3
        static let listBackground: UIColor = .systemGray5
        static let circleBackground: CGColor = UIColor.black.cgColor
        static let circleText: UIColor = .white
        static let descriptionLabel: UIColor = .systemGray
        static let overDue: UIColor = .systemRed
        static let cellBackground: UIColor = .white
        static let detailTextViewBorder: CGColor = UIColor.red.cgColor
    }
}
