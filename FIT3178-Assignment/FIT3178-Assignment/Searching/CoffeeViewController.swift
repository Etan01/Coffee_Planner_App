//
//  CoffeeViewController.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 02/05/2023.
//

import UIKit

class CoffeeViewController: UIViewController {

    var currentCoffee: CoffeeData?

    @IBOutlet weak var coffeeDescription: UILabel!
    @IBOutlet weak var coffeeImage: UIImageView!
    @IBOutlet weak var ingredientsText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentCoffee = currentCoffee else {
            return
        }
        
        coffeeDescription.text = currentCoffee.coffeeDescription
        coffeeDescription.adjustsFontSizeToFitWidth = true
        coffeeDescription.minimumScaleFactor = 0.8
        
        let myArray: [String]? = currentCoffee.ingredients
        
        var labelString = "["
        if let array = myArray{
            let lastIndex = array.count - 1
            for (index, item) in array.enumerated() {
                labelString += "\(item)"
                if index != lastIndex{
                    labelString += ", "
                }
            }
        }
        labelString += "]"
        
        ingredientsText.text = labelString
        navigationItem.title = currentCoffee.title

        // MARK: Download imageURL and display into imageView
        if let cover = currentCoffee.imageURL{
            
            let url = URL(string: cover)
            var comps = URLComponents(url: url!, resolvingAgainstBaseURL: false)
            comps?.scheme = "https"
            let data = try? Data(contentsOf: (comps?.url)!)
            coffeeImage.image = UIImage(data: data!)
        }
        
        // Do any additional setup after loading the view.
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
