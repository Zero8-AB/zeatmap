# ZeatMap

ZeatMap is a Flutter package for creating customizable heatmaps with support for various date ranges and interactive features.

## Features

- Display data in a heatmap format with customizable rows and columns.
- Scroll to specific months or dates.
- Highlight the current day.
- Show legends for different data categories.
- Interactive items with tap, double-tap, long-press, and other gestures.

## Installation

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  zeatmap:
    git:
      url: [https://ZERO8AB@dev.azure.com/ZERO8AB/Flutter%20Libraries/_git/zeatmap](https://github.com/Zero8-AB/zeatmap.git)
      ref: main
```

Then run `flutter pub get` to install the package.

## Usage

Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:zeatmap/zeatmap.dart';
import 'package:zeatmap/zeatmap_item.dart';
import 'package:zeatmap/zeatmap_position.dart';
import 'package:zeatmap/zeat_map_legend_item.dart';

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
```

## API

### ZeatMap
| Function | Type | Description |
| --- | --- | --- |
| `dates` | `List<DateTime>` | List of dates to display in the heatmap. |
| `rowHeaders` | `List<T>` | List of row headers. |
| `rowHeaderBuilder` | `Widget Function(T rowData)` | Builder function for row headers. |
| `itemBuilder` | `ZeatMapItem<T> Function(int rowIndex, int columnIndex)?` | Builder function for heatmap items. |
| `dayBuilder` | `Container Function(DateTime date)?` | Builder function for day cells. |
| `legendItems` | `List<ZeatMapLegendItem>` | List of legend items. |
| `headerTitle` | `String?` | Title for the heatmap header. |
| `showDay` | `bool` | Whether to show day labels. |
| `showWeek` | `bool` | Whether to show week labels. |
| `showMonth` | `bool` | Whether to show month labels. |
| `showYear` | `bool` | Whether to show year labels. |
| `highlightToday` | `bool` | Whether to highlight the current day. |
| `showLegend` | `bool` | Whether to show the legend. |
| `rowSpacing` | `double` | Spacing between rows. |
| `columnSpacing` | `double` | Spacing between columns. |
| `itemSize` | `double` | Size of each heatmap item. |
| `itemBorderRadius` | `double` | Border radius of each heatmap item. |
| `onItemTapped` | `void Function(ZeatMapItem<T> item)?` | Callback for item tap gesture. |
| `onItemLongPressed` | `void Function(ZeatMapItem<T> item)?` | Callback for item long press gesture. |
| `onItemDoubleTapped` | `void Function(ZeatMapItem<T> item)?` | Callback for item double tap gesture. |
| `onItemTapDown` | `void Function(ZeatMapItem<T> item)?` | Callback for item tap down gesture. |
| `onItemTapCancel` | `void Function(ZeatMapItem<T> item)?` | Callback for item tap cancel gesture. |

### ZeatMapItem
| Property       | Type              | Description                          |
| -------------- | ----------------- | ------------------------------------ |
| `position`     | `ZeatMapPosition` | Position of the item in the grid.    |
| `rowData`      | `T?`              | Data associated with the row.        |
| `color`        | `Color?`          | Color of the item.                   |
| `date`         | `DateTime?`       | Date associated with the item.       |
| `extraData`    | `dynamic`         | Additional data for the item.        |
| `tooltipWidget`| `Widget?`         | Widget to display as a tooltip.      |

### ZeatMapLegendItem
| Property | Type   | Description            |
| -------- | ------ | ---------------------- |
| `color`  | `Color`| Color of the legend.   |
| `label`  | `String`| Label for the legend. |

### ZeatMapPosition
| Property | Type  | Description            |
| -------- | ----- | ---------------------- |
| `x`      | `int` | X-coordinate position. |
| `y`      | `int` | Y-coordinate position. |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
