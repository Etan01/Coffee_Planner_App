//
//  ThemeViewController.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 31/5/2023.
//  Reference:
//  1. ChatGPT - How to implement dark theme mode in Xcode?
//

import UIKit

let themeModeKey = "ThemeMode"
let toggleStateKey = "ToggleState"

class ThemeViewController: UIViewController {
    
    @IBOutlet weak var toggle: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene else {
                return
            }

        guard let window = windowScene.windows.first else{
            return
        }


        let savedThemeMode = UserDefaults.standard.string(forKey: themeModeKey)
        let savedToggleState = UserDefaults.standard.bool(forKey: toggleStateKey)

        if savedThemeMode == "Dark" {
            // Apply dark theme
            window.overrideUserInterfaceStyle = .dark
        } else {
            // Apply light theme
            window.overrideUserInterfaceStyle = .light
        }
        
        toggle.setOn(savedToggleState, animated:false)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.popViewController(animated: true)
    }
    

    /// Change theme color to the application
    @IBAction func changeDarkTheme(_ sender: Any) {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene else {
                return
            }

        guard let window = windowScene.windows.first else{
            return
        }
        
        let themeMode = (sender as AnyObject).isOn ? "Dark" : "Light"
        
        if themeMode == "Dark" {
            // Apply dark theme
            window.overrideUserInterfaceStyle = .dark
        } else {
            // Apply light theme
            window.overrideUserInterfaceStyle = .light
        }
        
        // MARK: Save the mode and status into userdefaults
        UserDefaults.standard.set(themeMode, forKey: themeModeKey)
        
        let toggleState = (sender as AnyObject).isOn
        UserDefaults.standard.set(toggleState, forKey: toggleStateKey)
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
