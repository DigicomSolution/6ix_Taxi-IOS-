//
//  FeedbackViewController.swift
//  TranxitUser
//
//  Created by Umair Khan on 09/07/2022.
//  Copyright © 2022 Appoets. All rights reserved.
//

import UIKit

class FeedbackViewController: UIViewController {

    @IBOutlet weak var feedbackTableView: ConfiguredTableView!
    @IBOutlet weak var feedbackView: UIView!
    @IBOutlet weak var mainTitleLabel: UILabel!
    @IBOutlet weak var mainDescriptionLabel: UILabel!
    @IBOutlet weak var submitBtn: Button!
    @IBOutlet weak var outerView: UIView!
    
    private var onAction: ((String)->Void)?
    
    // PROPERTIES
    
    // DATASOURCE
    var feedbackInterfaceData: FeedbackInterfaceData = FeedbackInterfaceData(mainTitle: "Title", mainDescription: "Description", submitBtnTitle: "Button")
    var feedbackOptions: [FeedbackOption] = []
    
    private var selectedOptionsIndexPath: IndexPath?
    
    //For Pan Gesture
    private var viewTranslation = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllerName = String.init(describing: self.classForCoder)
        print("VCName***: \(viewControllerName)")

        initialLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        UIView.animate(withDuration: 0.3, delay: 0.3, options: UIView.AnimationOptions.allowUserInteraction, animations: {
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
    }
    
    //For setting up view or other work on viewDidLoad
    private func initialLoad(){
        registerCustomCells()
        populateView()
        addGestureRecognizers()
        setupPanGestureOnAlertView()
    }
    
    private func registerCustomCells(){
        feedbackTableView.register(UINib(nibName: "FeedbackTableViewCell", bundle: nil), forCellReuseIdentifier: XIB.Names.feedbackCell)
    }
    
    private func populateView(){
        mainTitleLabel.text = feedbackInterfaceData.mainTitle
        mainDescriptionLabel.text = feedbackInterfaceData.mainDescription
        submitBtn.setTitle(feedbackInterfaceData.submitBtnTitle, for: .normal)
        
        submitBtn.backgroundColor = UIColor.lightGray
        submitBtn.isEnabled = false
        
    }
    
    //For handling touch to dismiss
    private func addGestureRecognizers(){
        outerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onOuterViewClick)))
    }
    
    @objc func onOuterViewClick(){
        self.dismiss(animated: true, completion: nil)
    }
    
    //For handling swipe to dismiss
    private func setupPanGestureOnAlertView(){
        feedbackView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(sender:))))
        outerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(sender:))))
    }
    
    //Swipe to dismiss handling method
    @objc private func handlePanGesture(sender: UIPanGestureRecognizer){
        
        switch sender.state {
            case .changed:
                
                viewTranslation = sender.translation(in: view)
    
                if viewTranslation.y < 0{ //If gesture is towards upward direction
                    
                    if abs(viewTranslation.y)+feedbackView.frame.size.height <= feedbackView.frame.size.height+24{ //If from top gesture reach this minimum distance then ignore new less minimum values for limiting view to speicifc point
                    
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [.curveEaseOut, .allowUserInteraction], animations: {
                            self.feedbackView.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                        })
                    }
                    
                }else{ //If gesture is towards downward direction
                    
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [.curveEaseOut, .allowUserInteraction], animations: {
                        self.feedbackView.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                    })
                }
            case .ended:
                
                if sender.velocity(in: view).y >= 450{ //If pan gesture move quickly and direction is downward
                    dismiss(animated: true, completion: nil)
                    return
                }
                
                
                if viewTranslation.y < (feedbackView.frame.size.height-(feedbackView.frame.size.height/2)) { //If from bottom, on ending gesture state, translation value is less then actionOptionViewSize-(half of actionOptionViewSize)
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: [.curveEaseOut, .allowUserInteraction], animations: {
                        self.feedbackView.transform = .identity
                    })
                } else {
                    dismiss(animated: true, completion: nil)
                }
            default:
                break
            }
    }
    
    func onAction(callback: @escaping (String)->Void) {
        onAction = callback
    }
    
    @IBAction func onSubmitClick(_ sender: Button) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else{
                return
            }
            self.onAction?(self.feedbackOptions[self.selectedOptionsIndexPath!.row].optionTitle)
        }
    }
    
    deinit {
        print("Deinit FeedbackVC")
    }
}

//TableView datasource and delegate for options
extension FeedbackViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: XIB.Names.feedbackCell, for: indexPath) as! FeedbackTableViewCell
        
        cell.populateData(optionData: feedbackOptions[indexPath.row], isSelected: selectedOptionsIndexPath == indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selectedOptionsIndexPath != nil{//Deselect previous selected
            let previousSelectedCell = tableView.cellForRow(at: selectedOptionsIndexPath!) as! FeedbackTableViewCell
            previousSelectedCell.updateIsOptionSelected(isSelected: false)
        }
        
        //Select current selection
        let currentSelectedCell = tableView.cellForRow(at: indexPath) as! FeedbackTableViewCell
        currentSelectedCell.updateIsOptionSelected(isSelected: true)
        
        selectedOptionsIndexPath = indexPath
        
        if #available(iOS 13.0, *) {
            submitBtn.backgroundColor = UIColor.label
        } else {
            submitBtn.backgroundColor = UIColor.black
        }
        submitBtn.isEnabled = true
    }
    
}


