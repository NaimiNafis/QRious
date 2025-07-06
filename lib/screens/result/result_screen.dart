import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/history_provider.dart';
import '../../utils/app_colors.dart';
import 'result_controller.dart';
import 'result_content_view.dart';

class ResultScreen extends StatefulWidget {
  final String content;
  final String type;
  final int? id;
  final bool? isFavorite;
  final bool? isSafe;

  const ResultScreen({
    super.key,
    required this.content,
    required this.type,
    this.id,
    this.isFavorite,
    this.isSafe,
  });
  
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Track favorite status locally to update UI
  bool? _isFavorite;
  int? _currentId;
  bool? _isSafe;
  
  // Controller
  late ResultController _controller;
  
  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _currentId = widget.id;
    _isSafe = widget.isSafe;
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = ResultController(
      context: context,
      historyProvider: Provider.of<HistoryProvider>(context, listen: false),
    );
  }
  
  // Handle adding to favorites
  void _handleFavoriteToggle() {
    if (_currentId != null) {
      // Update local state immediately for better UX
      setState(() {
        _isFavorite = !(_isFavorite ?? false);
      });
      
      // Show feedback immediately
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite == true 
              ? 'Added to favorites' 
              : 'Removed from favorites'),
          duration: const Duration(seconds: 1),
        ),
      );
      
      // Toggle favorite for existing item
      _controller.toggleFavorite(_currentId!);
    } else {
      // This is a new scan, save it and mark as favorite
      _saveAndFavorite();
    }
  }
  
  // Save and mark as favorite
  Future<void> _saveAndFavorite() async {
    try {
      // First save to history and get the ID of the newly added item
      final newItem = await _controller.saveAndGetNewItem(widget.content, widget.type);
      
      if (!mounted) return;
      
      // Update local state with the new ID and favorite status
      setState(() {
        _currentId = newItem.id;
        _isFavorite = true;
        _isSafe = newItem.isSafe;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added to favorites'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to favorites: ${e.toString()}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  // Handle URL open action with safety check
  Future<void> _handleOpenUrl() async {
    await _controller.launchURL(widget.content, isSafeOverride: _isSafe);
  }
  
  // Handle copy action with safety check
  Future<void> _handleCopy() async {
    await _controller.copyToClipboard(
      widget.content, 
      type: widget.type, 
      isSafeOverride: _isSafe,
    );
  }
  
  // Handle share action with safety check
  Future<void> _handleShare() async {
    await _controller.shareContent(
      widget.content,
      type: widget.type,
      isSafeOverride: _isSafe,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final typeIcon = _controller.getIconForType(widget.type);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          widget.type,
          style: TextStyle(color: AppColors.textLight),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textLight),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _currentId != null && _isFavorite == true ? Icons.star : Icons.star_border,
              color: _currentId != null && _isFavorite == true ? AppColors.starYellow : AppColors.textLight,
            ),
            onPressed: _handleFavoriteToggle,
            tooltip: _currentId != null && _isFavorite == true ? 'Remove from favorites' : 'Add to favorites',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ResultContentView(
          content: widget.content,
          type: widget.type,
          typeIcon: typeIcon,
          onOpen: (widget.type == 'URL') 
              ? _handleOpenUrl
              : null,
          onCopy: _handleCopy,
          onShare: _handleShare,
        ),
      ),
    );
  }
} 