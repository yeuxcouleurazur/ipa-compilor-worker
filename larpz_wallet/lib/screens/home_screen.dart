import 'package:flutter/material.dart';
import '../models/token.dart';
import '../widgets/action_button.dart';
import '../widgets/animated_balance.dart';
import '../widgets/token_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _listAnimController;
  
  final List<Token> tokens = [
    Token(
      symbol: 'BTC',
      name: 'Bitcoin',
      balance: 21.36523,
      balanceFiat: 1463454.16,
      fiatPrice: 68500.00,
      priceChange24h: -14190.84,
      iconAsset: 'assets/btc.png',
    ),
    Token(
      symbol: 'SOL',
      name: 'Solana',
      balance: 2523.91040,
      balanceFiat: 212588.97,
      fiatPrice: 84.23,
      priceChange24h: -7487.02,
      iconAsset: 'assets/sol.png',
    ),
    Token(
      symbol: 'ETH',
      name: 'Ethereum',
      balance: 35.00000,
      balanceFiat: 69342.70,
      fiatPrice: 1981.22,
      priceChange24h: -1071.27,
      iconAsset: 'assets/eth.png',
    ),
    Token(
      symbol: 'MON',
      name: 'Monad',
      balance: 0.0,
      balanceFiat: 0.0,
      fiatPrice: 0.0,
      priceChange24h: 0.0,
      iconAsset: 'assets/mon.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Start list animation slightly delayed
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _listAnimController.forward();
    });
  }

  @override
  void dispose() {
    _listAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            _listAnimController.reset();
            _listAnimController.forward();
            await Future.delayed(const Duration(seconds: 1));
          },
          color: const Color(0xFFA693F5),
          backgroundColor: const Color(0xFF1C1C1E),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildBalanceSection(),
                  const SizedBox(height: 32),
                  _buildActionsRow(),
                  const SizedBox(height: 32),
                  _buildCashBalanceCard(),
                  const SizedBox(height: 32),
                  _buildTokensList(),
                  const SizedBox(height: 120), // Bottom padding for TabBar
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Profile Picture
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1C1C1E),
          ),
          alignment: Alignment.center,
          child: const Text(
            '💸',
            style: TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(width: 12),
        // Username
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              '@larpzwallet',
              style: TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 13,
              ),
            ),
            Text(
              'LarpzWallet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        // Icons
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.history, color: Colors.white, size: 28),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.search, color: Colors.white, size: 28),
        ),
      ],
    );
  }

  Widget _buildBalanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBalance(
          balance: 1745385.83,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2C1C1E), // Dark reddish
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '-\$22,749.13',
                style: TextStyle(
                  color: Color(0xFFFF5252),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF5252),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '-1.30%',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ActionButton(
          icon: Icons.send_outlined,
          label: 'Send',
          onTap: () {},
        ),
        ActionButton(
          icon: Icons.swap_horiz,
          label: 'Swap',
          onTap: () {},
        ),
        ActionButton(
          icon: Icons.qr_code_2,
          label: 'Receive',
          onTap: () {},
        ),
        ActionButton(
          icon: Icons.attach_money,
          label: 'Buy',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildCashBalanceCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Cash Balance',
                style: TextStyle(
                  color: Color(0xFF8E8E93),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '\$0.00',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA693F5),
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Add Cash',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokensList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text(
              'Tokens',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Color(0xFF8E8E93),
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tokens.length,
          itemBuilder: (context, index) {
            // Calculate a staggered animation interval for each card
            final startTime = (index * 0.1).clamp(0.0, 1.0);
            final endTime = (startTime + 0.4).clamp(0.0, 1.0);
            final animation = CurvedAnimation(
              parent: _listAnimController,
              curve: Interval(startTime, endTime, curve: Curves.easeOutCubic),
            );

            return TokenCard(
              token: tokens[index],
              animation: animation,
            );
          },
        ),
      ],
    );
  }
}
