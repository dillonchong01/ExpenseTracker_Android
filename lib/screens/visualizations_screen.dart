import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/weekly_bar_chart.dart';
import '../widgets/monthly_line_chart.dart';

class VisualizationsScreen extends StatelessWidget {
  const VisualizationsScreen({super.key});

  static const Color _steelBlueDark = Color(0xFF2E4A62);
  static const Color _steelBlueLight = Color(0xFF6B8FAF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        elevation: 0,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;
          final hasData = provider.expenses.isNotEmpty;

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.surface,
                  colorScheme.surfaceVariant.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),

                // Month header (always shown)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [_steelBlueDark, _steelBlueLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 18,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                      child: Row(
                        children: [
                          // Previous month
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              final current = provider.selectedMonth;
                              provider.changeMonth(
                                DateTime(current.year, current.month - 1),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.12),
                              ),
                              child: const Icon(
                                Icons.chevron_left,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Month + subtitle
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  DateFormat('MMMM yyyy')
                                      .format(provider.selectedMonth),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Insights for this Month',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Next month
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () {
                              final current = provider.selectedMonth;
                              provider.changeMonth(
                                DateTime(current.year, current.month + 1),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.12),
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                size: 22,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),


                const SizedBox(height: 20),

                // Content area
                Expanded(
                  child: hasData
                      ? SingleChildScrollView(
                          padding:
                              const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          child: Column(
                            children: [
                              _SectionCard(
                                title: 'Spending by Category',
                                subtitle:
                                    'Breakdown for ${DateFormat('MMMM').format(provider.selectedMonth)}',
                                accentIcon:
                                    Icons.pie_chart_outline_rounded,
                                child: SizedBox(
                                  height: 360,
                                  child: CategoryPieChart(
                                    categoryData:
                                        provider.spendingByCategory,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _SectionCard(
                                title: 'Weekly Spending',
                                subtitle:
                                    'Trend for ${DateFormat('MMMM').format(provider.selectedMonth)}',
                                accentIcon: Icons.bar_chart_rounded,
                                child: SizedBox(
                                  height: 250,
                                  child:
                                      FutureBuilder<List<double>>(
                                    future:
                                        provider.getWeeklySpending(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child:
                                                CircularProgressIndicator());
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Center(
                                            child: Text(
                                                'No data available'));
                                      }
                                      return WeeklyBarChart(
                                        weeklyData: snapshot.data!,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _SectionCard(
                                title: 'Monthly Spending Trend',
                                subtitle: 'Last 6 months',
                                accentIcon:
                                    Icons.show_chart_rounded,
                                child: SizedBox(
                                  height: 250,
                                  child:
                                      FutureBuilder<Map<String, double>>(
                                    future:
                                        provider.getMonthlySpending(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child:
                                                CircularProgressIndicator());
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Center(
                                            child: Text(
                                                'No data available'));
                                      }
                                      return MonthlyLineChart(
                                        monthlyData:
                                            snapshot.data!,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: colorScheme.primary
                                      .withOpacity(0.06),
                                ),
                                child: Icon(
                                  Icons.insights_outlined,
                                  size: 46,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No data to visualize',
                                style:
                                    textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add some expenses to see your insights.',
                                style:
                                    textTheme.bodySmall?.copyWith(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final IconData? accentIcon;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
    this.accentIcon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (accentIcon != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          colorScheme.primary.withOpacity(0.08),
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                    child: Icon(
                      accentIcon,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ),
                if (accentIcon != null)
                  const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}
