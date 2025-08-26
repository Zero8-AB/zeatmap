import 'package:flutter/material.dart';
import 'package:zeatmap/zeatmap.dart';

/// Performance demonstration app for ZeatMap with large datasets
class PerformanceDemo extends StatefulWidget {
  const PerformanceDemo({super.key});

  @override
  State<PerformanceDemo> createState() => _PerformanceDemoState();
}

class _PerformanceDemoState extends State<PerformanceDemo> {
  List<DateTime> dates = [];
  List<String> rowHeaders = [];
  String currentDatasetSize = 'Small';
  bool isBuilding = false;

  @override
  void initState() {
    super.initState();
    _generateSmallDataset();
  }

  void _generateSmallDataset() {
    setState(() {
      isBuilding = true;
      currentDatasetSize = 'Small';
    });

    // 10 rows × 30 days = 300 cells
    dates = List.generate(30, (i) => DateTime(2024, 1, i + 1));
    rowHeaders = List.generate(10, (i) => 'Project ${String.fromCharCode(65 + i)}');

    setState(() {
      isBuilding = false;
    });
  }

  void _generateMediumDataset() {
    setState(() {
      isBuilding = true;
      currentDatasetSize = 'Medium';
    });

    // 25 rows × 365 days = 9,125 cells
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 12, 31);
    dates = List.generate(
      endDate.difference(startDate).inDays + 1,
      (i) => startDate.add(Duration(days: i)),
    );
    rowHeaders = List.generate(25, (i) => 'Team ${i + 1}');

    setState(() {
      isBuilding = false;
    });
  }

  void _generateLargeDataset() {
    setState(() {
      isBuilding = true;
      currentDatasetSize = 'Large';
    });

    // 50 rows × 365 days = 18,250 cells
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2024, 12, 31);
    dates = List.generate(
      endDate.difference(startDate).inDays + 1,
      (i) => startDate.add(Duration(days: i)),
    );
    rowHeaders = List.generate(50, (i) => 'Department ${i + 1}');

    setState(() {
      isBuilding = false;
    });
  }

  void _generateExtraLargeDataset() {
    setState(() {
      isBuilding = true;
      currentDatasetSize = 'Extra Large';
    });

    // 100 rows × 730 days (2 years) = 73,000 cells
    final startDate = DateTime(2024, 1, 1);
    final endDate = DateTime(2025, 12, 31);
    dates = List.generate(
      endDate.difference(startDate).inDays + 1,
      (i) => startDate.add(Duration(days: i)),
    );
    rowHeaders = List.generate(100, (i) => 'Entity ${i + 1}');

    setState(() {
      isBuilding = false;
    });
  }

  Color _getColorForCell(int row, int col) {
    // Generate pseudo-random colors based on position
    final hash = (row * 37 + col * 17) % 100;
    if (hash < 20) return Colors.red[300]!;
    if (hash < 40) return Colors.orange[300]!;
    if (hash < 60) return Colors.yellow[300]!;
    if (hash < 80) return Colors.green[300]!;
    return Colors.blue[300]!;
  }

  @override
  Widget build(BuildContext context) {
    final cellCount = dates.length * rowHeaders.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ZeatMap Performance Demo'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Text(
                  'Performance Test: $currentDatasetSize Dataset',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${rowHeaders.length} rows × ${dates.length} columns = ${cellCount.toStringAsFixed(0)} cells',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDatasetButton('Small', '300 cells', _generateSmallDataset),
                    _buildDatasetButton('Medium', '9.1K cells', _generateMediumDataset),
                    _buildDatasetButton('Large', '18.3K cells', _generateLargeDataset),
                    _buildDatasetButton('Extra Large', '73K cells', _generateExtraLargeDataset),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Test scrolling performance with each dataset size. '
                  'Notice how performance remains smooth even with 73,000+ cells!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: isBuilding
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Generating dataset...'),
                      ],
                    ),
                  )
                : ZeatMap<String>(
                    dates: dates,
                    rowHeaders: rowHeaders,
                    rowHeaderBuilder: (data) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    itemBuilder: (row, col) => ZeatMapItem(
                      ZeatMapPosition(row, col),
                      rowData: rowHeaders[row],
                      color: _getColorForCell(row, col),
                      date: dates[col],
                      tooltipWidget: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rowHeaders[row],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Date: ${dates[col].toString().split(' ')[0]}'),
                            Text('Position: Row $row, Col $col'),
                          ],
                        ),
                      ),
                    ),
                    onItemTapped: (item) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tapped: ${item.rowData} at ${item.date?.toString().split(' ')[0]}',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    itemSize: 20,
                    columnSpacing: 1,
                    rowSpacing: 1,
                    rowHeaderWidth: 120,
                    headerTitle: 'Performance Test Grid',
                    legendItems: [
                      ZeatMapLegendItem(Colors.red[300]!, 'High Activity'),
                      ZeatMapLegendItem(Colors.orange[300]!, 'Medium Activity'),
                      ZeatMapLegendItem(Colors.yellow[300]!, 'Low Activity'),
                      ZeatMapLegendItem(Colors.green[300]!, 'Normal'),
                      ZeatMapLegendItem(Colors.blue[300]!, 'Inactive'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatasetButton(String label, String description, VoidCallback onPressed) {
    final isSelected = currentDatasetSize == label;
    
    return ElevatedButton(
      onPressed: isBuilding ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue[700] : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            description,
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    title: 'ZeatMap Performance Demo',
    home: PerformanceDemo(),
    debugShowCheckedModeBanner: false,
  ));
}