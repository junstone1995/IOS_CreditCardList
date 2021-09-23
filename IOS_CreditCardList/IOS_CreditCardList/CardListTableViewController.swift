//
//  CardListTableViewController.swift
//  IOS_CreditCardList
//
//  Created by Junseok Lee on 2021/09/16.
//

import UIKit
import Kingfisher
import FirebaseDatabase

class CardListTableViewController: UITableViewController {
    var ref: DatabaseReference!

    var creditCardList: [CreditCard] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UITableView Cell Register
        let nibName = UINib(nibName: "CardListTableViewCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CardListTableViewCell")
        
        ref = Database.database().reference()
        
        ref.observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: [String:Any]] else { return }
            
            do {
                let jsondata = try JSONSerialization.data(withJSONObject: value)
                let carddata = try JSONDecoder().decode([String: CreditCard].self, from: jsondata)
                let cardList = Array(carddata.values)
                self.creditCardList = cardList.sorted{$0.rank < $1.rank}
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error{
                print("Error Json parsing")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditCardList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardListTableViewCell", for: indexPath) as? CardListTableViewCell else { return UITableViewCell()}
        
        cell.rankLabel.text = "\(creditCardList[indexPath.row].rank)위"
        cell.promotionLabel.text = "\(creditCardList[indexPath.row].promotionDetail.amount)만원 증정 "
        cell.cardNameLabel.text = "\(creditCardList[indexPath.row].name)"
        
        let imageURL = URL(string: creditCardList[indexPath.row].cardImageURL)
        cell.cardImageView.kf.setImage(with: imageURL)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //상세 화면 전달
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let detailViewController = storyboard.instantiateViewController(identifier: "CardDetailViewController") as? CardDetailViewController else { return }
        
        detailViewController.promotionDetail = creditCardList[indexPath.row].promotionDetail
        self.show(detailViewController, sender: nil)
        
        //option 1
        let cardID = creditCardList[indexPath.row].id
//        ref.child("Item\(cardID)/isSelected").setValue(true)
        
        //option 2
//        ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value){[weak self] snapshot in
//            guard let self = self,
//            let value = snapshot.value as? [String:[String:Any]],
//            let key = value.keys.first else { return }
//
//            self.ref.child("\(key)/isSelected").setValue(true)
//        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            //option 1
            let cardID = creditCardList[indexPath.row].id
            ref.child("Item\(cardID)").removeValue()
            
            //option 2
//            ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value){[weak self] snapshot in
//                guard let self = self,
//                      let value = snapshot.value as? [String:[String:Any]],
//                      let key = value.keys.first else { return }
//                self.ref.child(key).removeValue()
//            }
        }
    }
}
