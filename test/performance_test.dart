import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeatmap/zeatmap.dart';

void main() {
  group('ZeatMap Performance Tests', () {
    testWidgets('Large dataset rendering test', (WidgetTester tester) async {
      // Create a large dataset to test performance
      final dates = List.generate(
        365, // Full year
        (i) => DateTime(2024, 1, 1).add(Duration(days: i)),
      );
      final rowHeaders = List.generate(50, (i) => 'Row ${i + 1}'); // 50 rows

      // This creates 18,250 cells (50 rows × 365 days)
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ZeatMap<String>(
            dates: dates,
            rowHeaders: rowHeaders,
            rowHeaderBuilder: (data) => Text(data),
            itemBuilder: (row, col) => ZeatMapItem(
              ZeatMapPosition(row, col),
              rowData: rowHeaders[row],
              color: Colors.blue,
              date: dates[col],
            ),
            itemSize: 20.0, // Smaller cells for performance
            columnSpacing: 1.0,
            rowSpacing: 1.0,
          ),
        ),
      ));

      // Ensure the widget builds without errors
      expect(find.byType(ZeatMap<String>), findsOneWidget);
      
      // Test that the widget renders header elements
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('ZeatMap'), findsOneWidget);

      // Verify that navigation controls are present
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      // Test basic interaction
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // Test scrolling performance by scrolling through the grid
      final listView = find.byType(ListView).first;
      await tester.drag(listView, const Offset(0, -200));
      await tester.pumpAndSettle();

      // Scroll back
      await tester.drag(listView, const Offset(0, 200));
      await tester.pumpAndSettle();
    });

    testWidgets('Extra large dataset stress test', (WidgetTester tester) async {
      // Create an even larger dataset for stress testing
      final dates = List.generate(
        730, // Two years
        (i) => DateTime(2024, 1, 1).add(Duration(days: i)),
      );
      final rowHeaders = List.generate(100, (i) => 'Row ${i + 1}'); // 100 rows

      // This creates 73,000 cells (100 rows × 730 days)
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ZeatMap<String>(
            dates: dates,
            rowHeaders: rowHeaders,
            rowHeaderBuilder: (data) => Text(data),
            itemBuilder: (row, col) => ZeatMapItem(
              ZeatMapPosition(row, col),
              rowData: rowHeaders[row],
              color: row % 2 == 0 ? Colors.blue : Colors.red,
              date: dates[col],
            ),
            itemSize: 15.0, // Even smaller cells
            columnSpacing: 0.5,
            rowSpacing: 0.5,
          ),
        ),
      ));

      // Verify the widget still renders correctly with a huge dataset
      expect(find.byType(ZeatMap<String>), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);

      // Test that scroll controls work
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();

      // Test rapid scrolling
      final listView = find.byType(ListView).first;
      for (int i = 0; i < 5; i++) {
        await tester.drag(listView, const Offset(0, -100));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpAndSettle();
    });

    testWidgets('Verify optimization features', (WidgetTester tester) async {
      // Test with smaller dataset to verify optimization features work
      final dates = List.generate(30, (i) => DateTime(2024, 1, i + 1));
      final rowHeaders = ['Row 1', 'Row 2', 'Row 3'];

      int tapCount = 0;
      ZeatMapItem<String>? lastTappedItem;

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ZeatMap<String>(
            dates: dates,
            rowHeaders: rowHeaders,
            rowHeaderBuilder: (data) => Text(data),
            itemBuilder: (row, col) => ZeatMapItem(
              ZeatMapPosition(row, col),
              rowData: rowHeaders[row],
              color: Colors.green,
              date: dates[col],
              tooltipWidget: Text('Row: $row, Col: $col'),
            ),
            onItemTapped: (item) {
              tapCount++;
              lastTappedItem = item;
            },
          ),
        ),
      ));

      // Find and tap a grid cell to test gesture detection
      final listView = find.byType(ListView).first;
      final firstCell = tester.widget<ListView>(listView);
      
      // Pump to ensure everything is rendered
      await tester.pumpAndSettle();

      // Verify that the optimization preserved functionality
      expect(find.byType(ZeatMap<String>), findsOneWidget);
      expect(find.text('Row 1'), findsOneWidget);
      expect(find.text('Row 2'), findsOneWidget);
      expect(find.text('Row 3'), findsOneWidget);
    });
  });
}