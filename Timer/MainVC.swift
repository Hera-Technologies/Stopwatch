//
//  ViewController.swift
//  Timer
//
//  Created by Lucas Andrade on 10/1/17.
//  Copyright © 2017 LGA. All rights reserved.
//

import UIKit
import CoreData

let dark = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 1)
fileprivate let cellID = "cell"

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var context: NSManagedObjectContext!
    var arr = [String]()
    var isRunning: Bool = false
    var timer: Timer?
    var min: Int = 0
    var sec: Int = 0
    var mili: Int = 0
    var timeStr: String?
    
// MARK: UI ELEMENTS
    
    let viewTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Stopwatch"
        lbl.textAlignment = .left
        lbl.font = UIFont(name: "Avenir-Black", size: 40)
        lbl.textColor = dark
        lbl.adjustsFontSizeToFitWidth = true
        lbl.minimumScaleFactor = 0.5
        return lbl
    }()
    
    let recordsBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "records"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let timeLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "00:00.00"
        lbl.font = UIFont(name: "Avenir", size: 80)
        lbl.textColor = dark
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    let resetBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Reset", for: .normal)
        btn.setTitleColor(dark, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 20)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let startBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Start", for: .normal)
        btn.setTitleColor(dark, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 20)
        btn.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        btn.layer.shadowColor = UIColor.gray.cgColor
        btn.layer.shadowOffset = CGSize(width: -1, height: 1.5)
        btn.layer.shadowRadius = 5
        btn.layer.shadowOpacity = 0.3
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let stopBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Stop", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 20)
        btn.backgroundColor = UIColor(red: 1, green: 94/255, blue: 98, alpha: 1)
        btn.layer.shadowColor = UIColor.gray.cgColor
        btn.layer.shadowOffset = CGSize(width: -1, height: 1.5)
        btn.layer.shadowRadius = 5
        btn.layer.shadowOpacity = 0.3
        btn.isHidden = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let table: UITableView = {
        let tb = UITableView()
        tb.backgroundColor = .clear
        tb.translatesAutoresizingMaskIntoConstraints = false
        return tb
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        setup()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
// MARK: UI SETUP
    
    func setup() {
        
        view.addSubview(viewTitle)
        view.addSubview(recordsBtn)
        view.addSubview(timeLbl)
        view.addSubview(resetBtn)
        view.addSubview(startBtn)
        view.addSubview(stopBtn)
        view.addSubview(table)
        
        let lblY = view.frame.height * 0.2
        timeLbl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        timeLbl.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -lblY).isActive = true
    
        viewTitle.frame = CGRect(x: 20, y: view.frame.height * 0.08, width: view.frame.width * 0.75, height: 50)
        
        recordsBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        recordsBtn.centerYAnchor.constraint(equalTo: viewTitle.centerYAnchor).isActive = true 
        recordsBtn.addTarget(self, action: #selector(showRecords), for: .touchUpInside)
        
        resetBtn.leadingAnchor.constraint(equalTo: timeLbl.leadingAnchor).isActive = true
        resetBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        resetBtn.addTarget(self, action: #selector(resetTimer), for: .touchUpInside)
        
        let size: CGFloat = 90
        startBtn.trailingAnchor.constraint(equalTo: timeLbl.trailingAnchor).isActive = true
        startBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        startBtn.widthAnchor.constraint(equalToConstant: size).isActive = true
        startBtn.heightAnchor.constraint(equalToConstant: size).isActive = true
        startBtn.layer.cornerRadius = size / 2
        startBtn.addTarget(self, action: #selector(startTimer), for: .touchUpInside)

        stopBtn.trailingAnchor.constraint(equalTo: timeLbl.trailingAnchor).isActive = true
        stopBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stopBtn.widthAnchor.constraint(equalToConstant: size).isActive = true
        stopBtn.heightAnchor.constraint(equalToConstant: size).isActive = true
        stopBtn.layer.cornerRadius = size / 2
        stopBtn.addTarget(self, action: #selector(stopTimer), for: .touchUpInside)
        
        table.topAnchor.constraint(equalTo: startBtn.bottomAnchor, constant: 30).isActive = true
        table.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        table.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        table.tableFooterView = UIView()
        table.register(LapCell.self, forCellReuseIdentifier: cellID)
        table.delegate = self
        table.dataSource = self
        
    }
    
    @objc func showRecords() {
        navigationController?.pushViewController(RecordsVC(), animated: true)
    }
    
// MARK: TIMER METHODS
    
    @objc func startTimer() {
        if isRunning == false {
            timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
                self.updateLabel()
                self.startBtn.isHidden = true
                self.stopBtn.isHidden = false
                self.resetBtn.setTitle("Lap", for: .normal)
            })
        }
        isRunning = !isRunning
    }
    
    func updateLabel() {
        mili += 1
        if mili == 100 {
            sec += 1
            mili = 0
        }
        if sec == 60 {
            min += 1
            sec = 0
        }
        let miliStr = mili > 9 ? "\(mili)" : "0\(mili)"
        let secStr = sec > 9 ? "\(sec)" : "0\(sec)"
        let minStr = min > 9 ? "\(min)" : "0\(min)"
        timeStr = "\(minStr):\(secStr).\(miliStr)"
        timeLbl.text = timeStr
    }
    
    @objc func stopTimer() {
        timer?.invalidate()
        stopBtn.isHidden = true
        startBtn.isHidden = false
        resetBtn.setTitle("Reset", for: .normal)
        isRunning = !isRunning
    }
    
    @objc func resetTimer() {
        if isRunning == false {
            min = 0
            sec = 0
            mili = 0
            timeStr = "00:00.00"
            timeLbl.text = timeStr
            arr = []
            table.reloadData()
        } else {
            arr.insert(timeLbl.text!, at: 0)
            table.reloadData()
        }
    }
    
// MARK: TABLEVIEW DELEGATE AND DATA SOURCE

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! LapCell
        cell.lapTimeLbl.text = arr[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let cell = tableView.cellForRow(at: indexPath) as! LapCell
        let save = UITableViewRowAction(style: .normal, title: "save") { (action, index) in
            do {
                let lap = Lap(context: self.context)
                lap.time = cell.lapTimeLbl.text!
                lap.date = Date()
                try self.context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
        save.backgroundColor = UIColor(red: 106/255, green: 130/255, blue: 251/255, alpha: 1)
        let delete = UITableViewRowAction(style: .destructive, title: "delete") { (action, index) in
            self.arr.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        return [save, delete]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height * 0.08
    }

// MARK: TABLEVIEW CELL
    
    class LapCell: UITableViewCell {
        
        let lapLbl: UILabel = {
            let lbl = UILabel()
            lbl.text = "Lap"
            lbl.font = UIFont(name: "Avenir-Roman", size: 20)
            lbl.textColor = .gray
            lbl.translatesAutoresizingMaskIntoConstraints = false
            return lbl
        }()
        
        let lapTimeLbl: UILabel = {
            let lbl = UILabel()
            lbl.font = UIFont(name: "Avenir-Heavy", size: 20)
            lbl.textColor = dark
            lbl.translatesAutoresizingMaskIntoConstraints = false
            return lbl
        }()
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .default, reuseIdentifier: cellID)
            
            backgroundColor = .clear
            addSubview(lapLbl)
            addSubview(lapTimeLbl)
            
            lapLbl.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
            lapLbl.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
            lapTimeLbl.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
            lapTimeLbl.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }

}









