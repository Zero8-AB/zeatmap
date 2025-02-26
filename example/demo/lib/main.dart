import 'package:flutter/material.dart';
import 'package:zeatmap/zeatmap.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('ZeatMap Example')),
        body: ZeatMapExample(),
      ),
    );
  }
}

class ZeatMapExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dates = List<DateTime>.generate(
      365,
      (index) => DateTime.now().subtract(Duration(days: index)),
    ).reversed.toList();

    final rowHeaders = ['Row 1', 'Row 2', 'Row 3'];

    final legendItems = [
      ZeatMapLegendItem(Colors.red, 'High'),
      ZeatMapLegendItem(Colors.yellow, 'Medium'),
      ZeatMapLegendItem(Colors.green, 'Low'),
    ];

    return ZeatMap<String>(
      dates: dates,
      rowHeaders: rowHeaders,
      rowHeaderBuilder: (rowData) => Text(rowData),
      itemBuilder: (rowIndex, columnIndex) {
        final position = ZeatMapPosition(rowIndex, columnIndex);
        final date = dates[columnIndex];
        final color = rowIndex == 0
            ? Colors.red
            : rowIndex == 1
                ? Colors.yellow
                : Colors.green;
        return ZeatMapItem<String>(
          position,
          rowData: rowHeaders[rowIndex],
          color: color,
          date: date,
        );
      },
      legendItems: legendItems,
      headerTitle: 'ZeatMap Example',
    );
  }
}
