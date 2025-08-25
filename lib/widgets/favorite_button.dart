import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoriteButton extends StatefulWidget {
  final String identifier; // Unique key e.g., 'dhikr_1_2' or 'hadith_bukhari_5'
  final String content;

  const FavoriteButton({super.key, required this.identifier, required this.content});

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = prefs.containsKey(widget.identifier);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavorite = !_isFavorite;
      if (_isFavorite) {
        prefs.setString(widget.identifier, widget.content);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت الإضافة إلى المفضلة')),
        );
      } else {
        prefs.remove(widget.identifier);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تمت الإزالة من المفضلة')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFavorite ? Icons.favorite : Icons.favorite_border,
        color: Colors.redAccent,
      ),
      onPressed: _toggleFavorite,
    );
  }
}