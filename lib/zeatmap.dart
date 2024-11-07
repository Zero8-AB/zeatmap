import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zeatmap/zeat_map_legend_item.dart';
import 'package:zeatmap/zeatmap_item.dart';
import 'package:intl/intl.dart';
import 'package:zeatmap/zeatmap_position.dart';

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
  final bool highlightToday;
  final List<ZeatMapLegendItem> legendItems;
  final bool showLegend;
  final Widget Function(T rowData) rowHeaderBuilder;
  final ZeatMapItem<T> Function(int rowIndex, int columnIndex)? itemBuilder;
  final Container Function(DateTime date)? dayBuilder;
  final String? headerTitle;
  final double rowHeaderWidth;

  // Event handlers
  final void Function(ZeatMapItem<T> item)? onItemTapped;
  final void Function(ZeatMapItem<T> item)? onItemLongPressed;
  final void Function(ZeatMapItem<T> item)? onItemDoubleTapped;
  final void Function(ZeatMapItem<T> item)? onItemTapDown;
  final void Function(ZeatMapItem<T> item)? onItemTapCancel;

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
    this.highlightToday = true,
    this.showLegend = true,
    this.rowSpacing = 8,
    this.columnSpacing = 8,
    this.itemSize = 30,
    this.itemBorderRadius = 5.0,
    this.onItemTapped,
    this.onItemLongPressed,
    this.onItemDoubleTapped,
    this.onItemTapDown,
    this.onItemTapCancel,
    this.headerTitle,
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

  @override
  void initState() {
    super.initState();
    // Initialize to the current date by default
    final now = DateTime.now();
    currentMonth = now.month;
    currentYear = now.year;

    // Scroll to the initialized month and year
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToMonth(currentMonth, currentYear);
    });
  }

  @override
  void didUpdateWidget(covariant ZeatMap<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

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
    scrollToMonth(now.month, now.year);
  }

  /// Scroll to the previous month
  void scrollToPreviousMonth() {
    int previousMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    int previousYear = currentMonth == 1 ? currentYear - 1 : currentYear;
    scrollToMonth(previousMonth, previousYear);
  }

  /// Scroll to the next month
  void scrollToNextMonth() {
    int nextMonth = currentMonth == 12 ? 1 : currentMonth + 1;
    int nextYear = currentMonth == 12 ? currentYear + 1 : currentYear;
    scrollToMonth(nextMonth, nextYear);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
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
              Tooltip(
                message: "Go to previous month",
                child: IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: scrollToPreviousMonth,
                ),
              ),
              Text(DateFormat("MMMM")
                  .format(DateTime(currentYear, currentMonth))),
              Tooltip(
                message: "Go to next month",
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: scrollToNextMonth,
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
              mainAxisAlignment: MainAxisAlignment.center,
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

  Expanded _generateDataGrid(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
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

  int getWeekNumber(DateTime date) {
    final diff = date.difference(DateTime(date.year, 1, 1)).inDays +
        (DateTime(date.year, 1, 1).weekday - 1);
    return (diff / 7).floor() + 1;
  }
}
