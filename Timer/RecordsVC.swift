//
//  RecordsVC.swift
//  Timer
//
//  Created by Lucas Andrade on 10/1/17.
//  Copyright © 2017 LGA. All rights reserved.
//

import UIKit
import CoreData

fileprivate let cellID = "cell"

class RecordsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var context: NSManagedObjectContext!
    var arr = [Lap]()
    
    let backBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    let viewTitle: UILabel = {
        let lbl = UILabel()
        lbl.text = "Previous Records"
        lbl.textAlignment = .center
        lbl.font = UIFont(name: "Avenir-Black", size: 25)
        lbl.textColor = dark
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
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
        fetchLaps()
    }
    
    // MARK: UI SETUP
    
    func fetchLaps() {
        let request: NSFetchRequest<Lap> = Lap.fetchRequest()
        do {
            arr = try context.fetch(request)
            DispatchQueue.main.async { self.table.reloadData() }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func setup() {
        
        view.addSubview(backBtn)
        view.addSubview(viewTitle)
        view.addSubview(table)
        
        let titleY = view.frame.height * 0.4
        viewTitle.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -titleY).isActive = true
        viewTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        backBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        backBtn.centerYAnchor.constraint(equalTo: viewTitle.centerYAnchor).isActive = true
        backBtn.widthAnchor.constraint(equalToConstant: 12).isActive = true
        backBtn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        backBtn.addTarget(self, action: #selector(back), for: .touchUpInside)
        
        table.topAnchor.constraint(equalTo: viewTitle.bottomAnchor, constant: 30).isActive = true
        table.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        table.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        table.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        table.tableFooterView = UIView()
        table.register(DetailCell.self, forCellReuseIdentifier: cellID)
        table.delegate = self
        table.dataSource = self
        
    }
    
    @objc func back() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: TABLEVIEW DELEGATE AND DATA SOURCE
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DetailCell
        cell.lapTimeLbl.text = arr[indexPath.row].time
        let date = arr[indexPath.row].date
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let dateStr = formatter.string(from: date!)
        cell.dateLbl.text = dateStr
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "delete") { (action, index) in
            self.context.delete(self.arr[indexPath.row])
            do {
                try self.context.save()
                self.arr.remove(at: indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            } catch {
                print(error.localizedDescription)
            }
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height * 0.08
    }
    
    // MARK: TABLEVIEW CELL
    
    class DetailCell: UITableViewCell {
        
        let dateLbl: UILabel = {
            let lbl = UILabel()
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
            addSubview(dateLbl)
            addSubview(lapTimeLbl)
            
            dateLbl.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
            dateLbl.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
            lapTimeLbl.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
            lapTimeLbl.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
}
