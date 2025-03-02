import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zeatmap/src/zeatmap_legend_item.dart';
import 'package:zeatmap/src/zeatmap_item.dart';
import 'package:intl/intl.dart';
import 'package:zeatmap/src/zeatmap_position.dart';

/// Enum defining possible positions for the legend
enum ZeatMapLegendPosition {
  start,
  center,
  end,
}

class ZeatMap<T> extends StatefulWidget {
  final List<DateTime> dates;
  final List<T> rowHeaders;
  final double rowSpacing;
  final double columnSpacing;
  final double itemSize;
  final double itemBorderRadius;
  final bool showDay;
  final bool showWeek;
  final bool showMonth;
  final bool showYear;

  /// Whether to display the year dropdown in the header
  final bool showYearDropdown;
  final bool highlightToday;
  final List<ZeatMapLegendItem> legendItems;
  final bool showLegend;

  /// Determines the horizontal position of the legend
  final ZeatMapLegendPosition legendPosition;

  final Widget Function(T rowData) rowHeaderBuilder;
  final ZeatMapItem<T> Function(int rowIndex, int columnIndex)? itemBuilder;
  final Widget Function(DateTime date)? dayBuilder;
  final String? headerTitle;
  final double rowHeaderWidth;
  final Color? cardColor;

  /// Whether horizontal scrolling is enabled on the ZeatMap
  final bool scrollingEnabled;

  /// Optional list of years to show in the dropdown. If not provided, years will be extracted from dates.
  final List<int>? years;

  /// Optional parameter to set the initially selected year. If not provided, defaults to current year or first available year.
  final int? selectedYear;

  // Event handlers
  final void Function(ZeatMapItem<T> item)? onItemTapped;
  final void Function(ZeatMapItem<T> item)? onItemLongPressed;
  final void Function(ZeatMapItem<T> item)? onItemDoubleTapped;
  final void Function(ZeatMapItem<T> item)? onItemTapDown;
  final void Function(ZeatMapItem<T> item)? onItemTapCancel;
  // Callback when year changes
  final void Function(int year)? onYearChanged;

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

  /// Call this method to scroll to a specific month within the widget.
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

    // Scroll to the initialized month and year
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    // Locate the date in the list
    final targetDate = widget.dates.firstWhere(
      (date) => date.month == month && date.year == year,
      orElse: () => widget.dates.first,
    );

    // Find the index of the date and calculate the offset
    int targetIndex = widget.dates.indexOf(targetDate);
    double offset = targetIndex * (widget.itemSize + widget.columnSpacing);

    // Scroll to the calculated offset with animation
    _scrollController
        .animateTo(
      offset,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    )
        .then((_) {
      // Update the state after the scroll animation completes
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          currentMonth = month;
          currentYear = year;
        });
      });
    });
  }

  /// Scroll to the current month
  void scrollToCurrentMonth() {
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

  /// Scroll to the previous month (within current year)
  void scrollToPreviousMonth() {
    if (hasPreviousMonth) {
      int previousMonth = currentMonth - 1;
      scrollToMonth(previousMonth, currentYear);
    }
  }

  /// Scroll to the next month (within current year)
  void scrollToNextMonth() {
    if (hasNextMonth) {
      int nextMonth = currentMonth + 1;
      scrollToMonth(nextMonth, currentYear);
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
                message: "Go to current month",
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
              // Month navigation
              Tooltip(
                message: "Go to previous month",
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: hasPreviousMonth ? scrollToPreviousMonth : null,
                ),
              ),
              // Date display section with month and year
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(DateFormat("MMMM")
                      .format(DateTime(currentYear, currentMonth))),
                ],
              ),
              // Month navigation
              Tooltip(
                message: "Go to next month",
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: hasNextMonth ? scrollToNextMonth : null,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

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

  Expanded _generateDataGrid(BuildContext context) {
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
                children: List.generate(widget.dates.length, (columnIndex) {
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
    return widget.showDay
        ? Row(
            children: List.generate(widget.dates.length, (index) {
              DateTime currentDate = widget.dates[index];
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
                          DateFormat('d').format(currentDate),
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
    return widget.showWeek
        ? Row(
            children: List.generate(widget.dates.length, (index) {
              return Padding(
                padding: EdgeInsets.only(left: widget.columnSpacing),
                child: SizedBox(
                  height: widget.itemSize,
                  width: widget.itemSize,
                  child: widget.dates[index].weekday == DateTime.monday
                      ? Center(
                          child: Text(
                            "W${getWeekNumber(widget.dates[index])}",
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
    return widget.showMonth
        ? Row(
            children: List.generate(widget.dates.length, (index) {
              return Padding(
                padding: EdgeInsets.only(left: widget.columnSpacing),
                child: SizedBox(
                  height: widget.itemSize,
                  width: widget.itemSize,
                  child: widget.dates[index].day == 1
                      ? Center(
                          child: Text(
                            DateFormat('MMM').format(widget.dates[index]),
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
    return widget.showYear
        ? Row(
            children: List.generate(widget.dates.length, (index) {
              return Padding(
                padding: EdgeInsets.only(left: widget.columnSpacing),
                child: SizedBox(
                  height: widget.itemSize,
                  width: widget.itemSize,
                  child: widget.dates[index].month == 1 &&
                          widget.dates[index].day == 1
                      ? Center(
                          child: Text(
                            DateFormat('yyyy').format(widget.dates[index]),
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
    DateTime date = widget.dates[columnIndex];
    Color color =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday
            ? const Color.fromARGB(110, 255, 131, 131)
            : const Color.fromARGB(110, 221, 221, 221);
    return ZeatMapItem(
      ZeatMapPosition(rowIndex, columnIndex),
      rowData: data,
      color: color,
      date: date,
    );
  }

  int get numberOfActiveDateRows {
    int activeRows = 0;
    if (widget.showYear) activeRows++;
    if (widget.showMonth) activeRows++;
    if (widget.showWeek) activeRows++;
    if (widget.showDay) activeRows++;
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
