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
    const zeatMapLegendItem = ZeatMapLegendItem(color, label);

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

  testWidgets('ZeatMap large dataset performance test', (WidgetTester tester) async {
    // Create a large dataset: 100 rows x 365 dates (1 year)
    final dates = List.generate(365, (i) => DateTime(2024, 1, 1).add(Duration(days: i)));
    final rowHeaders = List.generate(100, (i) => 'Row ${i + 1}');

    // Track itemBuilder calls to verify viewport optimization
    int itemBuilderCallCount = 0;

    await tester.pumpWidget(MaterialApp(
      home: ZeatMap<String>(
        dates: dates,
        rowHeaders: rowHeaders,
        rowHeaderBuilder: (data) => Text(data),
        itemBuilder: (row, col) {
          itemBuilderCallCount++;
          return ZeatMapItem(
            ZeatMapPosition(row, col),
            rowData: rowHeaders[row],
            color: row % 2 == 0 ? Colors.blue : Colors.green,
            date: dates[col],
          );
        },
      ),
    ));

    // Initial render should complete
    await tester.pumpAndSettle();

    // Verify the widget renders successfully
    expect(find.byType(Card), findsOneWidget);

    // With viewport optimization (100 dates threshold), not all 36,500 items should be built initially
    // The viewport optimization should significantly reduce the number of items built
    expect(itemBuilderCallCount, lessThan(36500),
        reason: 'Viewport optimization should reduce the number of items built');

    // Test that scrolling still works with large datasets
    final scrollFinder = find.byType(SingleChildScrollView).first;
    expect(scrollFinder, findsOneWidget);

    // Scroll horizontally
    await tester.drag(scrollFinder, const Offset(-500.0, 0.0));
    await tester.pumpAndSettle();

    // Verify we can still find row headers after scrolling
    expect(find.text('Row 1'), findsOneWidget);
  });

  testWidgets('ZeatMap aggregated dates caching test', (WidgetTester tester) async {
    // Test that aggregated dates are cached and not recalculated on every build
    final dates = List.generate(365, (i) => DateTime(2024, 1, 1).add(Duration(days: i)));
    final rowHeaders = ['Row 1', 'Row 2', 'Row 3'];

    final key = GlobalKey<ZeatMapState<String>>();

    await tester.pumpWidget(MaterialApp(
      home: ZeatMap<String>(
        key: key,
        dates: dates,
        rowHeaders: rowHeaders,
        rowHeaderBuilder: (data) => Text(data),
        granularity: ZeatMapGranularity.week,
      ),
    ));

    await tester.pumpAndSettle();

    // Get the state
    final state = key.currentState!;

    // Get aggregated dates
    final aggregated1 = state.aggregatedDates;
    expect(aggregated1.length, greaterThan(0));
    expect(aggregated1.length, lessThan(dates.length),
        reason: 'Week granularity should aggregate dates');

    // Get aggregated dates again (should use cache)
    final aggregated2 = state.aggregatedDates;
    expect(identical(aggregated1, aggregated2), isTrue,
        reason: 'Cached aggregated dates should return the same instance');

    // Verify aggregation works correctly for different granularities
    await tester.pumpWidget(MaterialApp(
      home: ZeatMap<String>(
        key: key,
        dates: dates,
        rowHeaders: rowHeaders,
        rowHeaderBuilder: (data) => Text(data),
        granularity: ZeatMapGranularity.month,
      ),
    ));

    await tester.pumpAndSettle();

    final aggregatedMonths = state.aggregatedDates;
    expect(aggregatedMonths.length, lessThan(aggregated1.length),
        reason: 'Month granularity should have fewer entries than week');
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
