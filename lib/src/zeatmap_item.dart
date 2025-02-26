import 'package:flutter/material.dart';
import 'package:zeatmap/src/zeatmap_position.dart';

class ZeatMapItem<T> {
  ZeatMapPosition position;
  T? rowData;
  Color? color;
  DateTime? date;
  dynamic extraData;

  Widget? tooltipWidget;

  ZeatMapItem(this.position,
      {this.date,
      this.color = Colors.transparent,
      this.rowData,
      this.extraData,
      this.tooltipWidget});
}
