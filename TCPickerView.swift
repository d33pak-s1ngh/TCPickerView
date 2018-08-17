//
//  TCPickerView.swift
//  TCPickerView
//
//  Created by Taras Chernyshenko on 9/4/17.
//  Copyright © 2017 Taras Chernyshenko. All rights reserved.
//

import UIKit

public protocol TCPickerViewDelegate: class {
    func pickerView(_ pickerView: TCPickerView, didSelectRowAtIndex index: Int)
}

open class TCPickerView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    public enum Mode {
        case none
        case single
        case multiply
    }
    
    public struct Value {
        public let title: String
        public var isChecked: Bool
        public var id: String
        
        public init(title: String, isChecked: Bool = false,id: String = "0") {
            self.title = title
            self.isChecked = isChecked
            self.id = id
        }
//        public init(title: String, isChecked: Bool = false) {
//            self.title = title
//            self.isChecked = isChecked
//        }
    }
    
    public typealias Completion = ([Int]) -> Void
    fileprivate let tableViewCellIdentifier = "TableViewCell"
    fileprivate var titleLabel: UILabel?
    fileprivate var selectAllButton: UIButton? //setp 1
    fileprivate var doneButton: UIButton?
    fileprivate var closeButton: UIButton?
    fileprivate var containerView: UIView?
    fileprivate var centerXConstraint: NSLayoutConstraint?
    fileprivate var centerYConstraint: NSLayoutConstraint?
    fileprivate var tableView: UITableView?
    fileprivate var titleLabelWidth : NSLayoutConstraint?
    fileprivate var selectAllButtonWidth : NSLayoutConstraint?
    
    private var checkmark: UIImage {
        var image = UIImage()
        let podBundle = Bundle(for: TCPickerView.self)
        if let url = podBundle.url(forResource: "TCPickerView", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            image = UIImage(named: "checkmark_icon", in: bundle, compatibleWith: nil)!
        } else {
            return UIImage(named: "checkmark_icon")!
        }
        return image
    }
    
    private var checked: UIImage {
        var image = UIImage()
        let podBundle = Bundle(for: TCPickerView.self)
        if let url = podBundle.url(forResource: "TCPickerView", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            image = UIImage(named: "checked", in: bundle, compatibleWith: nil)!
        } else {
            return UIImage(named: "checked")!
        }
        return image
    }
    
    private var unchecked: UIImage {
        var image = UIImage()
        let podBundle = Bundle(for: TCPickerView.self)
        if let url = podBundle.url(forResource: "TCPickerView", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            image = UIImage(named: "unchecked", in: bundle, compatibleWith: nil)!
        } else {
            return UIImage(named: "unchecked")!
        }
        return image
    }
    
    
    
    open var title: String = "Select" {
        didSet {
            self.titleLabel?.text = self.title
        }
    }
    open var doneText: String = "Done" {
        didSet {
            self.doneButton?.setTitle(self.doneText, for: .normal)
        }
    }
    open var closeText: String = "Close" {
        didSet {
            self.closeButton?.setTitle(self.closeText, for: .normal)
        }
    }
    //setp 2
    open var selectAllText: String = "All" {
        didSet {
            self.selectAllButton?.setTitle(self.selectAllText, for: .normal)
        }
    }
    open var textColor: UIColor = UIColor.white {
        didSet {
            self.titleLabel?.textColor = self.textColor
            self.doneButton?.titleLabel?.textColor = self.textColor
            self.closeButton?.titleLabel?.textColor = self.textColor
            self.selectAllButton?.titleLabel?.textColor = self.textColor //step 3
        }
    }
    open var mainColor: UIColor = UIColor(red: 75/255, green: 178/255,
        blue: 218/255, alpha: 1) {
        didSet {
            self.doneButton?.backgroundColor = self.mainColor
            self.titleLabel?.backgroundColor = self.mainColor
        }
    }
    open var closeButtonColor: UIColor = UIColor(red: 198/255,
        green: 198/255, blue: 198/255, alpha: 1) {
        didSet {
            self.closeButton?.backgroundColor = self.closeButtonColor
        }
    }
    //step 4
    open var selectAllButtonColor: UIColor = UIColor(red: 198/255,
                                                 green: 198/255, blue: 198/255, alpha: 1) {
        didSet {
            self.selectAllButton?.backgroundColor = self.closeButtonColor
        }
    }
    
    open var buttonFont: UIFont? = UIFont(name: "Helvetica", size: 15.0) {
        didSet {
            self.doneButton?.titleLabel?.font = self.buttonFont
            self.closeButton?.titleLabel?.font = self.buttonFont
        }
    }
    open var titleFont: UIFont? = UIFont(name: "Helvetica-Bold", size: 15.0) {
        didSet {
            self.titleLabel?.font = self.titleFont
        }
    }
    open var itemsFont: UIFont = UIFont.systemFont(ofSize: 15.0)
    
    open var values: [Value] = [] {
        didSet {
            self.tableView?.reloadData()
        }
    }
    
    open weak var delegate: TCPickerViewDelegate?
    
    open var completion: Completion?
    open var selection: Mode = .multiply {
        didSet{
            if selection == .multiply{
                print("multiple selection")
                
            }else{
                
                self.titleLabelWidth?.isActive = false
                self.titleLabelWidth = self.titleLabel?.widthAnchor.constraint(equalTo: (self.containerView?.widthAnchor)!, multiplier: 4/4)
                self.titleLabelWidth?.isActive = true
                
                self.selectAllButtonWidth?.isActive = false
                self.selectAllButtonWidth =  self.selectAllButton?.widthAnchor.constraint(equalTo: (self.containerView?.widthAnchor)!, multiplier: 0)
                selectAllButtonWidth?.isActive = true
                
                print("single or none selection")
            }
        }
    }
    
    public init() {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        let frame: CGRect = CGRect(x: 0, y: 0, width: screenWidth,
            height: screenHeight)
        super.init(frame: frame)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    fileprivate func initialize() {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        let width: CGFloat = screenWidth - 84
        let height: CGFloat = 400
        let x: CGFloat = 32
        let y: CGFloat = (screenHeight - height) / 2
        let frame: CGRect = CGRect(x: x, y: y, width: width, height: height)
        
        self.containerView = UIView(frame: frame)
        self.doneButton = UIButton(frame: CGRect.zero)
        self.selectAllButton = UIButton(frame: CGRect.zero) //step 5
        self.closeButton = UIButton(frame: CGRect.zero)
        self.titleLabel = UILabel(frame: CGRect.zero)
        self.tableView = UITableView(frame: CGRect.zero)
        self.tableView?.register(TCPickerTableViewCell.self,
            forCellReuseIdentifier: self.tableViewCellIdentifier)
        self.tableView?.tableFooterView = UIView()
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        
        self.doneButton?.addTarget(self, action: #selector(TCPickerView.done),
            for: .touchUpInside)
        self.closeButton?.addTarget(self, action: #selector(TCPickerView.close),
            for: .touchUpInside)
        self.selectAllButton?.addTarget(self, action: #selector(TCPickerView.selectAllOption),
                                    for: .touchUpInside)
        
        self.setupUI()
        self.updateUI()
    }
    
    fileprivate func setupUI() {
        //step 6
        guard let containerView = self.containerView,
            let doneButton = self.doneButton,
            let closeButton = self.closeButton,
            let titleLabel = self.titleLabel,
            let tableView = self.tableView,let selectAllButton = self.selectAllButton else {
                return
        }
        
        self.addSubview(containerView)
        containerView.addSubview(doneButton)
        containerView.addSubview(selectAllButton)
        containerView.addSubview(closeButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(tableView)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        selectAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        self.containerView?.center = CGPoint(x: self.center.x,
            y: self.center.y + self.frame.size.height)
        
        //titles
//        containerView.addConstraint(NSLayoutConstraint(item: titleLabel,
//            attribute: .top, relatedBy: .equal, toItem: containerView,
//            attribute: .top, multiplier: 1.0, constant: 0))
//        containerView.addConstraint(NSLayoutConstraint(item: titleLabel,
//           attribute: .leading, relatedBy: .equal, toItem: containerView,
//           attribute: .leading, multiplier: 1.0, constant: 0))
//        containerView.addConstraint(NSLayoutConstraint(item: titleLabel,
//           attribute: .trailing, relatedBy: .equal, toItem: containerView,
//           attribute: .trailing, multiplier: 1.0, constant: 0))
//        titleLabel.addConstraint(NSLayoutConstraint(item: titleLabel,
//            attribute: .height, relatedBy: .equal, toItem: nil,
//            attribute: .height, multiplier: 1.0, constant: 50))
        
        titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        titleLabelWidth = titleLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: self.selection == .multiply ? 3/4 : 4/4)
        
        titleLabelWidth?.isActive = true
        
        titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        selectAllButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        selectAllButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        selectAllButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        selectAllButtonWidth =  selectAllButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: self.selection == .multiply ?1/4 : 0)
        selectAllButtonWidth?.isActive = true
        
    
        
        //buttons
        containerView.addConstraint(NSLayoutConstraint(item: containerView,
            attribute: .trailing, relatedBy: .equal, toItem: doneButton,
            attribute: .trailing, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: containerView,
            attribute: .bottom, relatedBy: .equal, toItem: doneButton,
            attribute: .bottom, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: doneButton,
            attribute: .width, relatedBy: .equal, toItem: containerView,
            attribute: .width, multiplier: 0.5, constant: 0))
        doneButton.addConstraint(NSLayoutConstraint(item: doneButton,
            attribute: .height, relatedBy: .equal, toItem: nil,
            attribute: .height, multiplier: 1.0, constant: 50))
        
        containerView.addConstraint(NSLayoutConstraint(item: containerView,
            attribute: .leading, relatedBy: .equal, toItem: closeButton,
            attribute: .leading, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: containerView,
            attribute: .bottom, relatedBy: .equal, toItem: closeButton,
            attribute: .bottom, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: closeButton,
            attribute: .width, relatedBy: .equal, toItem: containerView,
            attribute: .width, multiplier: 0.5, constant: 0))
        closeButton.addConstraint(NSLayoutConstraint(item: closeButton,
            attribute: .height, relatedBy: .equal, toItem: nil,
            attribute: .height, multiplier: 1.0, constant: 50))
        
        //tableView
        containerView.addConstraint(NSLayoutConstraint(item: containerView,
            attribute: .trailing, relatedBy: .equal, toItem: tableView,
            attribute: .trailing, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: containerView,
            attribute: .leading, relatedBy: .equal, toItem: tableView,
            attribute: .leading, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: titleLabel,
            attribute: .bottom, relatedBy: .equal, toItem: tableView,
            attribute: .top, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: closeButton,
            attribute: .top, relatedBy: .equal, toItem: tableView,
            attribute: .bottom, multiplier: 1.0, constant: 0))
    }

    fileprivate func updateUI() {
        let grayColor = UIColor(red: 198/255,
            green: 198/255, blue: 198/255, alpha: 1)
        self.containerView?.backgroundColor = UIColor.white
        self.containerView?.layer.borderColor = grayColor.cgColor
        self.containerView?.layer.borderWidth = 0.5
        self.containerView?.layer.cornerRadius = 15.0
        self.containerView?.clipsToBounds = true
        self.titleLabel?.text = "Select"
        self.doneButton?.setTitle("Done", for: .normal)
        self.closeButton?.setTitle("Close", for: .normal)
        
        self.doneButton?.titleLabel?.textAlignment = .center
        self.closeButton?.titleLabel?.textAlignment = .center
        self.titleLabel?.textAlignment = .center
        
        self.textColor = UIColor.white
        self.closeButtonColor = grayColor
        self.selectAllButtonColor = grayColor
        
        //let tintedImage = checkmark.withRenderingMode(.alwaysTemplate)
        self.selectAllButton?.setImage(unchecked, for: .normal)
        self.selectAllButton?.setImage(checked, for: .selected)
        self.selectAllButton?.imageView?.contentMode = .scaleAspectFit
        //self.selectAllButton?.tintColor = UIColor.green
        
        self.mainColor = UIColor(red: 75/255, green: 178/255,
            blue: 218/255, alpha: 1)
        self.titleFont = UIFont(name: "Helvetica-Bold", size: 15.0)
        self.buttonFont = UIFont(name: "Helvetica", size: 15.0)
        self.tableView?.separatorInset = UIEdgeInsets(
            top: 0, left: 0, bottom: 0, right: 0)
        self.tableView?.rowHeight = 50
        self.tableView?.separatorStyle = .none
    }
    
    open func show() {
        
        manageSelectAllState()
        
        guard let appDelegate = UIApplication.shared.delegate else {
            assertionFailure()
            return
        }
        guard let window = appDelegate.window else {
            assertionFailure()
            return
        }
        
        window?.addSubview(self)
        window?.bringSubview(toFront: self)
        window?.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0.0,
            usingSpringWithDamping: 0.7, initialSpringVelocity: 3.0,
            options: .allowAnimatedContent, animations: {
            self.containerView?.center = self.center
            self.tableView?.reloadData()
        }) { (isFinished) in
            self.layoutIfNeeded()
        }
    }
    
    @objc private func selectAllOption(sender: UIButton){
        sender.isSelected = !sender.isSelected
        
        var values = self.values
        switch self.selection {
        case .none: return
        case .single:return
        case .multiply:
            
            if sender.isSelected {
                for i in 0..<values.count {
                    values[i].isChecked = true
                }
            }else{
                for i in 0..<values.count {
                    values[i].isChecked = false
                }
            }
        }
        self.values = values
    }
    
    @objc private func done() {
        var indexes: [Int] = []
        for i in 0..<self.values.count {
            if self.values[i].isChecked {
                indexes.append(i)
            }
        }
        self.completion?(indexes)
        self.close()
    }
    
    @objc private func close() {
        UIView.animate(withDuration: 0.7, delay: 0.0,
            usingSpringWithDamping: 1, initialSpringVelocity: 1.0,
            options: .allowAnimatedContent, animations: {
            self.containerView?.center = CGPoint(x: self.center.x,
            y: self.center.y + self.frame.size.height)
        }) { (isFinished) in
            self.removeFromSuperview()
        }
    }
    
    //MARK: UITableViewDataSource methods
    
    public func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return self.values.count
    }
    
    public func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:
            self.tableViewCellIdentifier,
            for: indexPath) as? TCPickerTableViewCell else {
            assertionFailure("cell doesn't init")
            return UITableViewCell()
        }
        let value = self.values[indexPath.row]
        cell.viewModel = TCPickerTableViewCell.ViewModel(
            title: value.title,
            isChecked: value.isChecked,
            titleFont: self.itemsFont
        )
        return cell
    }
    
    //MARK: UITableViewDelegate methods
    
    public func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        var values = self.values
        switch self.selection {
            case .none: return
            case .single:
                for i in 0..<values.count {
                    values[i].isChecked = false
                }
                values[indexPath.row].isChecked = true
            case .multiply:
                values[indexPath.row].isChecked = !values[indexPath.row].isChecked
            //manageSelectAllState()
                var isAllSelected = true
                for i in 0..<values.count {
                    if values[i].isChecked == false {
                        isAllSelected = false
                    }
                }
                if isAllSelected{
                    self.selectAllButton?.isSelected = true
                }else{
                    self.selectAllButton?.isSelected = false
            }
            
        }
        self.values = values
        self.delegate?.pickerView(self, didSelectRowAtIndex: indexPath.row)
    }
    
    func manageSelectAllState(){
        var isAllSelected = true
        for i in 0..<values.count {
            if values[i].isChecked == false {
                isAllSelected = false
            }
        }
        if isAllSelected{
            self.selectAllButton?.isSelected = true
        }else{
            self.selectAllButton?.isSelected = false
        }
    }
}
