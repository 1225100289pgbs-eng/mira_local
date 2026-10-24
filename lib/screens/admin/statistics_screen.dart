import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/business.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/rating_stars.dart';
import '../../widgets/status_badge.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final statuses = BusinessStatus.values;
    final counts = [for (final st in statuses) s.countByStatus(st)];
    final maxCount = counts.fold<int>(0, (a, b) => a > b ? a : b);
    final ranking = s.categoriesRanking();
    final maxCat = ranking.isEmpty ? 1 : (ranking.first.value == 0 ? 1 : ranking.first.value);
    final top = s.topRated();

    return Scaffold(
      appBar: AppBar(title: const Text('Estadísticas')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total de emprendimientos',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${s.totalBusinesses}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SectionTitle('Emprendimientos por estado'),
          AppCard(
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  maxY: (maxCount + 1).toDouble(),
                  alignment: BarChartAlignment.spaceAround,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= statuses.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              '${statuses[i].label}\n${counts[i]}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 11),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < statuses.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: counts[i].toDouble(),
                            color: statusColor(statuses[i]),
                            width: 28,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SectionTitle('Categorías con más emprendimientos'),
          AppCard(
            child: Column(
              children: [
                for (final e in ranking)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(e.key.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13)),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: e.value / maxCat,
                              minHeight: 8,
                              backgroundColor: AppColors.borde,
                              color: AppColors.adminPrimario,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 30,
                          child: Text('${e.value}',
                              textAlign: TextAlign.right,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SectionTitle('Negocios mejor calificados'),
          if (top.isEmpty)
            const Text('Aún no hay calificaciones.',
                style: TextStyle(color: AppColors.gris))
          else
            AppCard(
              child: Column(
                children: [
                  for (var i = 0; i < top.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text('${i + 1}.',
                                style: const TextStyle(color: AppColors.gris)),
                          ),
                          Expanded(
                            child: Text(top[i].name,
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          RatingStars(
                              value: top[i].average, count: top[i].ratingCount),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
