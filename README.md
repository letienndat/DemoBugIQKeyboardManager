# Bug view header fixed bị đẩy lên (nằm dưới và bị navigation bar đè lên) khi sử dụng IQKeyboardManagerSwift

https://github.com/user-attachments/assets/ba27afba-d565-4d36-9190-0e696f66b503

## [STEP TÁI HIỆN]
[1] Focus input 0<br>
[2] Scroll cuối dưới sao cho input đang được focus nằm ngoài phạm vi hiển thị của scrollview (scrollview visible)<br>
[3] Bấm return ở bàn phím (để focus input tiếp theo)<br>
=> Input 1 được focus + view header fixed bị đẩy lên bởi IQKeyboardManagerSwift

## [GIẢI PHÁP]
Disable IQKeyboardManagerSwift và xử lý hiển thị input được focus thủ công
