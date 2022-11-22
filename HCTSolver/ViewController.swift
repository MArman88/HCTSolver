//
//  ViewController.swift
//  HCTSolver
//
//  Created by M Arman on 22/11/22.
//

import UIKit
import HCTSolverLib

class ViewController: UIViewController, UIColorPickerViewControllerDelegate {

    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var hundredBox: UIView!
    @IBOutlet weak var ninetyBox: UIView!
    @IBOutlet weak var eightyBox: UIView!
    @IBOutlet weak var seventyBox: UIView!
    @IBOutlet weak var sixtyBox: UIView!
    @IBOutlet weak var fiftyBox: UIView!
    @IBOutlet weak var fortyBox: UIView!
    @IBOutlet weak var thirtyBox: UIView!
    @IBOutlet weak var twentyBox: UIView!
    @IBOutlet weak var tenBox: UIView!
    @IBOutlet weak var zeroBox: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        preview.layer.cornerRadius = 24
        onColorApplied()
    }

    var selectedColor: UIColor = .systemGreen {
        didSet {
            onColorApplied()
        }
    }
    
    @IBAction func applyColorBtn(_ sender: Any) {
        let vc = UIColorPickerViewController()
        vc.selectedColor = selectedColor
        vc.delegate = self
        self.present(vc, animated: true)
    }
    
    func onColorApplied() {
        preview.backgroundColor = selectedColor
        
        guard let colorInt = selectedColor.toInt() else { return }
        zeroBox.backgroundColor = UIColor.fromInt(Hct.fromInt(colorInt).setTone(0).toInt())
        tenBox.backgroundColor = UIColor.fromInt(Hct.fromInt(colorInt).setTone(10).toInt())
        twentyBox.backgroundColor = UIColor.fromInt(Hct.fromInt(colorInt).setTone(20).toInt())
        thirtyBox.backgroundColor = UIColor.fromInt(Hct.fromInt(colorInt).setTone(30).toInt())
        fortyBox.backgroundColor = UIColor.fromInt(Hct.fromInt(colorInt).setTone(40).toInt())
        fiftyBox.backgroundColor = UIColor.fromInt(Hct.fromInt(colorInt).setTone(50).toInt())
        sixtyBox.backgroundColor = UIColor.fromInt(Hct.fromInt(colorInt).setTone(60).toInt())
        seventyBox.backgroundColor = UIColor.fromInt(Hct.fromInt(colorInt).setTone(70).toInt())
        eightyBox.backgroundColor = UIColor.fromInt(Hct.fromInt(colorInt).setTone(80).toInt())
        ninetyBox.backgroundColor = UIColor.fromInt(Hct.fromInt(colorInt).setTone(90).toInt())
        hundredBox.backgroundColor = UIColor.fromInt(Hct.fromInt(colorInt).setTone(100).toInt())
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        selectedColor = viewController.selectedColor
    }
}

