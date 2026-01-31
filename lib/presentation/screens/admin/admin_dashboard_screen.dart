import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/analytics_providers.dart';

/// UC151-160: Admin dashboard for internal metrics.
///
/// Shows:
/// - User retention (D1, D7, D30, D90)
/// - Churn detection
/// - LTV metrics
/// - Funnel analysis
/// - AI cost tracking
/// - Ad ROI
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Administrativo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Refresh all metrics
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              // TODO: Export data
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DateRangeSelector(),
            const SizedBox(height: 24),
            Text(
              'Visao Geral',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _OverviewMetrics(),
            const SizedBox(height: 24),
            Text(
              'Retencao',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _RetentionMetrics(),
            const SizedBox(height: 24),
            Text(
              'Funil de Conversao',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _FunnelChart(),
            const SizedBox(height: 24),
            Text(
              'Metricas Financeiras',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _FinancialMetrics(),
            const SizedBox(height: 24),
            Text(
              'Custos de IA',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _AiCostMetrics(),
            const SizedBox(height: 24),
            Text(
              'Usuarios em Risco de Churn',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _ChurnRiskList(),
          ],
        ),
      ),
    );
  }
}

class _DateRangeSelector extends StatefulWidget {
  @override
  State<_DateRangeSelector> createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<_DateRangeSelector> {
  String _selectedRange = '7d';

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            const Text('Periodo:'),
            const SizedBox(width: 16),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: '7d', label: Text('7 dias')),
                ButtonSegment(value: '30d', label: Text('30 dias')),
                ButtonSegment(value: '90d', label: Text('90 dias')),
              ],
              selected: {_selectedRange},
              onSelectionChanged: (selection) {
                setState(() => _selectedRange = selection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewMetrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'Usuarios Ativos',
            value: '12,456',
            change: '+8.3%',
            isPositive: true,
            icon: Icons.people,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            title: 'Novos Usuarios',
            value: '1,234',
            change: '+12.5%',
            isPositive: true,
            icon: Icons.person_add,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 16,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  change,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RetentionMetrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final retentionData = [
      {'day': 'D1', 'value': 65.0, 'target': 60.0},
      {'day': 'D7', 'value': 42.0, 'target': 40.0},
      {'day': 'D30', 'value': 28.0, 'target': 25.0},
      {'day': 'D90', 'value': 18.0, 'target': 15.0},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: retentionData.map((data) {
            final value = data['value'] as double;
            final target = data['target'] as double;
            final isAboveTarget = value >= target;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['day'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${value.toStringAsFixed(1)}%',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: isAboveTarget ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(meta: ${target.toStringAsFixed(0)}%)',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      LinearProgressIndicator(
                        value: value / 100,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        color: isAboveTarget ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 8,
                      ),
                      Positioned(
                        left: (target / 100) *
                            (MediaQuery.of(context).size.width - 64),
                        child: Container(
                          width: 2,
                          height: 8,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FunnelChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final funnelSteps = [
      {'stage': 'Instalacao', 'count': 10000, 'percent': 100.0},
      {'stage': 'Onboarding completo', 'count': 7500, 'percent': 75.0},
      {'stage': 'Primeiro deck', 'count': 5000, 'percent': 50.0},
      {'stage': 'Primeira sessao', 'count': 3500, 'percent': 35.0},
      {'stage': 'Retorno D7', 'count': 2100, 'percent': 21.0},
      {'stage': 'Conversao Premium', 'count': 420, 'percent': 4.2},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: funnelSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final width = (step['percent'] as double) / 100;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        step['stage'] as String,
                        style: theme.textTheme.bodyMedium,
                      ),
                      Text(
                        '${step['count']} (${(step['percent'] as double).toStringAsFixed(1)}%)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FractionallySizedBox(
                    widthFactor: width,
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 1 - (index * 0.15),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _FinancialMetrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'LTV Medio',
                value: 'R\$ 45,80',
                change: '+5.2%',
                isPositive: true,
                icon: Icons.attach_money,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'CAC',
                value: 'R\$ 12,50',
                change: '-8.1%',
                isPositive: true,
                icon: Icons.campaign,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'LTV/CAC',
                value: '3.66x',
                change: '+15.3%',
                isPositive: true,
                icon: Icons.trending_up,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'MRR',
                value: 'R\$ 28.5k',
                change: '+22.1%',
                isPositive: true,
                icon: Icons.payments,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AiCostMetrics extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custo total IA',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'R\$ 4.250',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cards gerados',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '85.000',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custo por card',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'R\$ 0,05',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Receita por credito IA',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  'R\$ 0,15 (margem 66%)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChurnRiskList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final riskyUsers = [
      {
        'name': 'Usuario #4521',
        'days': 12,
        'lastAction': 'Estudou 3 cards',
        'risk': 'high',
      },
      {
        'name': 'Usuario #3892',
        'days': 8,
        'lastAction': 'Criou 1 deck',
        'risk': 'medium',
      },
      {
        'name': 'Usuario #2156',
        'days': 6,
        'lastAction': 'Gerou 5 cards IA',
        'risk': 'medium',
      },
    ];

    return Card(
      child: Column(
        children: riskyUsers.map((user) {
          final isHighRisk = user['risk'] == 'high';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  isHighRisk ? Colors.red.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
              child: Icon(
                Icons.warning,
                color: isHighRisk ? Colors.red : Colors.orange,
              ),
            ),
            title: Text(user['name'] as String),
            subtitle: Text(
              'Inativo ha ${user['days']} dias - ${user['lastAction']}',
            ),
            trailing: FilledButton.tonal(
              onPressed: () {
                // TODO: Send reengagement
              },
              child: const Text('Reengajar'),
            ),
          );
        }).toList(),
      ),
    );
  }
}
