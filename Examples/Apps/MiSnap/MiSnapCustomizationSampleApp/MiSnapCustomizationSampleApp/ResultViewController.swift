//
//  ResultViewController.swift
//  MiSnapDevApp
//
//  Created by Mitek Engineering on 3/5/21.
//  Copyright © 2021 Mitek Systems. All rights reserved.
//

import UIKit
import MiSnapCore
import MiSnap
import MiSnapUX

private enum ResultSection: String, Equatable, CaseIterable {
    case summary        = "Summary"
    case odc            = "ODC"
    case ode            = "ODE"
    
    var index: Int {
        switch self {
        case .summary:  return 0
        case .odc:      return 1
        case .ode:      return 2
        }
    }
    
    static func section(from index: Int) -> ResultSection {
        switch index {
        case 0:     return .summary
        case 1:     return .odc
        case 2:     return .ode
        default: fatalError("there's no section with index \(index)")
        }
    }
}

class ResultViewController: UIViewController {
    private let heightConstant: CGFloat = 50.0
    private let widthMultiplier: CGFloat = 0.95
    
    private var result: MiSnapResult?
    
    private var scrollView: UIScrollView!
    private var scrollVerticalStackView: UIStackView!
    private var configured: Bool = false
    
    private var personalDataArray: [String] {
        guard let result = result, let extraction = result.extraction else { return [] }
        var array: [String] = []
        
        if let givenName = extraction.givenName {
            array.append("Given name:\(givenName)")
        }
        if let middleName = extraction.middleName {
            array.append("Middle name:\(middleName)")
        }
        if let surname = extraction.surname {
            array.append("Surname:\(surname)")
        }
        if let dateOfBirth = extraction.dateOfBirthFormatted {
            array.append("Date of birth:\(dateOfBirth)")
        }
        if extraction.age != -1 {
            array.append("Age:\(String(describing: extraction.age))")
        }
        if let personalNumber = extraction.personalNumber {
            array.append("Personal number:\(personalNumber)")
        }
        if let optionalNumber = extraction.optionalNumber {
            array.append("Optional number:\(optionalNumber)")
        }
        if let sex = extraction.sex {
            array.append("Sex:\(sex)")
        }
        return array
    }
    
    private var documentDataArray: [String] {
        guard let result = result, let extraction = result.extraction else { return [] }
        var array: [String] = []

        if let documentNumber = extraction.documentNumber {
            array.append("Document number:\(documentNumber)")
        }
        if let issueDate = extraction.issueDateFormatted {
            array.append("Issue date:\(issueDate)")
        }
        if let expirationDate = extraction.expirationDateFormatted {
            array.append("Expiration date:\(expirationDate)")
            array.append("Expiration status:\(extraction.expirationStatusString)")
        }
        if let licenseClass = extraction.licenseClass {
            array.append("License class:\(licenseClass)")
        }
        if let restrictionCodes = extraction.restrictionCodes {
            array.append("Restriction codes:\(restrictionCodes)")
        }
        if let endorsementCodes = extraction.endorsementCodes {
            array.append("Endorsement codes:\(endorsementCodes)")
        }
        return array
    }
    
    private var addressArray: [String] {
        guard let result = result, let extraction = result.extraction else { return [] }
        var array: [String] = []
        
        if let addressLine1 = extraction.addressLine1 {
            array.append("Address line 1:\(addressLine1)")
        }
        if let addressLine2 = extraction.addressLine2 {
            array.append("Address line 2:\(addressLine2)")
        }
        if let city = extraction.city {
            array.append("City:\(city)")
        }
        if let state = extraction.state {
            array.append("State:\(state)")
        }
        if let postalCode = extraction.postalCode {
            array.append("Postal code:\(postalCode)")
        }
        if let country = extraction.country {
            array.append("Country:\(country)")
        }
        return array
    }
    
    private var personalDataOtherArray: [String] {
        guard let result = result, let extraction = result.extraction else { return [] }
        var array: [String] = []
        
        if let height = extraction.height {
            array.append("Height:\(height)")
        }
        if let weight = extraction.weight {
            array.append("Weight:\(weight)")
        }
        if let eyeColor = extraction.eyeColor {
            array.append("Eye color:\(eyeColor)")
        }
        if let hairColor = extraction.hairColor {
            array.append("Hair color:\(hairColor)")
        }
        if let nationality = extraction.nationality {
            array.append("Nationality:\(nationality)")
        }
        if !array.isEmpty {
            array.append("Organ donor:\(extraction.organDonor)")
            array.append("Veteran:\(extraction.veteran)")
        }
        return array
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with result: MiSnapResult) {
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
    
    deinit {
        print("\(NSStringFromClass(type(of: self))) is deinitialized")
    }
}

// MARK: Private views configurations functions
extension ResultViewController {
    private func configureSubviews() {
        configureConstantSubviews()
        configureResultSection(.summary)
    }
    
    private func configureConstantSubviews() {
        if configured { return }
        configured = true
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 200))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = result?.image
        imageView.isUserInteractionEnabled = true
        
        let imageViewTap = UITapGestureRecognizer(target: self, action: #selector(imageViewTapAction))
        imageViewTap.numberOfTapsRequired = 1
        
        imageView.addGestureRecognizer(imageViewTap)
        
        let segmentedControl = UISegmentedControl(items: ResultSection.allCases.compactMap { $0.rawValue })
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = ResultSection.summary.index
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = false
        
        scrollVerticalStackView = UIStackView()
        scrollVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollVerticalStackView.axis = .vertical
        scrollVerticalStackView.spacing = 5
        scrollVerticalStackView.distribution = .equalSpacing
        
        let mainVerticalStackView = UIStackView(arrangedSubviews: [imageView, segmentedControl, scrollView])
        mainVerticalStackView.translatesAutoresizingMaskIntoConstraints = false
        mainVerticalStackView.axis = .vertical
        mainVerticalStackView.spacing = 10
        mainVerticalStackView.distribution = .fill

        view.addSubview(mainVerticalStackView)
        
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 110, height: 100))
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("Back", for: .normal)
        backButton.setTitleColor(#colorLiteral(red: 0.03529411765, green: 0.4666666667, blue: 1, alpha: 1), for: .normal)
        backButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        backButton.contentHorizontalAlignment = .left
        backButton.contentVerticalAlignment = .top
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        
        view.addSubview(backButton)

        var topAnchor = view.topAnchor
        var leftAnchor = view.leftAnchor
        if #available(iOS 11.0, *) {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
            leftAnchor = view.safeAreaLayoutGuide.leftAnchor
        }

        NSLayoutConstraint.activate([
            mainVerticalStackView.topAnchor.constraint(equalTo: topAnchor),
            mainVerticalStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainVerticalStackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mainVerticalStackView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),
            
            segmentedControl.heightAnchor.constraint(equalToConstant: 30),
            
            backButton.widthAnchor.constraint(equalToConstant: backButton.frame.width),
            backButton.heightAnchor.constraint(equalToConstant: backButton.frame.height),
            backButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            backButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 20)
        ])
    }
    
    private func configureResultSection(_ section: ResultSection) {
        clearSubviews()
        addScrollStackView()
        
        switch section {
        case .summary:      configureSummarySection()
        case .odc:          configureOdcSection()
        case .ode:          configureOdeSection()
        }
    }
    
    private func configureOdcSection() {
        guard let result = result else { return }
        
        if !MiSnapLicenseManager.shared.featureSupported(.ODC) {
            addInfo(withTitle: "Your license doesn't support On-Device Classification", value: "", split: 1000.0)
            return
        }
        
        addInfo(withTitle: "Classification document type", value: result.classification.documentTypeString)
    }
    
    private func configureOdeSection() {
        if !MiSnapLicenseManager.shared.featureSupported(.ODE) {
            addInfo(withTitle: "Your license doesn't support On-Device Extraction", value: "", split: 1000.0)
            return
        }
        
        if personalDataArray.isEmpty, documentDataArray.isEmpty, addressArray.isEmpty, personalDataOtherArray.isEmpty {
            addInfo(withTitle: "No extracted info available for this document type", value: "", split: 1000.0)
            return
        }
        
        if !personalDataArray.isEmpty {
            addHeader(withTitle: "Personal Data")
            addEntries(from: personalDataArray)
        }
        
        if !documentDataArray.isEmpty {
            addHeader(withTitle: "Document Data")
            addEntries(from: documentDataArray)
        }
        
        if !addressArray.isEmpty {
            addHeader(withTitle: "Address")
            addEntries(from: addressArray)
        }
        
        if !personalDataOtherArray.isEmpty {
            addHeader(withTitle: "Personal Data (Other)")
            addEntries(from: personalDataOtherArray)
        }
    }
    
    private func addHeader(withTitle title: String) {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .systemFont(ofSize: 21, weight: .light)
        label.textAlignment = .center
        label.numberOfLines = 3
        
        var backgroundColor: UIColor = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                backgroundColor = #colorLiteral(red: 0.3333333333, green: 0.3333333333, blue: 0.3333333333, alpha: 1)
            }
        }
        
        label.backgroundColor = backgroundColor
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        
        scrollVerticalStackView.addArrangedSubview(label)
        
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: scrollVerticalStackView.widthAnchor),
            label.heightAnchor.constraint(equalToConstant: heightConstant)
        ])
    }
    
    private func addEntries(from array: [String]) {
        for str in array {
            let splitted = str.split(separator: ":")
            guard splitted.count == 2 else { fatalError("expected 2 components but got \(splitted.count)") }
            addInfo(withTitle: String(splitted[0]), value: String(splitted[1]))
        }
    }

    
    private func addInfo(withTitle title: String, value: String, split: CGFloat = 1.0) {
        let titelLabel = configureInfoLabel(withTitle: title, textAlignment: .left)
        let valueLabel = configureInfoLabel(withTitle: value, textAlignment: .right)
        
        let stackView = UIStackView(arrangedSubviews: [titelLabel, valueLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fill
        
        scrollVerticalStackView.addArrangedSubview(stackView)
        
        var multiplier: CGFloat = 1.0 / (1.0 + split) - stackView.spacing / (view.frame.width * widthMultiplier)
        if multiplier < 0.001 {
            multiplier = 0.001
        }
        
        NSLayoutConstraint.activate([
            valueLabel.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: multiplier),
            valueLabel.heightAnchor.constraint(equalToConstant: heightConstant),
            
            titelLabel.heightAnchor.constraint(equalToConstant: heightConstant)
        ])
    }
    
    private func configureInfoLabel(withTitle title: String, textAlignment: NSTextAlignment) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textAlignment = textAlignment
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 19, weight: .light)
        return label
    }
    
    private func configureSummarySection() {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .natural
        var str = ""
        if let result = result {
            var localizedStatus = MiSnapResult.string(from: result.highestPriorityStatus)
            if result.highestPriorityStatus == .good {
                localizedStatus = "Good"
            }
            str = "Status: \(localizedStatus)"
            if let mibiDataString = result.mibi.string {
                str += "\n\nMIBI: \(mibiDataString)"
            }
            if let extraction = result.extraction, let barcodeString = extraction.barcodeString {
                str += "\n\nBarcode string (not embedded into MIBI):\n\(barcodeString)"
            }
        }
        textView.text = str
        textView.font = .systemFont(ofSize: 19, weight: .light)
        textView.bounces = false
        
        scrollView.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: widthMultiplier),
            textView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            textView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor)
        ])
    }
    
    private func clearSubviews() {
        for v in scrollVerticalStackView.arrangedSubviews {
            v.removeFromSuperview()
        }
        
        for v in scrollView.subviews {
            v.removeFromSuperview()
        }
    }
    
    private func addScrollStackView() {
        scrollView.addSubview(scrollVerticalStackView)
        
        NSLayoutConstraint.activate([
            scrollVerticalStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollVerticalStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollVerticalStackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: widthMultiplier),
            scrollVerticalStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

// MARK: Other private functions
extension ResultViewController: UIScrollViewDelegate {
    @objc private func imageViewTapAction() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.tag = 3
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = result?.image
        imageView.tag = 4
        
        let zoomScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        zoomScrollView.translatesAutoresizingMaskIntoConstraints = false
        zoomScrollView.minimumZoomScale = 1.0
        zoomScrollView.maximumZoomScale = 5.0
        zoomScrollView.showsHorizontalScrollIndicator = false
        zoomScrollView.showsVerticalScrollIndicator = false
        zoomScrollView.bounces = false
        zoomScrollView.delegate = self
        zoomScrollView.tag = 5
        
        let zoomScrollViewTap = UITapGestureRecognizer(target: self, action: #selector(zoomScrollViewTapAction))
        zoomScrollViewTap.numberOfTapsRequired = 1
        
        zoomScrollView.addGestureRecognizer(zoomScrollViewTap)
        
        view.addSubview(blurView)
        zoomScrollView.addSubview(imageView)
        view.addSubview(zoomScrollView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurView.leftAnchor.constraint(equalTo: view.leftAnchor),
            blurView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            zoomScrollView.widthAnchor.constraint(equalTo: view.widthAnchor),
            zoomScrollView.heightAnchor.constraint(equalTo: view.heightAnchor),
            zoomScrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            zoomScrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            imageView.widthAnchor.constraint(equalTo: zoomScrollView.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: zoomScrollView.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: zoomScrollView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: zoomScrollView.centerYAnchor),
        ])
        
        zoomScrollView.contentSize = imageView.frame.size
    }
    
    @objc private func zoomScrollViewTapAction() {
        if let v = view.viewWithTag(3) {
            v.removeFromSuperview()
        }
        
        if let v = view.viewWithTag(5) as? UIScrollView {
            v.delegate = nil
            v.removeFromSuperview()
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        guard let v = view.viewWithTag(4) else { return nil }
        return v
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard let v = view.viewWithTag(4) else { fatalError("there's no view with tag 4") }
        
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0.0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0.0)
        v.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY)
    }
}

// MARK: Other private functions
extension ResultViewController {
    @objc private func segmentedControlValueChanged(_ segmentedControl: UISegmentedControl) {
        configureResultSection(ResultSection.section(from: segmentedControl.selectedSegmentIndex))
    }
    
    @objc private func backButtonAction() {
        dismiss(animated: true, completion: nil)
    }
}

