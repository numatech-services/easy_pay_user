import 'dart:async';

import 'package:flutter/material.dart';

class TimestampWidget extends StatefulWidget {
  final bool isValid;
  final String cardStatus;

  const TimestampWidget({
    Key? key,
    required this.isValid,
    required this.cardStatus,
  }) : super(key: key);

  @override
  State<TimestampWidget> createState() => _TimestampWidgetState();
}

class _TimestampWidgetState extends State<TimestampWidget> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Mise à jour chaque seconde
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String _formatDate(DateTime time) {
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    final year = time.year;
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    // Couleurs selon documentation ISIC
    final bgColor = widget.isValid
        ? const Color(0xFF4A4A4A) // Gris pour carte valide
        : const Color(0xFFFF0000); // Rouge pour carte expirée

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Status badge à gauche
          Row(
            children: [
              if (widget.isValid)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22BB44), // Vert selon doc
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                widget.isValid ? 'VALID' : 'EXPIRED',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          // Date et heure à droite
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDate(_currentTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatTime(_currentTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
