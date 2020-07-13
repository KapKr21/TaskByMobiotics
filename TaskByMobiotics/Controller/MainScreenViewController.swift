//
//  MainViewController.swift
//  TaskByMobiotics
//
//  Created by Kap's on 10/07/20.
//

import UIKit
import Alamofire
import GoogleSignIn
import AlamofireImage

class MainScreenViewController: UIViewController {
    
    var modelData       = [DataModel]()
    var id              = [String]()
    var urlData         = [String]()
    var thumbData       = [String]()
    var titleData       = [String]()
    var descriptionData = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        makeDataRequest()
        setDefaults()
    }
    
    func makeDataRequest() {
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)
        dispatchQueue.async {
            let videoRequest = DataRequest()
            videoRequest.getVideos() { [weak self] result in
                switch result {
                case .failure(let error) :
                    print(error)
                case .success(let data):
                    for modelData in data {
                        self?.id.append(modelData.id)
                        self?.urlData.append(modelData.url)
                        self?.thumbData.append(modelData.thumb)
                        self?.titleData.append(modelData.title)
                        self?.descriptionData.append(modelData.description)
                        self?.modelData.append(modelData)
                    }
                    semaphore.signal()
                }
            }
        }
        semaphore.wait()
    }
    
    func setDefaults() {
        UserDefaults.standard.setValue(id, forKey: "id")
        UserDefaults.standard.setValue(urlData, forKey: "urlData")
        UserDefaults.standard.setValue(thumbData, forKey: "thumbData")
        UserDefaults.standard.setValue(titleData, forKey: "titleData")
        UserDefaults.standard.setValue(descriptionData, forKey: "descriptionData")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MainScreenVC" {
            let detailVC = segue.destination as! DetailViewController
            detailVC.videoData = (sender as? DataModel)!
        }
    }
    
    // MARK: - Actions
    @IBAction func googleSignoutButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        
        //Correctly handle the signout here
        
        if GIDSignIn.sharedInstance()?.currentUser == nil {
            let alert = UIAlertController(title: "Message", message: "Signed out successfully", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default ) { (_) -> Void in
                self.dismiss(animated: true, completion: nil)
            })
            
            present(alert, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Message", message: "An error occured while signin out", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Table View Extension
extension MainScreenViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thumbData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! VideoDataCell
        cell.videoTitle?.text = titleData[indexPath.row]
        cell.videoDescription?.text = descriptionData[indexPath.row]
        
        Alamofire.request("\(thumbData[indexPath.row])").responseImage { response in
            if case .success(let image) = response.result {
                cell.videoImage.image = image
            } else {
                print("Could not load image")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = modelData[indexPath.row]
        performSegue(withIdentifier: "MainScreenVC", sender: data)
    }
}
