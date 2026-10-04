import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import 'canteen_menu.dart';

class CanteenHeatmapScreen extends StatefulWidget {
  const CanteenHeatmapScreen({super.key});

  @override
  State<CanteenHeatmapScreen> createState() => _CanteenHeatmapScreenState();
}

class _CanteenHeatmapScreenState extends State<CanteenHeatmapScreen> {
  final FirestoreService _firestore = FirestoreService();
  String? _selectedCanteenId;
  String _filterQueue = 'All'; // 'All', 'Low', 'Medium', 'High'

  @override
  void initState() {
    super.initState();
    _firestore.addListener(_handleUpdate);
  }

  @override
  void dispose() {
    _firestore.removeListener(_handleUpdate);
    super.dispose();
  }

  void _handleUpdate() {
    if (mounted) setState(() {});
  }

  Color _getQueueColor(String queueStatus) {
    switch (queueStatus.toLowerCase()) {
      case 'high':
        return AppColors.queueHigh;
      case 'medium':
        return AppColors.queueMedium;
      case 'low':
      default:
        return AppColors.queueLow;
    }
  }

  double _getQueueProgress(String queueStatus) {
    switch (queueStatus.toLowerCase()) {
      case 'high':
        return 0.88;
      case 'medium':
        return 0.52;
      case 'low':
      default:
        return 0.22;
    }
  }

  IconData _getQueueIcon(String queueStatus) {
    switch (queueStatus.toLowerCase()) {
      case 'high':
        return Icons.people_alt_rounded;
      case 'medium':
        return Icons.groups_rounded;
      case 'low':
      default:
        return Icons.person_rounded;
    }
  }

  void _navigateToMenu(String canteenName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CanteenMenu(canteenName: canteenName),
      ),
    );
  }

  // Pre-configured relative campus coordinates (0.0 to 1.0) for the 7 canteens
  Offset _getCanteenMapCoords(String canteenName) {
    switch (canteenName.toLowerCase()) {
      case 'cafe coffee day':
        return const Offset(0.22, 0.16);
      case 'rec cafe':
        return const Offset(0.50, 0.20);
      case 'wokon':
        return const Offset(0.18, 0.46);
      case 'hotspot':
        return const Offset(0.50, 0.52);
      case 'yippe':
        return const Offset(0.80, 0.44);
      case 'hut cafe':
        return const Offset(0.24, 0.80);
      case '6sense':
        return const Offset(0.78, 0.80);
      default:
        return const Offset(0.50, 0.50);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canteens = _firestore.canteens;

    // Filtered canteens list
    final filteredCanteens = canteens.where((c) {
      if (_filterQueue == 'All') return true;
      final status = (c['queueStatus'] as String? ?? 'Low').toLowerCase();
      return status == _filterQueue.toLowerCase();
    }).toList();

    // Summary counts
    final lowCount = canteens.where((c) => (c['queueStatus'] as String? ?? '').toLowerCase() == 'low').length;
    final mediumCount = canteens.where((c) => (c['queueStatus'] as String? ?? '').toLowerCase() == 'medium').length;
    final highCount = canteens.where((c) => (c['queueStatus'] as String? ?? '').toLowerCase() == 'high').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Canteen Crowd Heatmap',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                // Live indicator badge
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.queueLow,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'LIVE • REC Campus Canteens',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Refresh indicator info
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: IconButton(
              icon: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 22),
              tooltip: 'Crowd Info',
              onPressed: _showInfoBottomSheet,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Status Bar: Live status & Last updated time
            _buildLiveStatusBar(),

            const SizedBox(height: 12),

            // Heatmap Legend Bar
            _buildLegendCard(lowCount, mediumCount, highCount),

            const SizedBox(height: 20),

            // Section 1: Campus Heatmap Visualization Map
            _buildSectionHeader(
              title: 'Interactive Campus Map',
              subtitle: 'Tap any canteen pin to view wait times and open menu',
            ),
            const SizedBox(height: 12),
            _buildCampusMap(canteens),

            const SizedBox(height: 26),

            // Section 2: Filterable List of All 7 Canteens
            _buildSectionHeader(
              title: 'All Canteens Crowd Status',
              subtitle: 'Choose a canteen with minimal wait time',
            ),
            const SizedBox(height: 12),
            _buildFilterChips(),
            const SizedBox(height: 14),
            _buildCanteenList(filteredCanteens),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // LIVE STATUS & TIMESTAMP BAR
  // ------------------------------------------------------------
  Widget _buildLiveStatusBar() {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.queueLow.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.sensors_rounded, color: AppColors.queueLow, size: 14),
                SizedBox(width: 4),
                Text(
                  'SENSORS ACTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.queueLow,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Last updated: Today, 12:45 PM',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // HEATMAP LEGEND CARD
  // ------------------------------------------------------------
  Widget _buildLegendCard(int low, int medium, int high) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CROWD LEVEL LEGEND',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLegendItem(
                  color: AppColors.queueLow,
                  title: 'Low',
                  subtitle: '< 8m ($low)',
                ),
                Container(width: 1, height: 26, color: AppColors.border),
                _buildLegendItem(
                  color: AppColors.queueMedium,
                  title: 'Medium',
                  subtitle: '8-15m ($medium)',
                ),
                Container(width: 1, height: 26, color: AppColors.border),
                _buildLegendItem(
                  color: AppColors.queueHigh,
                  title: 'High',
                  subtitle: '> 15m ($high)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // CAMPUS MAP HEATMAP VISUALIZATION
  // ------------------------------------------------------------
  Widget _buildCampusMap(List<Map<String, dynamic>> canteens) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
      child: Container(
        height: 290,
        decoration: BoxDecoration(
          color: const Color(0xFFF1EFE9),
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 14,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          child: Stack(
            children: [
              // Campus Grid / Blueprint Background Elements
              CustomPaint(
                size: const Size(double.infinity, 290),
                painter: _CampusBlueprintPainter(),
              ),

              // Campus Zone Markers
              const Positioned(
                top: 10,
                left: 14,
                child: Text(
                  '🏫 REC MAIN CAMPUS SCHEMATIC',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF8C867A),
                  ),
                ),
              ),

              // Interactive Canteen Heat Nodes on Map
              ...canteens.map((canteen) {
                final name = canteen['name'] as String? ?? 'Canteen';
                final queueStatus = canteen['queueStatus'] as String? ?? 'Low';
                final queueWait = canteen['queueWait'] as String? ?? '5 mins';
                final coords = _getCanteenMapCoords(name);
                final color = _getQueueColor(queueStatus);
                final isSelected = _selectedCanteenId == canteen['id'];

                return Positioned(
                  left: coords.dx * 320,
                  top: coords.dy * 260,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCanteenId = canteen['id'];
                      });
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Heat Glow Halo
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: isSelected ? 42 : 32,
                              height: isSelected ? 42 : 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color.withValues(alpha: isSelected ? 0.35 : 0.22),
                              ),
                            ),
                            Container(
                              width: isSelected ? 26 : 20,
                              height: isSelected ? 26 : 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _getQueueIcon(queueStatus),
                                color: Colors.white,
                                size: isSelected ? 14 : 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Label Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isSelected ? color : AppColors.border,
                              width: isSelected ? 1.4 : 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected ? color : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                queueWait,
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              // Selected Canteen Quick Action Drawer
              if (_selectedCanteenId != null)
                Positioned(
                  bottom: 10,
                  left: 12,
                  right: 12,
                  child: _buildSelectedCanteenBanner(canteens),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedCanteenBanner(List<Map<String, dynamic>> canteens) {
    final canteen = canteens.firstWhere(
      (c) => c['id'] == _selectedCanteenId,
      orElse: () => canteens.first,
    );
    final queueStatus = canteen['queueStatus'] as String? ?? 'Low';
    final color = _getQueueColor(queueStatus);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.storefront_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  canteen['name'],
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                ),
                Text(
                  '${canteen['queueWait']} • $queueStatus Crowd',
                  style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _navigateToMenu(canteen['name']),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('View Menu', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _selectedCanteenId = null;
              });
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // FILTER CHIPS (All, Low, Medium, High)
  // ------------------------------------------------------------
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
      child: Row(
        children: ['All', 'Low', 'Medium', 'High'].map((status) {
          final isSelected = _filterQueue == status;
          Color activeColor = AppColors.primary;
          if (status == 'Low') activeColor = AppColors.queueLow;
          if (status == 'Medium') activeColor = AppColors.queueMedium;
          if (status == 'High') activeColor = AppColors.queueHigh;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(status == 'All' ? 'All (7)' : status),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _filterQueue = status;
                });
              },
              backgroundColor: AppColors.surface,
              selectedColor: activeColor.withValues(alpha: 0.15),
              checkmarkColor: activeColor,
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? activeColor : AppColors.textPrimary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? activeColor : AppColors.border,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ------------------------------------------------------------
  // CANTEEN CARDS LIST (All 7 Canteens)
  // ------------------------------------------------------------
  Widget _buildCanteenList(List<Map<String, dynamic>> canteens) {
    if (canteens.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.filter_list_off_rounded, size: 40, color: AppColors.textSecondary.withValues(alpha: 0.5)),
              const SizedBox(height: 8),
              Text(
                'No canteens match "$_filterQueue" crowd filter',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
      itemCount: canteens.length,
      itemBuilder: (context, index) {
        final canteen = canteens[index];
        return _buildCanteenHeatCard(canteen);
      },
    );
  }

  Widget _buildCanteenHeatCard(Map<String, dynamic> canteen) {
    final name = canteen['name'] as String? ?? 'Canteen';
    final location = canteen['location'] as String? ?? 'Campus Court';
    final queueStatus = canteen['queueStatus'] as String? ?? 'Low';
    final queueWait = canteen['queueWait'] as String? ?? '5 mins wait';
    final rating = canteen['rating'] as String? ?? '4.5';
    final image = canteen['image'] as String? ?? '';

    final queueColor = _getQueueColor(queueStatus);
    final queueProgress = _getQueueProgress(queueStatus);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToMenu(name),
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Canteen Image Thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        image,
                        width: 76,
                        height: 76,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 76,
                          height: 76,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.restaurant, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Canteen Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Rating badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.star.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 12, color: AppColors.star),
                                    const SizedBox(width: 3),
                                    Text(
                                      rating,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Crowd Status Pill
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: queueColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: queueColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '$queueStatus Crowd',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: queueColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.schedule_rounded, size: 13, color: Colors.grey.shade600),
                              const SizedBox(width: 3),
                              Text(
                                queueWait,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Crowd Density Heat Progress Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: queueProgress,
                          minHeight: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(queueColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${(queueProgress * 100).toInt()}% Capacity',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: queueColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Card Bottom Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Updated: Today, 12:45 PM',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                    ),
                    Row(
                      children: [
                        Text(
                          'Open Menu',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // SECTION HEADER
  // ------------------------------------------------------------
  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLarge)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'How Crowd Heatmap Works',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 10),
            const Text(
              'Eataly estimates waiting times based on real-time kitchen orders in queue and campus canteen counter traffic:\n\n'
              '• Green (Low): Minimal rush. Food typically prepared within 5-7 minutes.\n'
              '• Yellow (Medium): Moderate lunch break traffic. 10-14 minutes wait.\n'
              '• Red (High): Peak rush. Pre-ordering for a later pickup slot is recommended.',
              style: TextStyle(fontSize: 13, height: 1.45, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom schematic painter for the campus blueprint map
class _CampusBlueprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pathwayPaint = Paint()
      ..color = const Color(0xFFE2DDD1)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = const Color(0xFFDBD5C7).withValues(alpha: 0.5)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw background grid lines
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Main Campus Walkway Pathways
    final path = Path();
    // Central Spine
    path.moveTo(size.width * 0.5, 30);
    path.lineTo(size.width * 0.5, size.height - 30);
    // West Branch to Science & Canteens
    path.moveTo(20, size.height * 0.46);
    path.lineTo(size.width - 20, size.height * 0.46);
    // South Branch to Sports & Hut Cafe
    path.moveTo(size.width * 0.24, size.height * 0.80);
    path.lineTo(size.width * 0.78, size.height * 0.80);

    canvas.drawPath(path, pathwayPaint);

    // Green Campus Lawn Zones
    final lawnPaint = Paint()
      ..color = const Color(0xFFD6E5D3).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, 35, size.width * 0.35, 65),
        const Radius.circular(10),
      ),
      lawnPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(24, size.height * 0.56, size.width * 0.22, 50),
        const Radius.circular(10),
      ),
      lawnPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
