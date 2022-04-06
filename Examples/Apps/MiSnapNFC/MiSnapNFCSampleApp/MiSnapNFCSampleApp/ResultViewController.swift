//
//  ResultViewController.swift
//  MiSnapNFCSampleApp
//
//  Created by Stas Tsuprenko on 3/25/22.
//

import UIKit
import MiSnapNFC

class ResultViewController: UIViewController {
    private var result: [String : Any]?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with result: [String : Any]?) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var backgroundColor: UIColor = .white
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                backgroundColor = .black
            }
        }
        view.backgroundColor = backgroundColor
        
        configureSubviews()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    deinit {
        print("\(NSStringFromClass(type(of: self))) is deinitialized")
    }
}

// MARK: Private views configurations functions
extension ResultViewController {
    private func configureSubviews() {
        guard let result = result else { return }
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 40))
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(.systemBlue, for: .normal)
        backButton.setTitleColor(.systemBlue.withAlphaComponent(0.4), for: .highlighted)
        backButton.titleLabel?.font = .systemFont(ofSize: 20.0, weight: .bold)
        backButton.backgroundColor = .clear
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        
        view.addSubview(backButton)
        
        let imagesStackView = UIStackView()
        imagesStackView.translatesAutoresizingMaskIntoConstraints = false
        imagesStackView.axis = .horizontal
        imagesStackView.distribution = .equalCentering
        imagesStackView.spacing = 5
        
        view.addSubview(imagesStackView)
        
        add(image: result[MiSnapNFCKey.faceImage] as? UIImage, to: imagesStackView)
        add(image: result[MiSnapNFCKey.signatureImage] as? UIImage, to: imagesStackView)
        
        var imagesStackViewWidth: CGFloat = CGFloat(imagesStackView.arrangedSubviews.count - 1) * imagesStackView.spacing
        for v in imagesStackView.arrangedSubviews {
            imagesStackViewWidth += v.frame.width
        }
        
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.isSelectable = true
        textView.bounces = false
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.text = string(from: result)
        textView.font = .systemFont(ofSize: 16)
        textView.textContainer.lineBreakMode = .byCharWrapping
        
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: backButton.frame.width),
            backButton.heightAnchor.constraint(equalToConstant: backButton.frame.height),
            backButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            
            imagesStackView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10),
            imagesStackView.widthAnchor.constraint(equalToConstant: imagesStackViewWidth),
            imagesStackView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.25),
            imagesStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            textView.topAnchor.constraint(equalTo: imagesStackView.bottomAnchor, constant: 10),
            textView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func add(image: UIImage?, to stackView: UIStackView) {
        guard let image = image else { return }

        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        stackView.addArrangedSubview(imageView)
        
        var ar = 0.95
        if image.size.width > 0 && image.size.height > 0 {
            ar = image.size.width / image.size.height
            if ar > 0.95 {
                ar = 0.95
            }
        }
        
        let height = view.frame.height * 0.25
        imageView.frame = CGRect(x: 0, y: 0, width: height * ar, height: height)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: imageView.frame.width)
        ])
    }
    
    func string(from result: [String : Any]) -> String {
        guard !result.isEmpty else { return "" }
        
        var str = ""
        
        if let givenName = result[MiSnapNFCKey.givenName] as? String {
            str += "Given name: " + givenName
        }
        if let surname = result[MiSnapNFCKey.surname] as? String {
            str += "\nSurname: " + surname
        }
        if let dob = result[MiSnapNFCKey.dateOfBirth] as? String {
            str += "\nDate of birth: " + dob
        }
        if let placeOfBirth = result[MiSnapNFCKey.placeOfBirth] as? String {
            str += "\nPlace of birth: " + placeOfBirth
        }
        if let gender = result[MiSnapNFCKey.sex] as? String {
            str += "\nGender: " + gender
        }
        if let nationality = result[MiSnapNFCKey.nationality] as? String {
            str += "\nNationality: " + nationality
        }
        if let docNumber = result[MiSnapNFCKey.documentNumber] as? String {
            str += "\nDocument number: " + docNumber
        }
        if let doe = result[MiSnapNFCKey.documentExpiryDate] as? String {
            str += "\nDocument expiry date: " + doe
        }
        if let doi = result[MiSnapNFCKey.documentIssueDate] as? String {
            str += "\nDocument issue date: " + doi
        }
        if let address = result[MiSnapNFCKey.address] as? String {
            str += "\nAddress: " + address
        }
        if let telephone = result[MiSnapNFCKey.telephone] as? String {
            str += "\nTelephone: " + telephone
        }
        if let profession = result[MiSnapNFCKey.profession] as? String {
            str += "\nProfession: " + profession
        }
        if let title = result[MiSnapNFCKey.title] as? String {
            str += "\nTitle: " + title
        }
        if let personalSummary = result[MiSnapNFCKey.personalSummary] as? String {
            str += "\nPersonal summary: " + personalSummary
        }
        if let otherTravelDocNumbers = result[MiSnapNFCKey.otherTravelDocNumbers] as? [String] {
            for otherTravelDocNumber in otherTravelDocNumbers {
                str += "\nOther travel doc number: " + otherTravelDocNumber
            }
        }
        if let custodyInformation = result[MiSnapNFCKey.custodyInformation] as? String {
            str += "\nCustody information: " + custodyInformation
        }
        if let personalNumber = result[MiSnapNFCKey.personalNumber] as? String {
            str += "\nPersonal number: " + personalNumber
        }
        if let licenseClasses = result[MiSnapNFCKey.licenseClasses] as? [[String : String]] {
            str += "\nLicense classes:"
            for licenseClass in licenseClasses {
                if let licenseClassName = licenseClass[MiSnapNFCKey.licenseClass],
                   let doi = licenseClass[MiSnapNFCKey.licenseClassIssueDate],
                   let doe = licenseClass[MiSnapNFCKey.licenseClassExpiryDate] {
                    str += "\n\(licenseClassName) (DOI: \(doi), DOE: \(doe))"
                }
            }
        }
        if let issuingCountry = result[MiSnapNFCKey.issuingCountry] as? String {
            str += "\nIssuing country: " + issuingCountry
        }
        if let issuingAuthority = result[MiSnapNFCKey.issuingAuthority] as? String {
            str += "\nIssuing authority: " + issuingAuthority
        }
        if let documentType = result[MiSnapNFCKey.documentType] as? String {
            str += "\nDocument type: " + documentType
        }
        if let documentTypeCode = result[MiSnapNFCKey.documentTypeCode] as? String {
            str += "\nDocument type code: " + documentTypeCode
        }
        if let MRZ = result[MiSnapNFCKey.MRZ] as? String {
            str += "\nMRZ: " + MRZ
        }
        if let cipherText = result[MiSnapNFCKey.authenticationOutputs] as? String {
            str += "\nCA: " + cipherText
        }
        
        return str
    }
    
    @objc private func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }
}
