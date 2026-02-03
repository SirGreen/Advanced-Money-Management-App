import 'package:hive/hive.dart';

// ở đây tui có implement 1 cái class để xài Hive làm cái lưu trữ
// nó giống như cái hashmap nhưng ko mất data xuyên các lần chạy app

class HiveService {
  Future<Box> _getBox() async {
    // khởi tạo trước khi xài thôi

    // theo tui nhớ ko nhầm thì có thể tạo nhiều box đc
    // cho các scope/usecase khác nhau của ứng dụng
    return await Hive.openBox('moneyBox');
  }

  Future<int> read() async {
    final box = await _getBox();
    // ở đây thì lấy dữ liệu bằng key (ở đây là 'amount')
    // muốn lưu cái khác thì xài key khác hoặc scope khác thì
    // tạo box khác luôn (khi tạo box mới thì nên tạo nguyên cái service khác
    // vẫn xài hive nhưng mở box tên khác)

    return box.get('amount', defaultValue: 0);
  }

  Future<void> write(int amount) async {
    final box = await _getBox();

    // nói chung pattern khi làm ở layer này thì là
    // tạo/get box -> xài get(key) hoặc put(key, value) để nhập/xuất
    await box.put('amount', amount);
  }
}
