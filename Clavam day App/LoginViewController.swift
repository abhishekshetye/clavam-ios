//
//  LoginViewController.swift
//  Clavam day App
//
//  Created by abhishek on 3/18/17.
//  Copyright © 2017 abhishek. All rights reserved.
//

import UIKit
import FirebaseDatabase


class LoginViewController: UIViewController, UITextViewDelegate {

    
    @IBOutlet weak var me: UITextField!
    
    @IBOutlet weak var mob: UITextField!
    
    @IBOutlet weak var hq: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        let preferences = UserDefaults.standard
        
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        if preferences.object(forKey: "OPENED") == nil {
            preferences.set(1, forKey: "OPENED")
        } else {
            preferences.set(preferences.integer(forKey: "OPENED") + 1, forKey: "OPENED")
        }
        
        if preferences.object(forKey: "FIRST") == nil {
            
        } else {
            print("here")
            opened()
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "mainvc") as!
            ViewController
            self.present(nextViewController, animated:true, completion:nil)
            
        }

    }
    
    func opened(){
        let preferences = UserDefaults.standard
        if preferences.object(forKey: "KEY") == nil {
            
        } else {
         
            let ref = FIRDatabase.database().reference().child("users").child(preferences.string(forKey: "KEY")!).child("opened")
            ref.setValue(preferences.integer(forKey: "OPENED"))
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
                // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = text.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return text == numberFiltered
    }
    
    
    
    @IBAction func submit(_ sender: Any) {
        let name = self.me.text
        let mob = self.mob.text
        let hqs = self.hq.text
        
        if(name == nil || name?.characters.count == 0){
            let alert = UIAlertController(title: "Error", message: "ME field cannot be empty.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        
        
        if(mob == nil || mob?.characters.count != 10){
            let alert = UIAlertController(title: "Error", message: "Invalid mobile number. It should be of 10 digits.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        
        
        if(hqs == nil || hqs?.characters.count == 0){
            let alert = UIAlertController(title: "Error", message: "Headquarter field cannot be empty.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            return;
        }
        
        //upload to firebase
        let dict = ["me": name, "mobile": mob, "the_headquarter": hqs, "device": "ios", "opened": 0] as [String : Any]
        
        let ref = FIRDatabase.database().reference().child("users").childByAutoId()

        
        ref.setValue(dict) { (error, ref) in
            
            if(error == nil ){
                
                let preferences = UserDefaults.standard
                //save 
                preferences.set("YES", forKey:"FIRST" )
                
                //  Save to disk
                let didSave = preferences.synchronize()
                
                if !didSave {
                    //  Couldn't save (I've never seen this happen in real world testing)
                    print("Couldnt save..")
                }

                //save
                preferences.set(ref.key, forKey:"KEY" )
                
                preferences.synchronize()

                
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "mainvc") as!
                ViewController
                self.present(nextViewController, animated:true, completion:nil)

            }else{
                
            }
            
        }
        
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
