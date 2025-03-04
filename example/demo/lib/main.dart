import 'package:flutter/material.dart';
import 'package:zeatmap/zeatmap.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('ZeatMap Example')),
        body: const ZeatMapExample(),
      ),
    );
  }
}

class ZeatMapExample extends StatefulWidget {
  const ZeatMapExample({super.key});

  @override
  State<ZeatMapExample> createState() => _ZeatMapExampleState();
}

class _ZeatMapExampleState extends State<ZeatMapExample> {
  /// Years available in the year dropdown
  final allowedYears = [2022, 2023, 2024, 2025];
  late List<DateTime> dates;
  int currentYear = DateTime.now().year;

  /// Categories/projects to display in the heatmap
  final List<String> rowHeaders = ['Project A', 'Project B', 'Project C'];

  // ZeatMap configuration options
  bool _scrollingEnabled = false;
  bool _showDay = true;
  bool _showWeek = false;
  bool _showMonth = true;
  bool _showYear = false;
  bool _showLegend = true;
  bool _highlightToday = true;
  bool _showYearDropdown = true;
  ZeatMapLegendPosition _legendPosition = ZeatMapLegendPosition.center;
  ZeatMapGranularity _granularity = ZeatMapGranularity.day;

  // Visual property controls
  double _itemSize = 30.0;
  double _itemBorderRadius = 5.0;
  double _columnSpacing = 8.0;
  double _rowSpacing = 8.0;

  @override
  void initState() {
    super.initState();
    _generateDatesForYear(currentYear);
  }

  void _generateDatesForYear(int year) {
    setState(() {
      currentYear = year;
      dates = List.generate(
        DateTime(year, 12, 31).difference(DateTime(year, 1, 1)).inDays + 1,
        (index) => DateTime(year, 1, 1).add(Duration(days: index)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final legendItems = [
      ZeatMapLegendItem(
        const Color.fromARGB(110, 221, 221, 221),
        'Weekday',
      ),
      ZeatMapLegendItem(
        const Color.fromARGB(110, 255, 131, 131),
        'Weekend',
      ),
    ];

    return Column(
      children: [
        Expanded(
          child: ZeatMap<String>(
            dates: dates,
            rowHeaders: rowHeaders,
            rowHeaderBuilder: (rowData) => Text(rowData,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            rowHeaderWidth: 100,
            scrollingEnabled: _scrollingEnabled,
            showDay: _showDay,
            showWeek: _showWeek,
            showMonth: _showMonth,
            showYear: _showYear,
            showLegend: _showLegend,
            highlightToday: _highlightToday,
            showYearDropdown: _showYearDropdown,
            legendPosition: _legendPosition,
            granularity: _granularity,
            itemSize: _itemSize,
            itemBorderRadius: _itemBorderRadius,
            columnSpacing: _columnSpacing,
            rowSpacing: _rowSpacing,
            headerTitle: 'Default Builder Example',
            years: allowedYears,
            legendItems: legendItems,
            onYearChanged: (year) {
              _generateDatesForYear(year);
            },
          ),
        ),
        _buildControlPanel(),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ZeatMap Controls',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16.0,
            runSpacing: 12.0,
            children: [
              _buildGranularityControl(),
              _buildToggle('Scrolling', _scrollingEnabled, (value) {
                setState(() => _scrollingEnabled = value);
              }),
              _buildToggle('Show Day', _showDay, (value) {
                setState(() => _showDay = value);
              }),
              _buildToggle('Show Week', _showWeek, (value) {
                setState(() => _showWeek = value);
              }),
              _buildToggle('Show Month', _showMonth, (value) {
                setState(() => _showMonth = value);
              }),
              _buildToggle('Show Year', _showYear, (value) {
                setState(() => _showYear = value);
              }),
              _buildToggle('Show Legend', _showLegend, (value) {
                setState(() => _showLegend = value);
              }),
              _buildToggle('Highlight Today', _highlightToday, (value) {
                setState(() => _highlightToday = value);
              }),
              _buildToggle('Year Dropdown', _showYearDropdown, (value) {
                setState(() => _showYearDropdown = value);
              }),
              _buildLegendPositionControl(),
              _buildPropertyControl('Item Size', _itemSize, 15.0, 50.0,
                  (value) {
                setState(() => _itemSize = value);
              }),
              _buildPropertyControl(
                  'Border Radius', _itemBorderRadius, 0.0, 25.0, (value) {
                setState(() => _itemBorderRadius = value);
              }),
              _buildPropertyControl('Column Spacing', _columnSpacing, 0.0, 20.0,
                  (value) {
                setState(() => _columnSpacing = value);
              }),
              _buildPropertyControl('Row Spacing', _rowSpacing, 0.0, 20.0,
                  (value) {
                setState(() => _rowSpacing = value);
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 8.0),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendPositionControl() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Legend Position'),
            const SizedBox(width: 8.0),
            DropdownButton<ZeatMapLegendPosition>(
              value: _legendPosition,
              onChanged: (ZeatMapLegendPosition? newValue) {
                setState(() {
                  if (newValue != null) {
                    _legendPosition = newValue;
                  }
                });
              },
              items: ZeatMapLegendPosition.values
                  .map((ZeatMapLegendPosition position) {
                return DropdownMenuItem<ZeatMapLegendPosition>(
                  value: position,
                  child: Text(position.toString().split('.').last),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyControl(String label, double value, double min,
      double max, ValueChanged<double> onChanged) {
    final TextEditingController controller =
        TextEditingController(text: value.toStringAsFixed(1));

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          SizedBox(
            width: 80, // Fixed narrow width for input field
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                hintText:
                    '${min.toStringAsFixed(1)} - ${max.toStringAsFixed(1)}',
              ),
              onSubmitted: (value) {
                double? newValue = double.tryParse(value);
                if (newValue != null) {
                  newValue = newValue.clamp(min, max);
                  controller.text = newValue.toStringAsFixed(1);
                  onChanged(newValue);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGranularityControl() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2.0,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Granularity'),
            const SizedBox(width: 8.0),
            DropdownButton<ZeatMapGranularity>(
              value: _granularity,
              onChanged: (ZeatMapGranularity? newValue) {
                setState(() {
                  if (newValue != null) {
                    _granularity = newValue;
                  }
                });
              },
              items: ZeatMapGranularity.values.map((ZeatMapGranularity gran) {
                return DropdownMenuItem<ZeatMapGranularity>(
                  value: gran,
                  child: Text(gran.toString().split('.').last),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
