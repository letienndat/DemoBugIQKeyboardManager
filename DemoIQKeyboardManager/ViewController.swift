//
//  ViewController.swift
//  DemoIQKeyboardManager
//
//  Created by Le Tien Dat on 20/6/25.
//

// MARK: Bug view header fixed bị đẩy lên (nằm dưới và bị navigation bar đè lên) khi sử dụng IQKeyboardManagerSwift
/// [STEP TÁI HIỆN]
/// [1] Focus input 0
/// [2] Scroll cuối dưới sao cho input đang được focus nằm ngoài phạm vi hiển thị của scrollview (scrollview visible)
/// [3] Bấm return ở bàn phím (để focus input tiếp theo)
/// => Input 1 được focus + view header fixed bị đẩy lên bởi IQKeyboardManagerSwift
///
/// [GIẢI PHÁP]
/// Disable IQKeyboardManagerSwift và xử lý hiển thị input được focus thủ công

import UIKit
import IQKeyboardManagerSwift

class ViewController: UIViewController {
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private var listTextFields: [UITextField]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()

        // Comment method này để tái hiện bug
        fixBug()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.printViewHierarchy()
    }
    
    private func setup() {
        listTextFields.enumerated().forEach {
            $1.delegate = self
            $1.placeholder = "Input \($0)"
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func fixBug() {
        IQKeyboardManager.shared.isEnabled = false
        addObserverKeyboard()
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func addObserverKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardShow(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
    }
    
    @objc
    private func keyboardHide() {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let index = listTextFields.firstIndex(of: textField) {
            let nextInput = listTextFields[safe: index + 1] ?? listTextFields[0]
            nextInput.becomeFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Offset của input so với scrollview
        let frameInScroll = textField.convert(textField.bounds, to: scrollView)
        
        // Height của scroll visible (phần view của scroll đang được hiển thị trên màn hình)
        let visibleHeight = scrollView.bounds.height - scrollView.adjustedContentInset.top - scrollView.adjustedContentInset.bottom
        
        // Offset lớn nhất mà scrollView có thể scroll tới được
        let maxOffsetCanScroll = scrollView.contentSize.height - visibleHeight

        // Offset min y của visible scrollView
        let minVisibleY = scrollView.contentOffset.y
        // Offset max y của visible scrollView
        let maxVisibleY = minVisibleY + visibleHeight

        // Offset min y của input
        let minY = frameInScroll.minY
        // Offset max y của input
        let maxY = frameInScroll.maxY

        // Kiểm tra nếu input nằm phía trên so với phần visible scrollView => Scroll lên
        if minY < minVisibleY {
            // Nếu input nằm trong khoảng trên cùng => Scroll về đầu luôn
            if maxY <= visibleHeight {
                scrollView.setContentOffset(.zero, animated: true)
            }
            // Còn không thì scroll đang không nằm trong khoảng trên cùng => Scroll tới vị trí của input
            else {
                scrollView.setContentOffset(.init(x: 0, y: minY - scrollView.adjustedContentInset.top), animated: true)
            }
        }
        // Nếu input nằm phía dưới so với phần visible scrollView => Scroll xuống
        else if maxY > maxVisibleY {
            // Lấy ra offset của input cần scroll đến
            let offset = minY - visibleHeight + scrollView.adjustedContentInset.bottom

            // Nếu offset của input nằm ở cuối cùng của scroll => Scroll xuống cuối cùng
            if offset > maxOffsetCanScroll {
                scrollView.setContentOffset(.init(x: 0, y: maxOffsetCanScroll), animated: true)
            }
            // Còn không thì scroll đang không nằm trong khoảng cuối cùng => Scroll tới vị trí của input
            else {
                scrollView.setContentOffset(.init(x: 0, y: offset), animated: true)
            }
        }
    }
}

extension UIView {
    func printViewHierarchy(indent: String = "") {
        print("\(indent)\(type(of: self)) frame: \(self.frame)")
        for subview in self.subviews {
            subview.printViewHierarchy(indent: indent + "├── ")
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
