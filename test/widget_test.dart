// Test cơ bản cho app đọc truyện
import 'package:flutter_test/flutter_test.dart';
import 'package:webdoctruyen/main.dart';

void main() {
  testWidgets('App khởi chạy thành công', (WidgetTester tester) async {
    await tester.pumpWidget(const TruyenHayApp());
    // Kiểm tra app khởi chạy không lỗi
    expect(find.byType(TruyenHayApp), findsOneWidget);
  });
}
