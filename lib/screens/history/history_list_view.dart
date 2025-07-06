import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/qr_code_model.dart';
import '../../providers/history_provider.dart';
import '../../widgets/history/history_empty_state.dart';
import '../../widgets/history/history_list_item.dart';
import '../../screens/result/result_screen.dart';

class HistoryListView extends StatefulWidget {
  final bool showFavoritesOnly;
  final bool inSelectionMode;
  final Set<int> selectedItems;
  final Function(int?) onToggleSelection;
  final Function(int?) onEnterSelectionMode;
  final Function(int) onItemDelete;
  final Future<bool> Function(QRCodeModel) onHandleFavoriteToggle;
  final Function(QRCodeModel) onToggleItemFavorite;
  
  const HistoryListView({
    super.key,
    required this.showFavoritesOnly,
    required this.inSelectionMode,
    required this.selectedItems,
    required this.onToggleSelection,
    required this.onEnterSelectionMode,
    required this.onItemDelete,
    required this.onHandleFavoriteToggle,
    required this.onToggleItemFavorite,
  });

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, _) {
        // Filter history based on whether to show favorites only
        final filteredHistory = historyProvider.history.where((code) {
          if (widget.showFavoritesOnly) {
            return code.isFavorite;
          }
          return true;
        }).toList();
        
        if (filteredHistory.isEmpty) {
          return HistoryEmptyState(isFavoritesTab: widget.showFavoritesOnly);
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: filteredHistory.length,
          itemBuilder: (context, index) {
            final item = filteredHistory[index];
            final isSelected = item.id != null && widget.selectedItems.contains(item.id);
            
            return HistoryListItem(
              item: item,
              isSelected: isSelected,
              inSelectionMode: widget.inSelectionMode,
              onTap: () {
                if (widget.inSelectionMode) {
                  widget.onToggleSelection(item.id);
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(
                        content: item.content,
                        type: item.type,
                        id: item.id,
                        isFavorite: item.isFavorite,
                        isSafe: item.isSafe,
                      ),
                    ),
                  );
                }
              },
              onLongPress: () {
                if (!widget.inSelectionMode) {
                  widget.onEnterSelectionMode(item.id);
                }
              },
              onDelete: widget.onItemDelete,
              handleFavoriteToggle: widget.onHandleFavoriteToggle,
              onFavoriteToggle: (_) => widget.onToggleItemFavorite(item),
            );
          },
        );
      },
    );
  }
} 