import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedBalance extends StatefulWidget {
  final double balance;
  final TextStyle style;

  const AnimatedBalance({
    super.key,
    required this.balance,
    required this.style,
  });

  @override
  State<AnimatedBalance> createState() => _AnimatedBalanceState();
}

class _AnimatedBalanceState extends State<AnimatedBalance> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: widget.balance).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedBalance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.balance != widget.balance) {
      _animation = Tween<double>(begin: oldWidget.balance, end: widget.balance).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          currencyFormatter.format(_animation.value),
          style: widget.style,
        );
      },
    );
  }
}
