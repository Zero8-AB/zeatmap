import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zeatmap/zeat_map_legend_item.dart';

import 'package:zeatmap/zeatmap_item.dart';
import 'package:zeatmap/zeatmap_position.dart';

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
}
