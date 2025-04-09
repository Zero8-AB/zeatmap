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
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
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
  // Constants for styling
  static const _controlPanelPadding = EdgeInsets.all(16.0);
  static const _controlSpacing = 16.0;
  static const _controlRunSpacing = 12.0;
  static final _controlDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8.0),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 2.0,
        spreadRadius: 0.0,
      ),
    ],
  );
  static const _controlPadding =
      EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);

  /// Years available in the year dropdown
  final List<int> allowedYears = [2022, 2023, 2024, 2025];
  late List<DateTime> dates;
  int currentYear = DateTime.now().year;

  /// Categories/projects to display in the heatmap
  final List<String> rowHeaders = ['Project A', 'Project B', 'Project C'];

  // ZeatMap configuration options
  bool _scrollingEnabled = false;
  bool _dragToScrollEnabled = true;
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

  // Store controllers to dispose them properly
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _generateDatesForYear(currentYear);
    _initControllers();
  }

  @override
  void dispose() {
    // Clean up controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initControllers() {
    _controllers['itemSize'] =
        TextEditingController(text: _itemSize.toStringAsFixed(1));
    _controllers['itemBorderRadius'] =
        TextEditingController(text: _itemBorderRadius.toStringAsFixed(1));
    _controllers['columnSpacing'] =
        TextEditingController(text: _columnSpacing.toStringAsFixed(1));
    _controllers['rowSpacing'] =
        TextEditingController(text: _rowSpacing.toStringAsFixed(1));
  }

  void _generateDatesForYear(int year) {
    // More efficient way to generate dates
    final startDate = DateTime(year, 1, 1);
    final endDate = DateTime(year, 12, 31);

    setState(() {
      currentYear = year;
      dates = List.generate(
        endDate.difference(startDate).inDays + 1,
        (index) => startDate.add(Duration(days: index)),
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
          flex: 3, // Give the ZeatMap more space
          child: _buildZeatMap(legendItems),
        ),
        Expanded(
          flex:
              2, // Allow the control panel to have some space but less than the map
          child: SingleChildScrollView(
            child: _buildControlPanel(),
          ),
        ),
      ],
    );
  }

  Widget _buildZeatMap(List<ZeatMapLegendItem> legendItems) {
    return ZeatMap<String>(
      dates: dates,
      rowHeaders: rowHeaders,
      rowHeaderBuilder: (rowData) => Text(
        rowData,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      rowHeaderWidth: 100,
      scrollingEnabled: _scrollingEnabled,
      dragToScrollEnabled: _dragToScrollEnabled,
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
      onYearChanged: _generateDatesForYear,
    );
  }

  Widget _buildControlPanel() {
    return Container(
      width: double.infinity, // Make the panel use full available width
      padding: _controlPanelPadding,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Only take needed space
        children: [
          const Text(
            'ZeatMap Controls',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildControlsGrid(),
        ],
      ),
    );
  }

  Widget _buildControlsGrid() {
    return Wrap(
      spacing: _controlSpacing,
      runSpacing: _controlRunSpacing,
      children: [
        _buildControlGroup('View Options', [
          _buildGranularityControl(),
          _buildToggle('Normal Scrolling', _scrollingEnabled, (value) {
            setState(() => _scrollingEnabled = value);
          }),
          _buildToggle('Drag to Scroll', _dragToScrollEnabled, (value) {
            setState(() => _dragToScrollEnabled = value);
          }),
        ]),
        _buildControlGroup('Header Options', [
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
          _buildToggle('Year Dropdown', _showYearDropdown, (value) {
            setState(() => _showYearDropdown = value);
          }),
        ]),
        _buildControlGroup('Legend Options', [
          _buildToggle('Show Legend', _showLegend, (value) {
            setState(() => _showLegend = value);
          }),
          _buildLegendPositionControl(),
          _buildToggle('Highlight Today', _highlightToday, (value) {
            setState(() => _highlightToday = value);
          }),
        ]),
        _buildControlGroup('Appearance', [
          _buildPropertyControl('Item Size', 'itemSize', _itemSize, 15.0, 50.0,
              (value) {
            setState(() => _itemSize = value);
          }),
          _buildPropertyControl(
              'Border Radius', 'itemBorderRadius', _itemBorderRadius, 0.0, 25.0,
              (value) {
            setState(() => _itemBorderRadius = value);
          }),
          _buildPropertyControl(
              'Column Spacing', 'columnSpacing', _columnSpacing, 0.0, 20.0,
              (value) {
            setState(() => _columnSpacing = value);
          }),
          _buildPropertyControl(
              'Row Spacing', 'rowSpacing', _rowSpacing, 0.0, 20.0, (value) {
            setState(() => _rowSpacing = value);
          }),
        ]),
      ],
    );
  }

  Widget _buildControlGroup(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      decoration: _controlDecoration,
      child: Padding(
        padding: _controlPadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            const SizedBox(width: 8.0),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendPositionControl() {
    return Container(
      decoration: _controlDecoration,
      child: Padding(
        padding: _controlPadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Position'),
            const SizedBox(width: 8.0),
            DropdownButton<ZeatMapLegendPosition>(
              value: _legendPosition,
              isDense: true,
              onChanged: (ZeatMapLegendPosition? newValue) {
                if (newValue != null) {
                  setState(() => _legendPosition = newValue);
                }
              },
              items: ZeatMapLegendPosition.values.map((position) {
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

  Widget _buildPropertyControl(String label, String controllerKey, double value,
      double min, double max, ValueChanged<double> onChanged) {
    final controller = _controllers[controllerKey]!;

    // Update controller if the value changed externally
    if (double.parse(controller.text) != value) {
      controller.text = value.toStringAsFixed(1);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10.0),
      decoration: _controlDecoration,
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
                final newValue = double.tryParse(value);
                if (newValue != null) {
                  final clampedValue = newValue.clamp(min, max);
                  controller.text = clampedValue.toStringAsFixed(1);
                  onChanged(clampedValue);
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
      decoration: _controlDecoration,
      child: Padding(
        padding: _controlPadding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Granularity'),
            const SizedBox(width: 8.0),
            DropdownButton<ZeatMapGranularity>(
              value: _granularity,
              isDense: true,
              onChanged: (ZeatMapGranularity? newValue) {
                if (newValue != null) {
                  setState(() => _granularity = newValue);
                }
              },
              items: ZeatMapGranularity.values.map((gran) {
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
