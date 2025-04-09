import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zeatmap/src/zeatmap_legend_item.dart';
import 'package:zeatmap/src/zeatmap_item.dart';
import 'package:intl/intl.dart';
import 'package:zeatmap/src/zeatmap_position.dart';

/// Defines the horizontal alignment of the legend within the ZeatMap.
enum ZeatMapLegendPosition {
  start, // Aligns the legend to the left
  center, // Centers the legend horizontally
  end, // Aligns the legend to the right
}

/// Defines the time granularity for displaying data in the ZeatMap.
/// This affects how dates are aggregated and displayed.
enum ZeatMapGranularity {
  day, // Shows individual days
  week, // Aggregates data by week
  month, // Aggregates data by month
  year // Aggregates data by year
}

/// A customizable heatmap widget that displays data over time periods.
///
/// ZeatMap allows you to visualize data in a grid format where:
/// - Rows represent different categories or entities
/// - Columns represent time periods (days, weeks, months, or years)
/// - Cell colors indicate data intensity or state
///
/// Example usage:
/// ```dart
/// ZeatMap<String>(
///   dates: datesList,
///   rowHeaders: ['Project A', 'Project B'],
///   rowHeaderBuilder: (data) => Text(data),
///   itemBuilder: (row, col) => ZeatMapItem(...),
///   granularity: ZeatMapGranularity.day,
/// )
/// ```
class ZeatMap<T> extends StatefulWidget {
  /// The list of dates to display in the heatmap.
  /// These dates determine the columns of the grid.
  final List<DateTime> dates;

  /// The list of row headers.
  /// Each header represents a row in the heatmap.
  final List<T> rowHeaders;

  /// Vertical spacing between rows in the heatmap.
  final double rowSpacing;

  /// Horizontal spacing between columns in the heatmap.
  final double columnSpacing;

  /// Size of each cell in the heatmap grid.
  final double itemSize;

  /// Border radius for each cell in the grid.
  final double itemBorderRadius;

  /// Whether to show the day labels above the heatmap.
  final bool showDay;

  /// Whether to show week numbers above the heatmap.
  final bool showWeek;

  /// Whether to show month names above the heatmap.
  final bool showMonth;

  /// Whether to show year numbers above the heatmap.
  final bool showYear;

  /// Whether to display the year dropdown in the header for quick navigation.
  final bool showYearDropdown;

  /// Whether to highlight the current day in the heatmap.
  final bool highlightToday;

  /// List of legend items to display below the heatmap.
  final List<ZeatMapLegendItem> legendItems;

  /// Whether to show the legend below the heatmap.
  final bool showLegend;

  /// Controls the horizontal alignment of the legend.
  final ZeatMapLegendPosition legendPosition;

  /// Builder function for creating row header widgets.
  /// This allows custom styling and layout of row headers.
  final Widget Function(T rowData) rowHeaderBuilder;

  /// Builder function for creating heatmap cell items.
  /// If not provided, a default implementation will be used.
  final ZeatMapItem<T> Function(int rowIndex, int columnIndex)? itemBuilder;

  /// Builder function for creating day label widgets.
  /// If not provided, a default implementation will be used.
  final Widget Function(DateTime date)? dayBuilder;

  /// Title displayed in the header of the heatmap.
  final String? headerTitle;

  /// Width of the row header column.
  final double rowHeaderWidth;

  /// Background color of the card containing the heatmap.
  final Color? cardColor;

  /// Whether horizontal scrolling is enabled on the heatmap.
  final bool scrollingEnabled;

  /// Optional list of years to show in the dropdown.
  /// If not provided, years will be extracted from dates.
  final List<int>? years;

  /// Optional parameter to set the initially selected year.
  /// If not provided, defaults to current year or first available year.
  final int? selectedYear;

  /// Callback when a cell is tapped.
  final void Function(ZeatMapItem<T> item)? onItemTapped;

  /// Callback when a cell is long-pressed.
  final void Function(ZeatMapItem<T> item)? onItemLongPressed;

  /// Callback when a cell is double-tapped.
  final void Function(ZeatMapItem<T> item)? onItemDoubleTapped;

  /// Callback when a cell receives a tap down event.
  final void Function(ZeatMapItem<T> item)? onItemTapDown;

  /// Callback when a cell tap is cancelled.
  final void Function(ZeatMapItem<T> item)? onItemTapCancel;

  /// Callback when the selected year changes.
  final void Function(int year)? onYearChanged;

  /// The time granularity for displaying and aggregating data.
  final ZeatMapGranularity granularity;

  const ZeatMap({
    super.key,
    required this.dates,
    required this.rowHeaders,
    required this.rowHeaderBuilder,
    this.rowHeaderWidth = 150,
    this.itemBuilder,
    this.dayBuilder,
    this.legendItems = const [],
    this.showDay = true,
    this.showMonth = true,
    this.showWeek = false,
    this.showYear = false,
    this.showYearDropdown = true,
    this.highlightToday = true,
    this.showLegend = true,
    this.legendPosition = ZeatMapLegendPosition.center,
    this.granularity = ZeatMapGranularity.day,
    this.rowSpacing = 8,
    this.columnSpacing = 8,
    this.itemSize = 30,
    this.itemBorderRadius = 5.0,
    this.scrollingEnabled = true,
    this.onItemTapped,
    this.onItemLongPressed,
    this.onItemDoubleTapped,
    this.onItemTapDown,
    this.onItemTapCancel,
    this.onYearChanged,
    this.headerTitle,
    this.cardColor,
    this.years,
    this.selectedYear,
  });

  @override
  ZeatMapState<T> createState() => ZeatMapState<T>();

  /// Scrolls the heatmap to display a specific month and year.
  ///
  /// Example:
  /// ```dart
  /// zeatMapKey.currentState?.scrollToMonth(3, 2024); // Scroll to March 2024
  /// ```
  void scrollToMonth(BuildContext context, int month, int year) {
    final state = context.findAncestorStateOfType<ZeatMapState<T>>();
    state?.scrollToMonth(month, year);
  }
}

class ZeatMapState<T> extends State<ZeatMap<T>> {
  final ScrollController _scrollController = ScrollController();
  late int currentMonth;
  late int currentYear;
  late List<int> _availableYears;

  /// Get the text to display in the header's date label based on granularity
  String get headerDateText {
    switch (widget.granularity) {
      case ZeatMapGranularity.day:
        return DateFormat("MMMM").format(DateTime(currentYear, currentMonth));
      case ZeatMapGranularity.week:
        final firstVisibleDate = aggregatedDates.firstWhere(
          (date) =>
              date.year == currentYear &&
              getWeekNumber(date) == _currentWeekNumber,
          orElse: () => DateTime(currentYear, currentMonth, 1),
        );
        final weekEnd = firstVisibleDate.add(const Duration(days: 6));
        return '${DateFormat("MMM d").format(firstVisibleDate)} - ${DateFormat("MMM d").format(weekEnd)}';
      case ZeatMapGranularity.month:
        return DateFormat("MMMM yyyy")
            .format(DateTime(currentYear, currentMonth));
      case ZeatMapGranularity.year:
        return currentYear.toString();
    }
  }

  /// Check if previous navigation is available based on granularity
  bool get hasPrevious {
    switch (widget.granularity) {
      case ZeatMapGranularity.day:
        return _currentDayIndex > 0;
      case ZeatMapGranularity.week:
        return _currentWeekIndex > 0;
      case ZeatMapGranularity.month:
        return currentMonth > 1;
      case ZeatMapGranularity.year:
        return _availableYears.indexOf(currentYear) > 0;
    }
  }

  /// Check if next navigation is available based on granularity
  bool get hasNext {
    switch (widget.granularity) {
      case ZeatMapGranularity.day:
        return _currentDayIndex < widget.dates.length - 1;
      case ZeatMapGranularity.week:
        return _currentWeekIndex < _aggregateByWeek().length - 1;
      case ZeatMapGranularity.month:
        return currentMonth < 12;
      case ZeatMapGranularity.year:
        return _availableYears.indexOf(currentYear) <
            _availableYears.length - 1;
    }
  }

  // Additional navigation properties for days
  int _currentDayIndex = 0;

  // Additional navigation properties for weeks
  int _currentWeekIndex = 0;
  int _currentWeekNumber = 1;

  void scrollToPreviousDay() {
    if (_currentDayIndex > 0) {
      _currentDayIndex--;
      final date = widget.dates[_currentDayIndex];
      currentMonth = date.month;
      currentYear = date.year;
      scrollToDate(date);
    }
  }

  void scrollToNextDay() {
    if (_currentDayIndex < widget.dates.length - 1) {
      _currentDayIndex++;
      final date = widget.dates[_currentDayIndex];
      currentMonth = date.month;
      currentYear = date.year;
      scrollToDate(date);
    }
  }

  void scrollToPreviousWeek() {
    if (_currentWeekIndex > 0) {
      _currentWeekIndex--;
      final weekStartDates = _aggregateByWeek();
      final date = weekStartDates[_currentWeekIndex];
      _currentWeekNumber = getWeekNumber(date);
      currentMonth = date.month;
      currentYear = date.year;
      scrollToDate(date);
    }
  }

  void scrollToNextWeek() {
    if (_currentWeekIndex < _aggregateByWeek().length - 1) {
      _currentWeekIndex++;
      final weekStartDates = _aggregateByWeek();
      final date = weekStartDates[_currentWeekIndex];
      _currentWeekNumber = getWeekNumber(date);
      currentMonth = date.month;
      currentYear = date.year;
      scrollToDate(date);
    }
  }

  void scrollToPreviousMonth() {
    if (currentMonth > 1) {
      int previousMonth = currentMonth - 1;
      scrollToMonth(previousMonth, currentYear);
    }
  }

  void scrollToNextMonth() {
    if (currentMonth < 12) {
      int nextMonth = currentMonth + 1;
      scrollToMonth(nextMonth, currentYear);
    }
  }

  void scrollToPreviousYear() {
    final currentYearIndex = _availableYears.indexOf(currentYear);
    if (currentYearIndex > 0) {
      final previousYear = _availableYears[currentYearIndex - 1];
      _setYear(previousYear);
    }
  }

  void scrollToNextYear() {
    final currentYearIndex = _availableYears.indexOf(currentYear);
    if (currentYearIndex < _availableYears.length - 1) {
      final nextYear = _availableYears[currentYearIndex + 1];
      _setYear(nextYear);
    }
  }

  /// Scroll to a specific date
  void scrollToDate(DateTime date) {
    if (!mounted) return;
    final dates = widget.dates;
    final targetIndex = dates.indexWhere(
      (d) => d.year == date.year && d.month == date.month && d.day == date.day,
      0,
    );

    if (targetIndex >= 0) {
      double offset = targetIndex * (widget.itemSize + widget.columnSpacing);

      _scrollController
          .animateTo(
        offset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      )
          .then((_) {
        if (!mounted) return;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() {
            _currentDayIndex = targetIndex;
          });
        });
      });
    }
  }

  void navigateToPrevious() {
    switch (widget.granularity) {
      case ZeatMapGranularity.day:
        scrollToPreviousDay();
        break;
      case ZeatMapGranularity.week:
        scrollToPreviousWeek();
        break;
      case ZeatMapGranularity.month:
        scrollToPreviousMonth();
        break;
      case ZeatMapGranularity.year:
        scrollToPreviousYear();
        break;
    }
  }

  void navigateToNext() {
    switch (widget.granularity) {
      case ZeatMapGranularity.day:
        scrollToNextDay();
        break;
      case ZeatMapGranularity.week:
        scrollToNextWeek();
        break;
      case ZeatMapGranularity.month:
        scrollToNextMonth();
        break;
      case ZeatMapGranularity.year:
        scrollToNextYear();
        break;
    }
  }

  @override
  void initState() {
    super.initState();

    // Initialize to the current date by default
    final now = DateTime.now();
    currentMonth = now.month;

    // Calculate the available years from the available dates
    _updateDateBoundaries();

    // Determine the initial year based on provided parameters
    if (widget.selectedYear != null &&
        _availableYears.contains(widget.selectedYear)) {
      // Use the explicitly provided year if it's in the available years
      currentYear = widget.selectedYear!;
    } else {
      // Otherwise use current year if available, or first available year
      currentYear = _availableYears.contains(now.year)
          ? now.year
          : _availableYears.isNotEmpty
              ? _availableYears.first
              : now.year;
    }

    // Initialize the indices based on the current date
    if (widget.dates.isNotEmpty) {
      _currentDayIndex = widget.dates.indexWhere(
        (date) =>
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day,
      );
      if (_currentDayIndex < 0) {
        _currentDayIndex = 0; // Default to first date if current date not found
      }

      final weekStartDates = _aggregateByWeek();
      _currentWeekNumber = getWeekNumber(now);
      _currentWeekIndex = weekStartDates.indexWhere(
        (date) =>
            getWeekNumber(date) == _currentWeekNumber && date.year == now.year,
      );
      if (_currentWeekIndex < 0) {
        _currentWeekIndex =
            0; // Default to first week if current week not found
      }
    }

    // Scroll to the initialized month and year
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      scrollToMonth(currentMonth, currentYear);
    });
  }

  @override
  void didUpdateWidget(covariant ZeatMap<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Recalculate date boundaries if dates changed
    if (oldWidget.dates != widget.dates) {
      _updateDateBoundaries();
    }

    // Automatically scroll to currentMonth when widget updates (e.g., new dates provided)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      scrollToMonth(currentMonth, currentYear);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Update the year boundaries and get all available years from dates
  void _updateDateBoundaries() {
    if (widget.dates.isEmpty) {
      _availableYears = [DateTime.now().year];
      return;
    }

    // If years are explicitly provided, use them
    if (widget.years != null && widget.years!.isNotEmpty) {
      _availableYears = List<int>.from(widget.years!)..sort();
    } else {
      // Otherwise extract years from the dates
      _availableYears = widget.dates.map((date) => date.year).toSet().toList()
        ..sort();
    }
  }

  /// Set current year and notify caller if callback exists
  void _setYear(int year) {
    if (currentYear != year) {
      setState(() {
        currentYear = year;
        // When changing year, default to January of that year
        currentMonth = 1;
        scrollToMonth(currentMonth, currentYear);
      });

      // Notify caller about year change
      widget.onYearChanged?.call(year);
    }
  }

  /// Check if previous month is available (within current year)
  bool get hasPreviousMonth => currentMonth > 1;

  /// Check if next month is available (within current year)
  bool get hasNextMonth => currentMonth < 12;

  /// Method to scroll to the beginning of a specific month
  void scrollToMonth(int month, int year) {
    if (!mounted) return;

    // Locate the date in the list
    final targetDate = widget.dates.firstWhere(
      (date) => date.month == month && date.year == year,
      orElse: () => widget.dates.first,
    );

    // Find the index of the date and calculate the offset
    int targetIndex = widget.dates.indexOf(targetDate);
    double offset = targetIndex * (widget.itemSize + widget.columnSpacing);

    if (!_scrollController.hasClients) return;

    // Scroll to the calculated offset with animation
    _scrollController
        .animateTo(
      offset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    )
        .then((_) {
      if (!mounted) return;
      // Update the state after the scroll animation completes
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          currentMonth = month;
          currentYear = year;
        });
      });
    });
  }

  /// Scroll to the current month
  void scrollToCurrentMonth() {
    if (!mounted) return;
    var now = DateTime.now();
    // Check if today's year is in the available years
    if (_availableYears.contains(now.year)) {
      // If yes, navigate to current month of current year
      if (now.year != currentYear) {
        // If the year is changing, notify the caller
        widget.onYearChanged?.call(now.year);
      }
      setState(() {
        currentYear = now.year;
        currentMonth = now.month;
      });
      scrollToMonth(now.month, now.year);
    } else {
      // If today's year is not available, just stay in current year but go to current month number
      scrollToMonth(now.month, currentYear);
    }
  }

  /// Aggregates dates based on the current granularity setting.
  /// Returns a list of representative dates for each time period.
  List<DateTime> get aggregatedDates {
    switch (widget.granularity) {
      case ZeatMapGranularity.day:
        return widget.dates;
      case ZeatMapGranularity.week:
        return _aggregateByWeek();
      case ZeatMapGranularity.month:
        return _aggregateByMonth();
      case ZeatMapGranularity.year:
        return _aggregateByYear();
    }
  }

  List<DateTime> _aggregateByWeek() {
    if (widget.dates.isEmpty) return [];

    final Map<int, DateTime> weekStartDates = {};
    for (var date in widget.dates) {
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      final weekKey = weekStart.millisecondsSinceEpoch;
      if (!weekStartDates.containsKey(weekKey)) {
        weekStartDates[weekKey] = weekStart;
      }
    }

    return weekStartDates.values.toList()..sort();
  }

  List<DateTime> _aggregateByMonth() {
    if (widget.dates.isEmpty) return [];

    final Map<int, DateTime> monthStartDates = {};
    for (var date in widget.dates) {
      final monthStart = DateTime(date.year, date.month, 1);
      final monthKey = monthStart.millisecondsSinceEpoch;
      if (!monthStartDates.containsKey(monthKey)) {
        monthStartDates[monthKey] = monthStart;
      }
    }

    return monthStartDates.values.toList()..sort();
  }

  List<DateTime> _aggregateByYear() {
    if (widget.dates.isEmpty) return [];

    final Map<int, DateTime> yearStartDates = {};
    for (var date in widget.dates) {
      final yearStart = DateTime(date.year, 1, 1);
      final yearKey = yearStart.millisecondsSinceEpoch;
      if (!yearStartDates.containsKey(yearKey)) {
        yearStartDates[yearKey] = yearStart;
      }
    }

    return yearStartDates.values.toList()..sort();
  }

  /// Generates the appropriate date label based on granularity.
  /// For example, shows day number for daily view, week number for weekly view.
  String getDateLabel(DateTime date) {
    switch (widget.granularity) {
      case ZeatMapGranularity.day:
        return DateFormat('d').format(date);
      case ZeatMapGranularity.week:
        return 'W${getWeekNumber(date)}';
      case ZeatMapGranularity.month:
        return DateFormat('MMM').format(date);
      case ZeatMapGranularity.year:
        return date.year.toString();
    }
  }

  /// Formats date for tooltip display based on granularity.
  /// Provides more detailed date information when hovering over cells.
  String getTooltipDateFormat(DateTime date) {
    switch (widget.granularity) {
      case ZeatMapGranularity.day:
        return DateFormat('EEEE, MMMM d, yyyy').format(date);
      case ZeatMapGranularity.week:
        final weekEnd = date.add(const Duration(days: 6));
        return '${DateFormat('MMM d').format(date)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}';
      case ZeatMapGranularity.month:
        return DateFormat('MMMM yyyy').format(date);
      case ZeatMapGranularity.year:
        return DateFormat('yyyy').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: widget.cardColor ?? Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _generateHeader(),
            const Divider(),
            Row(
              children: [
                _generateRowHeaderColumn(),
                _generateDataGrid(context),
              ],
            ),
            _generateLegend(),
          ],
        ),
      ),
    );
  }

  /// Builds the header section of the heatmap including:
  /// - Title
  /// - Current period navigation
  /// - Year dropdown (if enabled)
  Widget _generateHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.headerTitle ?? 'ZeatMap',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Tooltip(
                message: "Go to current date",
                child: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: scrollToCurrentMonth,
                ),
              ),
              // Year dropdown - conditionally shown
              if (widget.showYearDropdown)
                DropdownButton<int>(
                  value: _availableYears.contains(currentYear)
                      ? currentYear
                      : _availableYears.first,
                  items: _availableYears
                      .map((year) => DropdownMenuItem(
                            value: year,
                            child: Text(year.toString()),
                          ))
                      .toList(),
                  onChanged: (year) {
                    if (year != null) {
                      _setYear(year);
                    }
                  },
                ),
              // Period navigation based on granularity
              Tooltip(
                message:
                    "Go to previous ${widget.granularity.toString().split('.').last}",
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: hasPrevious ? navigateToPrevious : null,
                ),
              ),
              // Date display section showing appropriate label based on granularity
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  headerDateText,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              // Period navigation based on granularity
              Tooltip(
                message:
                    "Go to next ${widget.granularity.toString().split('.').last}",
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: hasNext ? navigateToNext : null,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Builds the legend section below the heatmap.
  /// Shows color indicators with labels if legend items are provided.
  Widget _generateLegend() {
    return widget.showLegend && widget.legendItems.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: _getLegendAlignment(),
              children: widget.legendItems.map((legendItem) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: legendItem.color,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(legendItem.label),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          )
        : Container();
  }

  /// Converts the legendPosition enum to a MainAxisAlignment value
  MainAxisAlignment _getLegendAlignment() {
    switch (widget.legendPosition) {
      case ZeatMapLegendPosition.start:
        return MainAxisAlignment.start;
      case ZeatMapLegendPosition.end:
        return MainAxisAlignment.end;
      case ZeatMapLegendPosition.center:
      default:
        return MainAxisAlignment.center;
    }
  }

  /// Builds the main data grid of the heatmap.
  /// This includes all the cells representing data points.
  Expanded _generateDataGrid(BuildContext context) {
    final dates = aggregatedDates;
    return Expanded(
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: widget.scrollingEnabled
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            _generateDateRowYear(),
            _generateDateRowMonth(),
            _generateDateRowWeek(),
            _generateDateRowDay(context),
            ...List.generate(widget.rowHeaders.length, (rowIndex) {
              return Row(
                children: List.generate(dates.length, (columnIndex) {
                  ZeatMapItem<T> item = widget.itemBuilder != null
                      ? widget.itemBuilder!(rowIndex, columnIndex)
                      : _defaultItemBuilder(rowIndex, columnIndex);

                  return Padding(
                    padding: EdgeInsets.only(
                      top: widget.rowSpacing,
                      left: widget.columnSpacing,
                    ),
                    child: GestureDetector(
                      onTap: () => widget.onItemTapped?.call(item),
                      onDoubleTap: () => widget.onItemDoubleTapped?.call(item),
                      onLongPress: () => widget.onItemLongPressed?.call(item),
                      onTapDown: (details) => widget.onItemTapDown?.call(item),
                      onTapCancel: () => widget.onItemTapCancel?.call(item),
                      child: item.tooltipWidget != null
                          ? Tooltip(
                              richMessage:
                                  WidgetSpan(child: item.tooltipWidget!),
                              child: Container(
                                height: widget.itemSize,
                                width: widget.itemSize,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      widget.itemBorderRadius),
                                  color: item.color,
                                ),
                              ))
                          : Container(
                              height: widget.itemSize,
                              width: widget.itemSize,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    widget.itemBorderRadius),
                                color: item.color,
                              ),
                            ),
                    ),
                  );
                }),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _generateDateRowDay(BuildContext context) {
    final dates = aggregatedDates;
    // Only show day row if granularity is day
    return widget.showDay && widget.granularity == ZeatMapGranularity.day
        ? Row(
            children: List.generate(dates.length, (index) {
              DateTime currentDate = dates[index];
              bool isToday = DateTime(
                      currentDate.year, currentDate.month, currentDate.day) ==
                  DateTime(DateTime.now().year, DateTime.now().month,
                      DateTime.now().day);

              Widget dayWidget = Container(
                decoration: widget.highlightToday && isToday
                    ? const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      )
                    : null,
                height: widget.itemSize,
                width: widget.itemSize,
                child: widget.dayBuilder != null
                    ? widget.dayBuilder!(currentDate)
                    : Center(
                        child: Text(
                          getDateLabel(currentDate),
                          style: widget.highlightToday && isToday
                              ? const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)
                              : null,
                        ),
                      ),
              );

              return Padding(
                padding: EdgeInsets.only(left: widget.columnSpacing),
                child: dayWidget,
              );
            }),
          )
        : Container();
  }

  Widget _generateDateRowWeek() {
    final dates = aggregatedDates;
    // Only show week row if granularity is day or week
    return widget.showWeek &&
            widget.granularity.index <= ZeatMapGranularity.week.index
        ? Row(
            children: List.generate(dates.length, (index) {
              return Padding(
                padding: EdgeInsets.only(left: widget.columnSpacing),
                child: SizedBox(
                  height: widget.itemSize,
                  width: widget.itemSize,
                  child: widget.granularity == ZeatMapGranularity.week ||
                          (dates[index].weekday == DateTime.monday)
                      ? Center(
                          child: Text(
                            "W${getWeekNumber(dates[index])}",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                ),
              );
            }),
          )
        : Container();
  }

  Widget _generateDateRowMonth() {
    final dates = aggregatedDates;
    // Only show month row if granularity is day, week, or month
    return widget.showMonth &&
            widget.granularity.index <= ZeatMapGranularity.month.index
        ? Row(
            children: List.generate(dates.length, (index) {
              return Padding(
                padding: EdgeInsets.only(left: widget.columnSpacing),
                child: SizedBox(
                  height: widget.itemSize,
                  width: widget.itemSize,
                  child: widget.granularity == ZeatMapGranularity.month ||
                          (dates[index].day == 1)
                      ? Center(
                          child: Text(
                            DateFormat('MMM').format(dates[index]),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                ),
              );
            }),
          )
        : Container();
  }

  Widget _generateDateRowYear() {
    final dates = aggregatedDates;
    // Always show year row
    return widget.showYear
        ? Row(
            children: List.generate(dates.length, (index) {
              return Padding(
                padding: EdgeInsets.only(left: widget.columnSpacing),
                child: SizedBox(
                  height: widget.itemSize,
                  width: widget.itemSize,
                  child: widget.granularity == ZeatMapGranularity.year ||
                          (dates[index].month == 1 && dates[index].day == 1)
                      ? Center(
                          child: Text(
                            DateFormat('yyyy').format(dates[index]),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      : null,
                ),
              );
            }),
          )
        : Container();
  }

  Column _generateRowHeaderColumn() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: widget.columnSpacing),
          child: SizedBox(
            height: widget.itemSize * numberOfActiveDateRows,
            width: widget.rowHeaderWidth,
          ),
        ),
        ...List.generate(widget.rowHeaders.length, (index) {
          Widget header = widget.rowHeaderBuilder(widget.rowHeaders[index]);
          return Padding(
            padding: EdgeInsets.only(
                left: widget.columnSpacing, top: widget.rowSpacing),
            child: SizedBox(
              height: widget.itemSize,
              width: widget.rowHeaderWidth,
              child: header,
            ),
          );
        }),
      ],
    );
  }

  ZeatMapItem<T> _defaultItemBuilder(int rowIndex, int columnIndex) {
    T data = widget.rowHeaders[rowIndex];
    final dates = aggregatedDates;
    if (columnIndex >= dates.length) {
      return ZeatMapItem(
        ZeatMapPosition(rowIndex, columnIndex),
        rowData: data,
        color: Colors.grey[300]!,
      );
    }

    DateTime date = dates[columnIndex];
    Color color = _getDefaultColorForPeriod(date);

    final tooltipWidget = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.toString()),
          Text("Date: ${getTooltipDateFormat(date)}"),
        ],
      ),
    );

    return ZeatMapItem(
      ZeatMapPosition(rowIndex, columnIndex),
      rowData: data,
      color: color,
      date: date,
      tooltipWidget: tooltipWidget,
    );
  }

  Color _getDefaultColorForPeriod(DateTime startDate) {
    switch (widget.granularity) {
      case ZeatMapGranularity.day:
        return startDate.weekday == DateTime.saturday ||
                startDate.weekday == DateTime.sunday
            ? const Color.fromARGB(110, 255, 131, 131)
            : const Color.fromARGB(110, 221, 221, 221);

      case ZeatMapGranularity.week:
        // Check if any day in the week is a weekend
        bool hasWeekend = false;
        for (int i = 0; i < 7; i++) {
          final date = startDate.add(Duration(days: i));
          if (date.weekday == DateTime.saturday ||
              date.weekday == DateTime.sunday) {
            hasWeekend = true;
            break;
          }
        }
        return hasWeekend
            ? const Color.fromARGB(110, 255, 180, 180)
            : const Color.fromARGB(110, 221, 221, 221);

      case ZeatMapGranularity.month:
        // Count weekend days in the month
        final daysInMonth =
            DateTime(startDate.year, startDate.month + 1, 0).day;
        int weekendDays = 0;
        for (int i = 1; i <= daysInMonth; i++) {
          final date = DateTime(startDate.year, startDate.month, i);
          if (date.weekday == DateTime.saturday ||
              date.weekday == DateTime.sunday) {
            weekendDays++;
          }
        }
        // Normalize weekend ratio to determine color intensity
        final weekendRatio = weekendDays / daysInMonth;
        return Color.fromARGB(
          110,
          221 + ((255 - 221) * weekendRatio).round(),
          221 - (90 * weekendRatio).round(),
          221 - (90 * weekendRatio).round(),
        );

      case ZeatMapGranularity.year:
        // Use a neutral color for year view
        return const Color.fromARGB(110, 221, 221, 221);
    }
  }

  /// Calculates the number of active date label rows based on:
  /// - Which label rows are enabled (day, week, month, year)
  /// - Current granularity setting
  int get numberOfActiveDateRows {
    int activeRows = 0;
    // Only count rows that are visible based on granularity
    if (widget.showYear) activeRows++;
    if (widget.showMonth &&
        widget.granularity.index <= ZeatMapGranularity.month.index)
      activeRows++;
    if (widget.showWeek &&
        widget.granularity.index <= ZeatMapGranularity.week.index) activeRows++;
    if (widget.showDay && widget.granularity == ZeatMapGranularity.day)
      activeRows++;
    return activeRows;
  }

  /// Returns the ISO 8601 week number for the given [date].
  ///
  /// The week number is calculated based on the ISO 8601 standard,
  /// which defines the first week of the year as the week containing
  /// the first Thursday of the year.
  ///
  /// [date]: The date for which to calculate the week number.
  ///
  /// Returns an integer representing the week number.
  int getWeekNumber(DateTime date) {
    // ISO 8601 week date system
    // Week starts on Monday and the first week of the year contains the first Thursday
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final firstThursday = firstDayOfYear
        .add(Duration(days: (4 - firstDayOfYear.weekday + 7) % 7));
    final weekNumber = ((date.difference(firstThursday).inDays) / 7).ceil() + 1;
    return weekNumber;
  }
}
