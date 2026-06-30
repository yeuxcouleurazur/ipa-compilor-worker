import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/token.dart';

class TokenCard extends StatelessWidget {
  final Token token;
  final Animation<double> animation;

  const TokenCard({
    super.key,
    required this.token,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final isNegative = token.priceChange24h < 0;
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.5, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: FadeTransition(
        opacity: animation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Icon Placeholder (using letters/colors for now if asset fails, but aiming for asset)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  // In a real app we'd load the image, here we use a simple colored circle with initial
                ),
                alignment: Alignment.center,
                child: Text(
                  token.symbol[0],
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Name & Balance
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          token.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified,
                          color: Color(0xFFA693F5),
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${token.balance} ${token.symbol}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF8E8E93),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Fiat Balance & Change
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormatter.format(token.balanceFiat),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isNegative ? '' : '+'}${currencyFormatter.format(token.priceChange24h)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isNegative ? const Color(0xFFFF5252) : const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
