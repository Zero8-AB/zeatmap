# ZeatMap

[![pub package](https://img.shields.io/pub/v/zeatmap.svg)](https://pub.dev/packages/zeatmap)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A highly customizable Flutter heatmap widget for visualizing data across date ranges. Create interactive heatmaps with support for custom layouts, date navigation, and interactive features.

![ZeatMap Example](https://via.placeholder.com/800x400?text=ZeatMap+Screenshot)

## Features

- ✅ Flexible heatmap layouts with customizable rows and columns
- ✅ Date-based visualization with day, week, month, and year views
- ✅ Interactive cells with support for tap, double-tap, and long-press gestures
- ✅ Customizable legends for data categories
- ✅ Automatic highlighting of the current day
- ✅ Smooth scrolling through date ranges
- ✅ Fully customizable appearance including colors, spacing, and sizing

## Installation

Add ZeatMap to your `pubspec.yaml` file:

```yaml
dependencies:
  zeatmap: ^0.2.0
```

Or use the following for the latest development version:

```yaml
dependencies:
  zeatmap:
    git:
      url: https://github.com/Zero8-AB/zeatmap.git
      ref: main
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:flutter/material.dart';
import 'package:zeatmap/zeatmap.dart';

class SimpleHeatmapExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Generate dates for the past year
    final dates = List<DateTime>.generate(
      365,
      (index) => DateTime.now().subtract(Duration(days: 365 - index)),
    );
    
    // Define row headers
    final rowHeaders = ['Project A', 'Project B', 'Project C'];
    
    return Scaffold(
      appBar: AppBar(title: Text('ZeatMap Example')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ZeatMap<String>(
          dates: dates,
          rowHeaders: rowHeaders,
          rowHeaderBuilder: (rowData) => Text(
            rowData,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          itemBuilder: (rowIndex, columnIndex) {
            // Generate sample heatmap data
            final value = (rowIndex * columnIndex) % 3;
            final color = value == 0 
                ? Colors.green.shade300
                : value == 1 
                    ? Colors.orange.shade300 
                    : Colors.red.shade300;
            
            return ZeatMapItem(
              ZeatMapPosition(rowIndex, columnIndex),
              rowData: rowHeaders[rowIndex],
              color: color,
              date: dates[columnIndex],
              tooltipWidget: Text('Value: $value'),
            );
          },
          legendItems: [
            ZeatMapLegendItem(Colors.green.shade300, 'Low'),
            ZeatMapLegendItem(Colors.orange.shade300, 'Medium'),
            ZeatMapLegendItem(Colors.red.shade300, 'High'),
          ],
          headerTitle: 'Activity Heatmap',
          onItemTapped: (item) => print('Tapped: ${item.date}, ${item.rowData}'),
        ),
      ),
    );
  }
}
```

## Advanced Usage

### Custom Date Navigation

ZeatMap provides built-in navigation controls, but you can also programmatically control the view:

```dart
// Reference to the ZeatMap state
final zeatmapKey = GlobalKey<ZeatMapState>();

// Later in your code:
zeatmapKey.currentState?.scrollToMonth(1, 2024);
// Use `scrollToDate(DateTime(2024, 1, 1))` if you need to target an exact day.
zeatmapKey.currentState?.scrollToToday();
```

### Customizing Appearance

```dart
ZeatMap<String>(
  // Basic configuration
  dates: dates,
  rowHeaders: rowHeaders,
  rowHeaderBuilder: (data) => Text(data),
  itemBuilder: itemBuilder,
  
  // Styling options
  itemSize: 24.0,
  itemBorderRadius: 6.0,
  rowSpacing: 8.0,
  columnSpacing: 4.0,
  
  // Visibility options
  showDay: true,
  showMonth: true,
  showWeek: false,
  showYear: true,
  showLegend: true,
  highlightToday: true,
)
```

### Scrolling Options

```dart
ZeatMap<String>(
  // Basic configuration...
  
  // Scrolling options
  scrollingEnabled: true,  // Enable/disable normal scrolling with mouse wheel or touch swipe
  dragToScrollEnabled: true,  // Enable/disable click and drag scrolling
)
```

### Interactive Features

```dart
ZeatMap<String>(
  // Basic configuration...
  
  // Interaction callbacks
  onItemTapped: (item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Item Selected'),
        content: Text('Date: ${item.date}, Row: ${item.rowData}'),
      ),
    );
  },
  onItemLongPressed: (item) {
    // Handle long press
  },
  onItemDoubleTapped: (item) {
    // Handle double tap
  },
)
```

## API Reference

### ZeatMap

| Parameter | Type | Description |
|---|---|---|
| `dates` | `List<DateTime>` | **Required**. List of dates to display in the heatmap. |
| `rowHeaders` | `List<T>` | **Required**. List of row headers. |
| `rowHeaderBuilder` | `Widget Function(T rowData)` | **Required**. Builder function for row headers. |
| `itemBuilder` | `ZeatMapItem<T> Function(int rowIndex, int columnIndex)?` | Builder function for heatmap items. |
| `dayBuilder` | `Container Function(DateTime date)?` | Builder function for day cells. |
| `legendItems` | `List<ZeatMapLegendItem>?` | List of legend items. |
| `headerTitle` | `String?` | Title for the heatmap header. |
| `showDay` | `bool` | Whether to show day labels. Default: `true` |
| `showWeek` | `bool` | Whether to show week labels. Default: `true` |
| `showMonth` | `bool` | Whether to show month labels. Default: `true` |
| `showYear` | `bool` | Whether to show year labels. Default: `true` |
| `highlightToday` | `bool` | Whether to highlight the current day. Default: `true` |
| `showLegend` | `bool` | Whether to show the legend. Default: `true` |
| `rowSpacing` | `double` | Spacing between rows. Default: `4.0` |
| `columnSpacing` | `double` | Spacing between columns. Default: `2.0` |
| `itemSize` | `double` | Size of each heatmap item. Default: `16.0` |
| `itemBorderRadius` | `double` | Border radius of heatmap items. Default: `4.0` |
| `scrollingEnabled` | `bool` | Whether normal scrolling with mouse wheel or touch swipe is enabled. Default: `true` |
| `dragToScrollEnabled` | `bool` | Whether drag-to-scroll is enabled (click and drag horizontally). Default: `true` |
| `onItemTapped` | `void Function(ZeatMapItem<T> item)?` | Callback when item is tapped. |
| `onItemLongPressed` | `void Function(ZeatMapItem<T> item)?` | Callback when item is long-pressed. |
| `onItemDoubleTapped` | `void Function(ZeatMapItem<T> item)?` | Callback when item is double-tapped. |
| `onItemTapDown` | `void Function(ZeatMapItem<T> item)?` | Callback when tap starts on item. |
| `onItemTapCancel` | `void Function(ZeatMapItem<T> item)?` | Callback when tap is canceled. |

### ZeatMapItem

| Property | Type | Description |
|---|---|---|
| `position` | `ZeatMapPosition` | **Required**. Position of the item in the grid. |
| `rowData` | `T?` | Data associated with the row. |
| `color` | `Color?` | Color of the item. |
| `date` | `DateTime?` | Date associated with the item. |
| `extraData` | `dynamic` | Additional data for the item. |
| `tooltipWidget` | `Widget?` | Widget to display as a tooltip. |

### ZeatMapLegendItem

| Property | Type | Description |
|---|---|---|
| `color` | `Color` | **Required**. Color of the legend. |
| `label` | `String` | **Required**. Label for the legend. |

### ZeatMapPosition

| Property | Type | Description |
|---|---|---|
| `x` | `int` | X-coordinate position. |
| `y` | `int` | Y-coordinate position. |

## Compatibility

ZeatMap is compatible with:

* Flutter 2.5.0 or higher
* Dart 2.14.0 or higher

## Troubleshooting

### Common Issues

1. **Items not appearing**: Ensure your `itemBuilder` is properly returning `ZeatMapItem` objects for each position.
2. **Date navigation issues**: Verify that your `dates` list contains valid `DateTime` objects in chronological order.

### Getting Help

If you encounter any issues or have questions, please:

1. Check the [GitHub Issues](https://github.com/Zero8-AB/zeatmap/issues) for similar problems
2. Open a new issue with a detailed description and reproduction steps

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.