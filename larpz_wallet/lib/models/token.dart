class Token {
  final String symbol;
  final String name;
  final double balance;
  final double balanceFiat;
  final double fiatPrice;
  final double priceChange24h;
  final String iconAsset;

  Token({
    required this.symbol,
    required this.name,
    required this.balance,
    required this.balanceFiat,
    required this.fiatPrice,
    required this.priceChange24h,
    required this.iconAsset,
  });
}
