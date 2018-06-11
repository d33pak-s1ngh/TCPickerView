//
//  ViewController.swift
//  TCPickerView
//
//  Created by Taras Chernyshenko on 9/4/17.
//  Copyright © 2017 Taras Chernyshenko. All rights reserved.
//

import UIKit
import TCPickerView

class ViewController: UIViewController, TCPickerViewDelegate {
    func pickerView(_ pickerView: TCPickerView,
        cellForRowAt indexPath: IndexPath) -> (UITableViewCell & TCPickerCellType)? {
        let cell = pickerView.dequeueReusableCell(withIdentifier: "ExampleTableViewCell", for: indexPath)
        return cell
    }
    

    @IBAction private func showButtonPressed(button: UIButton) {
        let picker = TCPickerView()
        picker.title = "Cars"
        let cars = [
            "Chevrolet Bolt EV",
            "Subaru WRX",
            "Porsche Panamera",
            "BMW 330e",
            "Chevrolet Volt",
            "Ford C-Max Hybrid",
            "Ford Focus"
        ]
        let values = cars.map { TCPickerView.Value(title: $0) }
        picker.values = values
        picker.delegate = self
        picker.itemsFont = UIFont.systemFont(ofSize: 15, weight: .bold)
        picker.selection = .single
        picker.register(UINib(nibName: "ExampleTableViewCell", bundle: nil), forCellReuseIdentifier: "ExampleTableViewCell")
        picker.completion = { (selectedIndexes) in
            for i in selectedIndexes {
                print(values[i].title)
            }
        }
        picker.show()
    }
    
    //MARK: TCPickerViewDelegate methods
    
    func pickerView(_ pickerView: TCPickerView, didSelectRowAtIndex index: Int) {
        print("Uuser select row at index: \(index)")
    }
}

