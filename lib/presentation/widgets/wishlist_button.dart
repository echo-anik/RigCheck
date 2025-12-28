import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/toast_utils.dart';
import '../providers/wishlist_provider.dart';

/// Reusable wishlist button widget for components and builds
class WishlistButton extends ConsumerStatefulWidget {
  final String itemId;
  final WishlistItemType type;
  final bool showLabel;
  final ButtonStyle? style;
  final IconData? filledIcon;
  final IconData? outlineIcon;

  const WishlistButton({
    super.key,
    required this.itemId,
    this.type = WishlistItemType.component,
    this.showLabel = false,
    this.style,
    this.filledIcon,
    this.outlineIcon,
  });

  @override
  ConsumerState<WishlistButton> createState() => _WishlistButtonState();
}

class _WishlistButtonState extends ConsumerState<WishlistButton> {
  bool _isInWishlist = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    final notifier = ref.read(wishlistProvider.notifier);

    final inWishlist = widget.type == WishlistItemType.component
        ? await notifier.isComponentInWishlist(widget.itemId)
        : await notifier.isBuildInWishlist(widget.itemId);

    if (mounted) {
      setState(() {
        _isInWishlist = inWishlist;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleWishlist() async {
    setState(() {
      _isLoading = true;
    });

    final notifier = ref.read(wishlistProvider.notifier);
    bool success = false;

    if (widget.type == WishlistItemType.component) {
      success = await notifier.toggleComponent(widget.itemId);
    } else {
      success = await notifier.toggleBuild(widget.itemId);
    }

    if (success && mounted) {
      setState(() {
        _isInWishlist = !_isInWishlist;
        _isLoading = false;
      });

      // Show feedback
      ToastUtils.showSuccess(
        _isInWishlist
            ? 'Added to wishlist'
            : 'Removed from wishlist',
      );
    } else if (mounted) {
      setState(() {
        _isLoading = false;
      });

      ToastUtils.showError('Failed to update wishlist');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.showLabel
          ? ElevatedButton.icon(
              onPressed: null,
              icon: const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              label: const Text('Loading...'),
              style: widget.style,
            )
          : IconButton(
              onPressed: null,
              icon: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
    }

    final icon = _isInWishlist
        ? (widget.filledIcon ?? Icons.favorite)
        : (widget.outlineIcon ?? Icons.favorite_border);

    final color = _isInWishlist ? Colors.red : null;

    if (widget.showLabel) {
      return ElevatedButton.icon(
        onPressed: _toggleWishlist,
        icon: Icon(icon, color: color),
        label: Text(_isInWishlist ? 'In Wishlist' : 'Add to Wishlist'),
        style: widget.style,
      );
    }

    return IconButton(
      onPressed: _toggleWishlist,
      icon: Icon(icon),
      color: color,
      tooltip: _isInWishlist ? 'Remove from wishlist' : 'Add to wishlist',
    );
  }
}

/// Type of wishlist item (matches the model enum)
enum WishlistItemType {
  component,
  build,
}
