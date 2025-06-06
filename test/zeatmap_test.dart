import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeatmap/zeatmap.dart';

void main() {
  test('ZeatMapItem', () {
    final position = ZeatMapPosition(0, 0);
    const data = 'Row Data';
    const color = Colors.red;
    final date = DateTime.now();
    const tooltipWidget = Text('Tooltip Widget');
    final zeatMapItem = ZeatMapItem(position,
        rowData: data, color: color, date: date, tooltipWidget: tooltipWidget);

    expect(zeatMapItem.position, position);
    expect(zeatMapItem.rowData, data);
    expect(zeatMapItem.color, color);
    expect(zeatMapItem.date, date);
    expect(zeatMapItem.tooltipWidget, tooltipWidget);
  });

  test('ZeatMapLegendItem', () {
    const color = Colors.red;
    const label = 'Label';
    final zeatMapLegendItem = ZeatMapLegendItem(color, label);

    expect(zeatMapLegendItem.color, color);
    expect(zeatMapLegendItem.label, label);
  });

  testWidgets('ZeatMap widget tests', (WidgetTester tester) async {
    final dates = List.generate(10, (i) => DateTime(2024, 1, i + 1));
    final rowHeaders = ['Row 1', 'Row 2'];

    await tester.pumpWidget(MaterialApp(
      home: ZeatMap<String>(
        dates: dates,
        rowHeaders: rowHeaders,
        rowHeaderBuilder: (data) => Text(data),
        itemBuilder: (row, col) => ZeatMapItem(
          ZeatMapPosition(row, col),
          rowData: rowHeaders[row],
          color: Colors.blue,
          date: dates[col],
        ),
      ),
    ));

    expect(find.byType(Card), findsOneWidget);
    expect(find.text('ZeatMap'), findsOneWidget);

    // Test navigation buttons
    expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    // Test row headers
    expect(find.text('Row 1'), findsOneWidget);
    expect(find.text('Row 2'), findsOneWidget);

    // Test item grid
    expect(find.byType(GestureDetector),
        findsNWidgets(25)); // 2 rows * 10 columns + 4 navigation buttons

    // Test scrolling
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();
  });

  test('ZeatMap state methods', () {
    final state = ZeatMapState<String>();

    expect(state.getWeekNumber(DateTime(2024, 1, 1)), 1);
    expect(state.getWeekNumber(DateTime(2024, 1, 8)), 2);
    // Dates at the start of the year that belong to the previous year's last week
    expect(state.getWeekNumber(DateTime(2023, 1, 1)), 52);
    // Last days of the year can belong to the first week of the next year
    expect(state.getWeekNumber(DateTime(2020, 12, 31)), 53);
  });
}
