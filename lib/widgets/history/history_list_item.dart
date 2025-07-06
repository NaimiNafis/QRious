import 'package:flutter/material.dart';
import '../../models/qr_code_model.dart';
import '../../utils/app_colors.dart';

class HistoryListItem extends StatelessWidget {
  final QRCodeModel item;
  final bool isSelected;
  final bool inSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Function(bool) onFavoriteToggle;
  final Function(int) onDelete;
  final Future<bool> Function(QRCodeModel) handleFavoriteToggle;
  
  const HistoryListItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.inSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.onFavoriteToggle,
    required this.onDelete,
    required this.handleFavoriteToggle,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isSelected && isDarkMode ? Colors.black : null;
    
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Dismissible(
        key: Key(item.id.toString()),
        background: Container(
          color: AppColors.starYellow,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20),
          child: Icon(
            item.isFavorite ? Icons.star_border : Icons.star,
            color: Colors.white,
          ),
        ),
        secondaryBackground: Container(
          color: AppColors.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        direction: inSelectionMode ? DismissDirection.none : DismissDirection.horizontal,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Handle favorite toggle
            return await handleFavoriteToggle(item);
          } else {
            // For endToStart (delete), return true to proceed with dismissal
            return true;
          }
        },
        onDismissed: (direction) {
          // This will only be called for endToStart (delete) swipes
          if (item.id != null) {
            onDelete(item.id!);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 40) : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ListTile(
            leading: inSelectionMode 
              ? _buildSelectionIndicator()
              : _buildTypeIcon(isDarkMode),
            title: Text(
              item.type,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            subtitle: Text(
              item.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: textColor?.withValues(alpha: 204)),
            ),
            trailing: !inSelectionMode
                ? IconButton(
                    icon: Icon(
                      item.isFavorite ? Icons.star : Icons.star_border,
                      color: item.isFavorite ? AppColors.starYellow : AppColors.textMuted,
                    ),
                    onPressed: () => onFavoriteToggle(item.isFavorite),
                    tooltip: item.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                  )
                : null,
          ),
        ),
      ),
    );
  }
  
  Widget _buildSelectionIndicator() {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.textMuted,
          width: 2,
        ),
        color: isSelected ? AppColors.primary : Colors.transparent,
      ),
      child: isSelected 
          ? const Icon(Icons.check, color: Colors.white, size: 20)
          : const SizedBox(width: 20, height: 20),
    );
  }
  
  Widget _buildTypeIcon(bool isDarkMode) {
    final iconColor = isSelected && isDarkMode ? Colors.black : null;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.background,
        shape: BoxShape.circle,
      ),
      child: _getIconForType(item.type, iconColor),
    );
  }
  
  Widget _getIconForType(String type, Color? iconColor) {
    IconData iconData;
    
    switch (type) {
      case 'URL':
        iconData = Icons.link;
        break;
      case 'WI-FI':
        iconData = Icons.wifi;
        break;
      case 'CONTACTS':
        iconData = Icons.person;
        break;
      case 'PRODUCT':
        iconData = Icons.shopping_cart;
        break;
      default:
        iconData = Icons.text_snippet;
    }
    
    return Icon(iconData, color: iconColor);
  }
} 