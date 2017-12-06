//
//  ChatListViewController.swift
//  Makestagram
//
//  Created by Matthew Patella on 12/4/17.
//  Copyright © 2017 Matthew Patella. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ChatListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var chats = [Chat]()
    
    var userChatHandle: DatabaseHandle = 0
    var userChatsRef: DatabaseReference?
    
    @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
        
        navigationController?.dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 71
        
        tableView.tableFooterView = UIView()
        
        userChatHandle = UserService.observeChats { [weak self] (ref, chats) in
            self?.userChatsRef = ref
            self?.chats = chats
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        // Do any additional setup after loading the view.
    }
    
    deinit {
        
        userChatsRef?.removeObserver(withHandle: userChatHandle)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChatListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell") as! ChatListCell
        let chat = chats[indexPath.row]
        cell.titleLabel.text = chat.title
        cell.lastMessageLabel.text = chat.lastMessage
        
        return cell
    }
}

extension ChatListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toChat", sender: self)
    }
}

extension ChatListViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "toChat",
        let destination = segue.destination as? ChatViewController,
        let indexPath = tableView.indexPathForSelectedRow {
            
            destination.chat = chats[indexPath.row]
        }
    }
}
