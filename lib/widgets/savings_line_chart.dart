import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SavingsLineChart extends StatelessWidget {
  final Map<String, double> savingsData;
  final bool isCumulative;

  const SavingsLineChart({
    super.key,
    required this.savingsData,
    this.isCumulative = false,
  });

  @override
  Widget build(BuildContext context) {
    // Show message if no data or all values are invalid
    if (savingsData.isEmpty || savingsData.values.every((v) => v.isNaN)) {
      return const Center(child: Text('No data available'));
    }

    final sortedEntries = savingsData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Only keep the last 6 months
    final visibleEntries = sortedEntries.length > 6
        ? sortedEntries.sublist(sortedEntries.length - 6)
        : sortedEntries;

    // Guard in case visibleEntries is empty
    if (visibleEntries.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final spots = visibleEntries.asMap().entries.map((entry) {
      final value = entry.value.value.isNaN ? 0.0 : entry.value.value;
      return FlSpot(entry.key.toDouble(), value);
    }).toList();

    final maxY =
        visibleEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minY =
        visibleEntries.map((e) => e.value).reduce((a, b) => a < b ? a : b);

    // Compute a "nice" interval for max 5 Y-axis labels
    const maxLabels = 5;
    double rawInterval = (maxY - minY) / (maxLabels - 1);
    if (rawInterval.isNaN || rawInterval <= 0) rawInterval = 1;

    final interval = (rawInterval / 50).ceil() * 50;

    // Round maxY and minY to multiples of interval
    final chartMaxY = ((maxY / interval).ceil()) * interval;
    final chartMinY = ((minY / interval).floor()) * interval;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: interval.toDouble(),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300],
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: interval.toDouble(),
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= visibleEntries.length) {
                  return const SizedBox();
                }

                final monthKey = visibleEntries[index].key;
                final parts = monthKey.split('-');
                if (parts.length != 2) return const SizedBox();

                final month = int.parse(parts[1]);
                final monthName =
                    DateFormat('MMM').format(DateTime(2000, month));

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    monthName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
            left: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        minX: 0,
        maxX: (visibleEntries.length - 1).toDouble(),
        minY: chartMinY.toDouble(),
        maxY: chartMaxY.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,
            gradient: LinearGradient(
              colors: [
                Colors.green.shade600,
                Colors.green.shade400,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.green,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.3),
                  Colors.green.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.green.shade700,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final index = touchedSpot.x.toInt();
                if (index < 0 || index >= visibleEntries.length) {
                  return null;
                }

                final monthKey = visibleEntries[index].key;
                final parts = monthKey.split('-');
                final monthName = DateFormat('MMM yyyy').format(
                  DateTime(int.parse(parts[0]), int.parse(parts[1])),
                );

                return LineTooltipItem(
                  '$monthName\n\$${touchedSpot.y.toStringAsFixed(2)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}