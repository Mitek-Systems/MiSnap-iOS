//
//  NFCInputsHeaderView.swift
//  MiSnapSampleApp
//
//  Copyright © 2026 Mitek Systems Inc. All rights reserved.
//

import UIKit

final class NFCInputsHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "NFCInputsHeaderView"
    static let elementKind = "NFCInputsHeaderViewKind"

    var onDocumentNumberChanged: ((String) -> Void)?
    var onDateOfBirthChanged: ((String) -> Void)?
    var onDateOfExpiryChanged: ((String) -> Void)?
    var onMrzChanged: ((String) -> Void)?

    private let stackView = UIStackView()
    private let documentNumberField = UITextField()
    private let dateOfBirthField = UITextField()
    private let dateOfExpiryField = UITextField()
    private let mrzField = UITextField()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(documentNumber: String, dateOfBirth: String, dateOfExpiry: String, mrzString: String) {
        documentNumberField.text = documentNumber
        dateOfBirthField.text = dateOfBirth
        dateOfExpiryField.text = dateOfExpiry
        mrzField.text = mrzString
    }

    private func setupViews() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8

        configureField(documentNumberField, placeholder: "Document Number", keyboardType: .default)
        configureField(dateOfBirthField, placeholder: "Date of Birth (YYMMDD)", keyboardType: .numberPad)
        configureField(dateOfExpiryField, placeholder: "Expiration Date (YYMMDD)", keyboardType: .numberPad)
        configureField(mrzField, placeholder: "MRZ String", keyboardType: .default)

        addSubview(stackView)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ])
    }

    private func configureField(_ textField: UITextField, placeholder: String, keyboardType: UIKeyboardType) {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.font = UIFont.monospacedSystemFont(ofSize: 17, weight: .regular)
        textField.clearButtonMode = .always
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .secondarySystemBackground
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        stackView.addArrangedSubview(textField)
    }

    @objc private func textChanged(_ sender: UITextField) {
        let text = sender.text ?? ""
        if sender === documentNumberField {
            onDocumentNumberChanged?(text)
            return
        }
        if sender === dateOfBirthField {
            onDateOfBirthChanged?(text)
            return
        }
        if sender === dateOfExpiryField {
            onDateOfExpiryChanged?(text)
            return
        }
        if sender === mrzField {
            onMrzChanged?(text)
        }
    }
}
