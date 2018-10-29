//
//  CommentView.swift
//  XTrip
//
//  Created by Khoa Bui on 12/18/17.
//  Copyright © 2017 Hoang Cap. All rights reserved.
//

import UIKit

protocol CommentViewDelegate: class {
    func didTapCommentButton(commentView: CommentView, withComment comment: String)
}

class CommentView: UIView {

    @IBOutlet weak var commentTextField: UITextField!
    weak var delegate: CommentViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func commentButtonTapped(_ sender: UIButton) {
        guard let commentText = self.commentTextField.text, !commentText.isBlank else { return }
        self.delegate?.didTapCommentButton(commentView: self, withComment: commentText)
    }
}
