# Hướng dẫn đóng góp

Tuân thủ các hướng dẫn sau về cấu trúc dự án, code style và quản lý phiên bản.

## 1. Cấu trúc & kiến trúc dự án

Dự án này tuân theo phương pháp **Clean Architecture** với **MVVM** (Model-View-ViewModel). Codebase được chia thành ba lớp riêng biệt. Các thành viên nên đảm bảo các file mới được đặt đúng thư mục.

### `lib/domain` (business logic)
Lớp này chứa các business logic.
* **`entities/`**: Các object Dart thuần túy đại diện cho dữ liệu cốt lõi (ví dụ: `money_entity.dart`). Những file này không nên chứa logic chuyển đổi JSON.
* **`repositories/`**: Các abstract class (interface) định nghĩa hợp đồng cho các thao tác dữ liệu (ví dụ: `money_repository.dart`).

### `lib/data` (storage)
Lớp này xử lý việc truy xuất và lưu trữ dữ liệu.
* **`data_sources/`**: Logic truy cập dữ liệu cấp thấp (ví dụ: gọi API, service database cục bộ như `in_memory_service.dart`).
* **`repositories/`**: Các triển khai cụ thể (concrete implementations) của các interface được định nghĩa trong lớp Domain (ví dụ: `money_repository_impl.dart`).

### `lib/ui` (presentation)
Lớp này được tổ chức theo **tính năng** (ví dụ: `ui/money/`).
* **`*_view.dart`**: Các Flutter Widget và bố cục UI. File này chỉ nên xử lý việc hiển thị và các sự kiện tương tác của người dùng.
* **`*_view_model.dart`**: Xử lý quản lý trạng thái và logic cho view. Nó giao tiếp với lớp domain để lấy hoặc cập nhật dữ liệu.

---

## 2. Code style, formatting & linting

Duy trì code style nghiêm ngặt để đảm bảo tính nhất quán trên toàn bộ codebase.

### Trước khi commit
Bạn PHẢI chạy các công cụ format và lint chuẩn của Flutter trước khi commit.

1.  **Format code:**
    Chạy Dart formatter để tuân thủ nghiêm ngặt độ dài dòng và khoảng cách:
    ```bash
    dart format .
    ```

2.  **Lint / analyze:**
    Chạy analyzer để bắt các lỗi tĩnh và cảnh báo linting:
    ```bash
    flutter analyze
    ```

3.  **Quick fixes:**
    Để tự động sửa các lỗi lint đơn giản:
    ```bash
    dart fix --apply
    ```

**Lưu ý:** Nếu pull request của bạn không qua được CI, nó sẽ không được merge.

---

## 3. Quy trình Git & hướng dẫn commit

Giữ lịch sử Git sạch và dễ đọc.

### Commit message
* **Mô tả rõ ràng:** Mô tả rõ *cái gì* đã thay đổi và *tại sao* trong commit message.
* **Thể mệnh lệnh:** Sử dụng thể mệnh lệnh (ví dụ: "Add money view model" thay vì "Added..." hoặc "Adding...").

### Tránh "Uber-commits"
* **Atomic commits:** Không gộp nhiều thay đổi không liên quan vào một commit lớn.
* **Độ dễ review:** Các commit nhỏ, tập trung sẽ làm quá trình code review và bisect dễ hơn.

---

## 4. Quy trình tạo pull request

1.  Tự review code của mình trước.
2.  Xác minh `flutter analyze` không đưa lỗi.
3.  Thêm mô tả rõ ràng vào pull request giải thích các thay đổi.