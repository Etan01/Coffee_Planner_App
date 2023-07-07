//
//  AboutUsViewController.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 31/5/2023.
//

import UIKit

class AboutUsViewController: UIViewController {

    @IBOutlet weak var AboutUsText: UILabel!
    
    
    var aboutText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        aboutText = """
        Welcome to Coffee Planner!\
        
        \nAt Cafe Planner, we strive to provide a seamless experience for coffee lovers who want to monitor their beverage expenses and discover the nearby cafes in their area. Our app is designed to enhance your cafe-going experience.\
        \n
        \nTrack Your Expenses \
        \nWith this app, you can easily track your spendings on beverages wth the help of Coffee Planner. You may keep a record of your spending and visits to a cafe, the drinks you had and the amount you spent. User can obtain a clear picture of cafe expenses in this app \
        \n
        \nTechnologies Used: \
        \n1. Utilises Persistent Storage (Week 4)
        \n   - Tools: Core Data & User Defaults
        \n   - Purpose:
        \n        Core Data: Store data locally into Persistent Storage so that it can be accessed offline
        \n        User Default: To store small amounts of data quickly
        \n   - License:
        \n        MuticastDelegate is distributed under the Apache License 2.0
        \n        Reference: https://lms.monash.edu/mod/resource/view.php?id=11398189
        \n
        \n2. Firebase Cloud Platform (Week 6)
        \n   - Purpose: To handle user authentication and save individual expenses
        \n   - License:
        \n        Firebase is distributed under the Apache License 2.0, which is an open source license:
        \n        Reference: https://github.com/firebase/firebase-ios-sdk/blob/master/LICENSE
        \n
        \n3. Maps and Location Services (Week 7)
        \n   - Purpose: To handle user location and retrieve nearby cafes
        \n   - Tools: Apple Map Kit
        \n
        \n4. Web Services (Week 5)
        \n   - Purpose: To fetch useful information from public resources
        \n   - Tools:
        \n      1. Yelp API:
        \n        License: https://www.yelp.com/developers/api_terms
        \n      2. Sample API
        \n        License: Free Open Source
        \n
        """
                
        AboutUsText.text = aboutText
        AboutUsText.numberOfLines = aboutText.count

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.popViewController(animated: true)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
