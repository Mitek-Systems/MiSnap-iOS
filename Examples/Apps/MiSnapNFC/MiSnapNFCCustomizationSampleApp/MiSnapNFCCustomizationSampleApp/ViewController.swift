//
//  ViewController.swift
//  MiSnapNFCCustomizationSampleApp
//
//  Created by Mitek Engineering on 3/25/22.
//

import UIKit
import MiSnapNFCUX
import MiSnapNFC
import MiSnapLicenseManager

class ViewController: UIViewController {
    private var misnapNFCVC: MiSnapNFCViewController?
    private var result: [String : Any]?
    
    private var resultVC: ResultViewController?
    
    private var stackView = UIStackView()
    private var documentTypeSegmenetedControl = UISegmentedControl(items: ["Passport", "ID", "DL"])

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        misnapNFCVC = nil
        resultVC = nil
        
        configureSubviews()
        
        if let result = result {
            resultVC = ResultViewController(with: result)
            guard let resultVC = resultVC else { return }
            present(resultVC, animated: true)
            self.result = nil
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK: Invoking MiSnapNFC
extension ViewController {
    @objc private func scanButtonAction() {
        let documentType: MiSnapNFCDocumentType = getSelectedDocumentType()
        let documentNumber = getValue(for: .documentNumber)
        let dateOfBirth = getValue(for: .dateOfBirth)
        let dateOfExpiry = getValue(for: .dateOfExpiry)
        let mrzString = getValue(for: .mrzString)
                
        let chipLocation = MiSnapNFCChipLocator.chipLocation(mrzString: mrzString,
                                                             documentNumber: documentNumber,
                                                             dateOfBirth: dateOfBirth,
                                                             dateOfExpiry: dateOfExpiry)

        if (chipLocation == .noChip && (documentType == .id || documentType == .passport)) ||
            (documentType == .dl && mrzString.isEmpty) {
            let alert = UIAlertController(title: nil, message: "There is no chip in a document with provided information or a document is not supported yet", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true)
        } else {
            let configuration = MiSnapNFCConfiguration()
                .withInputs { inputs in
                    inputs.documentNumber = documentNumber
                    inputs.dateOfBirth = dateOfBirth
                    inputs.dateOfExpiry = dateOfExpiry
                    inputs.mrzString = mrzString
                    inputs.documentType = documentType
                    inputs.chipLocation = chipLocation
                }
                .withCustomUxParameters { uxParameters in
                    uxParameters.timeout = 20.0
                }
                .withCustomLocalization { localization in
                    localization.bundle = Bundle.main
                    localization.stringsName = "Localizable"
                }
            
            misnapNFCVC = MiSnapNFCViewController(with: configuration, delegate: self)
            
            guard let misnapNFCVC = misnapNFCVC else { return }
            present(misnapNFCVC, animated: true)
        }
    }
}

// MARK: MiSnapNFCViewControllerDelegate callbacks
extension ViewController: MiSnapNFCViewControllerDelegate {
    // Note, it will only be sent if `MiSnapLicenseStatus` is anything but `.valid`
    func miSnapNfcLicenseStatus(_ status: MiSnapLicenseStatus) {
        // Handle a license status here
    }

    func miSnapNfcSuccess(_ result: [String : Any]) {
        // Handle successful session results here
        self.result = result
    }

    func miSnapNfcCancelled(_ result: [String: Any]) {
        // Handle cancelled session results here
    }

    func miSnapNfcSkipped(_ result: [String: Any]) {
        // Handle skipped session results here
    }
}

// MARK: Views configurations
extension ViewController {
    private func configureSubviews() {
        if let _ = view.viewWithTag(1) { return }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .equalCentering
        
        view.addSubview(stackView)
        
        for nfcField in NFCField.allCases {
            add(nfcField, to: stackView)
        }
        
        documentTypeSegmenetedControl.translatesAutoresizingMaskIntoConstraints = false
        documentTypeSegmenetedControl.selectedSegmentIndex = 0
        view.addSubview(documentTypeSegmenetedControl)
        
        let scanButton = configureButton(withTitle: "Scan eDocument", selector: #selector(scanButtonAction))
        scanButton.tag = 1
        
        view.addSubview(scanButton)
                
        let appNameLabel = configureLabel(withText: "MiSnapNFC\nCustomizationSampleApp", numberOfLines: 2)
        let misnapUxVersionLabel = configureLabel(withText: "MiSnapNFCUX \(MiSnapNFCUX.version())", fontSize: 17)
        let misnapVersionLabel = configureLabel(withText: "MiSnapNFC \(MiSnapNFC.version())", fontSize: 17)
        
        view.addSubview(appNameLabel)
        view.addSubview(misnapUxVersionLabel)
        view.addSubview(misnapVersionLabel)
        
        NSLayoutConstraint.activate([
            appNameLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            appNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: appNameLabel.bottomAnchor, constant: 30),
            stackView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9),
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            documentTypeSegmenetedControl.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            documentTypeSegmenetedControl.widthAnchor.constraint(equalToConstant: view.frame.width * 0.9),
            documentTypeSegmenetedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            scanButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanButton.topAnchor.constraint(equalTo: documentTypeSegmenetedControl.bottomAnchor, constant: 50),
            
            misnapVersionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            misnapVersionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            misnapUxVersionLabel.bottomAnchor.constraint(equalTo: misnapVersionLabel.topAnchor, constant: -5),
            misnapUxVersionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureButton(withTitle title: String, selector: Selector) -> UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.setTitleColor(.systemBlue.withAlphaComponent(0.4), for: .highlighted)
        button.titleLabel?.font = .systemFont(ofSize: 19.0, weight: .bold)
        
        button.addTarget(self, action: selector, for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: button.frame.width),
            button.heightAnchor.constraint(equalToConstant: button.frame.height)
        ])
        
        return button
    }
    
    private func configureLabel(withText text: String, numberOfLines: Int = 1, fontSize: CGFloat = 19.0) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.9, height: CGFloat(numberOfLines * 27)))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: fontSize, weight: .thin)
        label.numberOfLines = numberOfLines
        label.textAlignment = .center
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalToConstant: label.frame.width),
            label.heightAnchor.constraint(equalToConstant: label.frame.height)
        ])
        
        return label
    }
    
    private func add(_ nfcField: NFCField, to stackView: UIStackView) {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: view.frame.width * 0.9, height: 30))
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 21.0)
        textField.placeholder = nfcField.placeholder
        if let text = UserDefaults.standard.object(forKey: nfcField.rawValue) as? String {
            textField.text = text
        }
        switch nfcField {
        case .dateOfBirth, .dateOfExpiry: textField.keyboardType = .numberPad
        default: break
        }
        
        textField.delegate = self
        
        stackView.addArrangedSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalToConstant: textField.frame.width)
        ])
    }
    
    private func getValue(for nfcField: NFCField) -> String {
        guard let textField = stackView.arrangedSubviews[nfcField.index] as? UITextField else { return "" }
        return textField.text ?? ""
    }
    
    private func getSelectedDocumentType() -> MiSnapNFCDocumentType {
        guard let documentType = MiSnapNFCDocumentType(rawValue: documentTypeSegmenetedControl.selectedSegmentIndex + 1) else { return .none }
        return documentType
    }
}

// MARK: UITextFieldDelegate callbacks
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("Setting")
        for (index, view) in stackView.arrangedSubviews.enumerated() {
            guard let textField = view as? UITextField else { continue }
            let nfcField = NFCField.from(index)
            UserDefaults.standard.set(textField.text ?? "", forKey: nfcField.rawValue)
        }
        
        UserDefaults.standard.synchronize()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
