import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class MonthlyLineChart extends StatelessWidget {
  final Map<String, double> monthlyData;

  const MonthlyLineChart({super.key, required this.monthlyData});

  @override
  Widget build(BuildContext context) {
    if (monthlyData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final sortedEntries = monthlyData.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final spots = sortedEntries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    final maxY =
        sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final minY =
        sortedEntries.map((e) => e.value).reduce((a, b) => a < b ? a : b);

    // Compute Y-axis interval with max 5 labels and round to nearest 50
    const maxLabels = 5;
    final rawInterval = (maxY - minY) / (maxLabels - 1);
    final interval = (rawInterval / 50).ceil() * 50;

    // Round max and min Y to multiples of interval
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
                if (index < 0 || index >= sortedEntries.length) {
                  return const SizedBox();
                }

                final monthKey = sortedEntries[index].key;
                final parts = monthKey.split('-');
                if (parts.length != 2) return const SizedBox();

                final month = int.parse(parts[1]);
                final monthName =
                    DateFormat('MMM').format(DateTime(2000, month));

                // Show every other month to avoid crowding
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
        maxX: (sortedEntries.length - 1).toDouble(),
        minY: chartMinY.toDouble(),
        maxY: chartMaxY.toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: false,  // Straight lines
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: Colors.blue,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.3),
                  Colors.blue.withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => Colors.blue.shade700,
            tooltipPadding: const EdgeInsets.all(8),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((LineBarSpot touchedSpot) {
                final index = touchedSpot.x.toInt();
                if (index < 0 || index >= sortedEntries.length) {
                  return null;
                }

                final monthKey = sortedEntries[index].key;
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