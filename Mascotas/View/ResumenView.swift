//
//  DetailView.swift
//  Mascotas
//
//  Created by Ángel González on 26/04/25.
//

import UIKit

class ResumenView: UIView {
    let tv = UITextView()
    
    override func draw(_ rect: CGRect) {
        self.addSubview(tv)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.widthAnchor.constraint(equalToConstant:250).isActive = true
        tv.heightAnchor.constraint(equalToConstant:450).isActive = true
        tv.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        tv.topAnchor.constraint(equalTo:self.topAnchor, constant: 15).isActive = true
        tv.backgroundColor = .systemCyan
        tv.isEditable = false
        tv.font = UIFont.systemFont(ofSize: 22)
    }

}
