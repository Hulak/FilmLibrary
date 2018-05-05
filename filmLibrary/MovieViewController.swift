

import UIKit
import os.log

class MovieViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UITextFieldDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var genreTextField: UITextField!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var movie: Movie?
    var searchedMovie: Movie?
    
    var genrePickerView = UIPickerView()
    var yearPickerView = UIPickerView()
    
    let minYear = 1950
    
    var genres = ["Action", "Adventure", "Comedy", "Crime & Gangsters", "Drama", "Historical", "Horror", "Musicals/Dance", "Science fiction", "War", "Westerns"]
    var years: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        genrePickerView.delegate = self
        genrePickerView.dataSource = self
        
        genreTextField.inputView = genrePickerView
        genreTextField.textAlignment = .left
        genreTextField.placeholder = "Select genre"
        
        yearTextField.inputView = yearPickerView
        yearTextField.textAlignment = .left
        yearTextField.placeholder = "Select year of production"
        
        if years.isEmpty {
            var year = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!.component(.year, from: NSDate() as Date)
            for _ in 1...50 {
                years.append(year)
                year -= 1
            }
        }
        
        yearPickerView.delegate = self
        yearPickerView.dataSource = self
        
        genrePickerView.dataSource = self
        genrePickerView.delegate = self
        
        descriptionTextView.returnKeyType = .done
        descriptionTextView.delegate = self
        
        titleTextField.returnKeyType = .done
        titleTextField.delegate = self
        
        if let movie = movie {
            titleTextField.text = movie.title
            yearTextField.text = movie.yearOfProduction
            genreTextField.text = movie.genre
            posterImageView.image = movie.poster
            descriptionTextView.text = movie.descr
            navigationItem.title = titleTextField.text
        }
        if descriptionTextView.text.isEmpty || descriptionTextView.text == "Enter description" {
            descriptionTextView.text = "Enter description"
            descriptionTextView.textColor = UIColor.lightGray
        } else {
            descriptionTextView.textColor = UIColor.black
        }
        updateSaveButtonState()
    }
    
    // Select image from library
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as?
            UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        posterImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    //pickerViews genres and years
    
    func getCurrentYear() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        return year
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
    }
    
    func textFieldShouldReturn (_ textField: UITextField) -> Bool {
        if yearTextField.isFirstResponder {
            yearTextField.resignFirstResponder()
        }
        if genreTextField.isFirstResponder {
            genreTextField.resignFirstResponder()
        }
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == genrePickerView {
            return genres.count
        } else if pickerView == yearPickerView {
            return years.count
        }
        return 0
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow
        row: Int, forComponent component: Int) -> String? {
        if pickerView == genrePickerView {
            return "\(genres[row])"
        } else if pickerView == yearPickerView {
            return "\(years[row])"
        }
        return ""
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == genrePickerView {
            genreTextField.text = "\(genres[row])"
            genreTextField.resignFirstResponder()
        } else if pickerView == yearPickerView {
            yearTextField.text = "\(years[row])"
            yearTextField.resignFirstResponder()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        descriptionTextView.resignFirstResponder()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter description" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter description"
            textView.textColor = UIColor.lightGray
        }
        textView.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Navigation
    @IBAction func cancel(_ sender: UIBarButtonItem) {
   
        let isPresentingInAddMovieMode = presentingViewController is UINavigationController
        if isPresentingInAddMovieMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The MovieViewController is not inside a navigation controller.")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let title = titleTextField.text ?? ""
        let poster = posterImageView.image
        let genre = genreTextField.text ?? ""
        let year = yearTextField.text ?? ""
        let description = descriptionTextView.text ?? ""
        
        movie = Movie.init(title: title, genre: genre, yearOfProduction: year, poster: poster, description: description)
    }
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = titleTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
}

