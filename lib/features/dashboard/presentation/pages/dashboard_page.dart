import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/bloc/theme_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../diamond/presentation/pages/diamond_search_page.dart';
import '../../../diamond/presentation/pages/diamond_detail_page.dart';
import 'edit_profile_page.dart';
import 'contact_us_page.dart';
import '../widgets/app_drawer.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import '../../../wishlist/presentation/pages/wishlist_page.dart';
import '../../../wishlist/presentation/bloc/wishlist_cubit.dart';
import '../../../diamond/presentation/bloc/diamond_bloc.dart';
import '../../../diamond/presentation/bloc/diamond_event.dart';
import '../../../diamond/presentation/bloc/diamond_state.dart';
import '../../../diamond/data/models/diamond_model.dart';
import '../../../../core/utils/dialog_utils.dart';
import 'dart:ui';
import '../../../version_check/presentation/bloc/version_bloc.dart';
import '../../../version_check/presentation/bloc/version_state.dart';
import '../../../version_check/presentation/widgets/update_dialog.dart';
import '../../../version_check/data/models/version_model.dart';

class DashboardPage extends StatefulWidget {
  final String userId;
  final String userName;
  final String userEmail;

  const DashboardPage({
    super.key,
    required this.userId,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _updateDialogShown = false;

  final List<Map<String, dynamic>> _diamondShapes = [
    {'name': 'Round', 'image': 'assets/images/round-grey.png'},
    {'name': 'Princess', 'image': 'assets/images/princess-grey.png'},
    {'name': 'Cushion Modified', 'image': 'assets/images/cushion-modifie-grey.png'},
    {'name': 'Cushion Brilliant', 'image': 'assets/images/cushion-brillia-grey.png'},
    {'name': 'LCU', 'image': 'assets/images/lcu-grey.png'},
    {'name': 'Old Miner', 'image': 'assets/images/cushion-grey.png'},
    {'name': 'Square Emerald', 'image': 'assets/images/square-emerald-grey.png'},
    {'name': 'Emerald', 'image': 'assets/images/emerald-grey.png'},
    {'name': 'Oval', 'image': 'assets/images/oval-grey.png'},
    {'name': 'Radiant', 'image': 'assets/images/radiant-grey.png'},
    {'name': 'Asscher', 'image': 'assets/images/asscher-grey.png'},
    {'name': 'Marquise', 'image': 'assets/images/marquise-grey.png'},
    {'name': 'Heart', 'image': 'assets/images/heart-grey.png'},
    {'name': 'Pear', 'image': 'assets/images/pear-grey.png'},
    {'name': 'Other', 'image': 'assets/images/other-grey.png'},
  ];

  @override
  void initState() {
    super.initState();
    // Dispatch initial fetch events so data is available
    context.read<DiamondBloc>().add(const FetchDiamonds());
    if (widget.userId != 'guest') {
      context.read<WishlistCubit>().fetchWishlist();
      context.read<CartBloc>().add(FetchCart());
      context.read<AuthBloc>().add(AuthGetProfileRequested(userId: widget.userId));
    }

    // Check if update is already available from early check in main.dart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final versionBloc = context.read<VersionBloc>();
      if (versionBloc.state is VersionUpdateAvailable) {
        final state = versionBloc.state as VersionUpdateAvailable;
        _showUpdateDialog(state.versionInfo);
      }
    });
  }

  void _showUpdateDialog(VersionModel versionInfo) {
    if (_updateDialogShown) return;
    _updateDialogShown = true;
    showDialog(
      context: context,
      barrierDismissible: !versionInfo.forceUpdate,
      builder: (context) => UpdateDialog(versionInfo: versionInfo),
    ).then((_) {
      _updateDialogShown = false;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    // Dynamic Counts
    final diamondState = context.watch<DiamondBloc>().state;
    int totalDiamonds = 0;
    List<DiamondModel> featuredDiamonds = [];

    if (diamondState is DiamondLoaded) {
      totalDiamonds = diamondState.unfilteredTotalCount;
      if (totalDiamonds == 0) totalDiamonds = diamondState.totalRecords;
      featuredDiamonds = diamondState.diamonds.take(3).toList();
    }

    // Fallback Mock featured diamonds to display in "Exceptional Diamonds" section if empty
    if (featuredDiamonds.isEmpty) {
      featuredDiamonds = [
        DiamondModel(
          diamondId: 'mock-1',
          shape: 'Round',
          weight: '1.02',
          color: 'D',
          grade: 'FL',
          cut: 'EX',
          polish: 'EX',
          symmetry: 'EX',
          lab: 'GIA',
          totalPrice: '7500',
        ),
        DiamondModel(
          diamondId: 'mock-2',
          shape: 'Oval',
          weight: '1.51',
          color: 'E',
          grade: 'VVS1',
          cut: 'EX',
          polish: 'EX',
          symmetry: 'EX',
          lab: 'GIA',
          totalPrice: '9200',
        ),
        DiamondModel(
          diamondId: 'mock-3',
          shape: 'Cushion',
          weight: '2.01',
          color: 'F',
          grade: 'VS1',
          cut: 'EX',
          polish: 'EX',
          symmetry: 'EX',
          lab: 'GIA',
          totalPrice: '12400',
        ),
      ];
    }

    final wishlistState = context.watch<WishlistCubit>().state;
    int wishlistCount = 0;
    if (wishlistState is WishlistLoaded) wishlistCount = wishlistState.items.length;

    final cartState = context.watch<CartBloc>().state;
    int cartCount = 0;
    if (cartState is CartLoaded) cartCount = cartState.cartItems.length;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is AuthProfileLoadFailure) {
              if (state.errorMessage.contains('User not found') || state.errorMessage.contains('not found')) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_id');
                await prefs.remove('user_name');
                await prefs.remove('user_email');
                if (context.mounted) {
                  context.read<AuthBloc>().add(const AuthLogoutRequested());
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            }
          },
        ),
        BlocListener<VersionBloc, VersionState>(
          listener: (context, state) {
            if (state is VersionUpdateAvailable) {
              _showUpdateDialog(state.versionInfo);
            }
          },
        ),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: isDark ? AppConstants.backgroundColor : const Color(0xFFFAF8F5), // Premium cream/beige background from screenshot
        drawer: AppDrawer(
          currentPage: 'dashboard',
          userId: widget.userId,
          userName: widget.userName,
          userEmail: widget.userEmail,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 1. Sleek Premium Header
              _buildHeader(context, isDark, accentColor, wishlistCount, cartCount),
              
              // 2. Main Scrollable Dashboard Content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero Banner Section
                      _buildHeroSection(context, isDark, accentColor, totalDiamonds, cartCount),
                      
                      // Legacy Section ("Confidence in Every Carat")
                      // _buildLegacySection(context, isDark, accentColor),
                      
                      // Shop by Shape Section ("Every Shape Tells a Different Story")
                      _buildShapeGridSection(context, isDark, accentColor, cartCount),
                      
                      // Process steps ("A Seamless Path from Inquiry to Delivery")
                      // _buildProcessSection(context, isDark, accentColor),
                      
                      // Featured Inventory ("Exceptional Diamonds, Ready to Ship")
                      _buildFeaturedInventorySection(context, isDark, accentColor, featuredDiamonds, cartCount),
                      
                      // Certifications ("Certification You Can Trust")
                      _buildCertificationsSection(context, isDark, accentColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    Color accentColor,
    int wishlistCount,
    int cartCount,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spaceMD + 4,
        vertical: AppConstants.spaceSM + 2,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withOpacity(0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.userName.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceMD - 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_getGreeting()},',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                        ),
                      ),
                      Text(
                        widget.userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.playfairDisplay(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : const Color(0xFF2E6F40),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Theme Toggle
              _buildHeaderIcon(
                icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                onPressed: () {
                  context.read<ThemeBloc>().add(const ThemeToggleRequested());
                },
                isDark: isDark,
              ),
              const SizedBox(width: 6),
              
              // Wishlist
              Stack(
                alignment: Alignment.center,
                children: [
                  _buildHeaderIcon(
                    icon: Icons.favorite_border_rounded,
                    onPressed: () {
                      if (widget.userId == 'guest') {
                        DialogUtils.showLoginRequiredDialog(context);
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const WishlistPage()),
                      );
                    },
                    isDark: isDark,
                  ),
                  if (wishlistCount > 0)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppConstants.accentSecondary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$wishlistCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),

              // Cart
              Stack(
                alignment: Alignment.center,
                children: [
                  _buildHeaderIcon(
                    icon: Icons.shopping_cart_outlined,
                    onPressed: () {
                      if (widget.userId == 'guest') {
                        DialogUtils.showLoginRequiredDialog(context);
                        return;
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartPage()),
                      );
                    },
                    isDark: isDark,
                  ),
                  if (cartCount > 0)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppConstants.accentSecondary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 14,
                          minHeight: 14,
                        ),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 6),

              // Logout / Guest Login
              _buildHeaderIcon(
                icon: widget.userId == 'guest'
                    ? Icons.login_rounded
                    : Icons.power_settings_new_rounded,
                iconColor: widget.userId == 'guest' ? accentColor : AppConstants.errorColor,
                onPressed: () async {
                  if (widget.userId == 'guest') {
                    final navigator = Navigator.of(context);
                    final authBloc = context.read<AuthBloc>();
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('user_id');
                    await prefs.remove('user_name');
                    await prefs.remove('user_email');
                    authBloc.add(const AuthLogoutRequested());
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  } else {
                    DialogUtils.showLogoutConfirmDialog(context, () async {
                      final navigator = Navigator.of(context);
                      final authBloc = context.read<AuthBloc>();
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('user_id');
                      await prefs.remove('user_name');
                      await prefs.remove('user_email');
                      authBloc.add(const AuthLogoutRequested());
                      navigator.pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    });
                  }
                },
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIcon({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
    Color? iconColor,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor ?? (isDark ? Colors.white : const Color(0xFF2E6F40)),
          size: 18,
        ),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: isDark ? AppConstants.surfaceColor : const Color(0xFFF1F6F3),
          side: BorderSide(
            color: isDark ? AppConstants.borderLight : const Color(0xFFE2EBE5),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  // 1. Hero Section (Partner for B2B Diamond Trading)
  Widget _buildHeroSection(
    BuildContext context,
    bool isDark,
    Color accentColor,
    int totalDiamonds,
    int cartCount,
  ) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.spaceMD),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.0),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF13201A), const Color(0xFF0C1310)]
              : [const Color(0xFFE2ECE7), const Color(0xFFFAF8F5)], // Soft green to cream gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark ? const Color(0xFF1B4D3E) : const Color(0xFFD3DFDA),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppConstants.accentColorDark.withOpacity(0.15)
                        : const Color(0xFF398860).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'B2B GEM TRADING',
                    style: GoogleFonts.nunito(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppConstants.accentColorDark : const Color(0xFF2E6F40),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Partner for B2B\nDiamond Trading',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2E6F40),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Certified diamonds for current making and daily orders with customized solutions at factory rates.',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    // Explore Collection Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DiamondSearchPage(
                              currentCartCount: cartCount,
                              onCartUpdated: (_) {},
                              userId: widget.userId,
                              userName: widget.userName,
                              userEmail: widget.userEmail,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppConstants.accentColorDark : const Color(0xFF398860),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        'Explore Collection',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Contact Us text button
                    TextButton(
                      onPressed: () {
                        if (widget.userId == 'guest') {
                          DialogUtils.showLoginRequiredDialog(context);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ContactUsPage(
                                userId: widget.userId,
                                userName: widget.userName,
                                userEmail: widget.userEmail,
                              ),
                            ),
                          );
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? AppConstants.accentColorDark : const Color(0xFF398860),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: Text(
                        'Contact Us',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2. Legacy Section ("Confidence in Every Carat")
  Widget _buildLegacySection(BuildContext context, bool isDark, Color accentColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD, vertical: AppConstants.spaceSM),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isDark ? AppConstants.borderLight : const Color(0xFFE8EDE9),
        ),
        boxShadow: AppConstants.glassShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ABOUT OUR LEGACY',
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isDark ? AppConstants.accentColorDark : const Color(0xFF2E6F40),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Confidence in Every Carat',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2E6F40),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'With decades of heritage, we source, certify, and supply diamonds to top global jewelers, maintaining the absolute highest standards.',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          
          // Legacy Bullet Points Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.5,
            children: [
              _buildLegacyBullet(isDark, 'Certified Diamonds', Icons.workspace_premium_rounded),
              _buildLegacyBullet(isDark, 'Quick Delivery', Icons.local_shipping_rounded),
              _buildLegacyBullet(isDark, 'Custom Jewelry', Icons.draw_rounded),
              _buildLegacyBullet(isDark, 'Professional Support', Icons.support_agent_rounded),
            ],
          ),
          
          const SizedBox(height: 16),
          Divider(color: isDark ? AppConstants.borderLight : const Color(0xFFE8EDE9)),
          const SizedBox(height: 8),
          
          // Learn More Link
          GestureDetector(
            onTap: () {
              if (widget.userId == 'guest') {
                DialogUtils.showLoginRequiredDialog(context);
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ContactUsPage(
                      userId: widget.userId,
                      userName: widget.userName,
                      userEmail: widget.userEmail,
                    ),
                  ),
                );
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Learn More about us',
                  style: GoogleFonts.playfairDisplay(
                    color: isDark ? AppConstants.accentColorDark : const Color(0xFF398860),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: isDark ? AppConstants.accentColorDark : const Color(0xFF398860),
                  size: 14,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyBullet(bool isDark, String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isDark ? AppConstants.accentColorDark : const Color(0xFF398860),
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // 3. Shop by Shape Section ("Every Shape Tells a Different Story")
  Widget _buildShapeGridSection(BuildContext context, bool isDark, Color accentColor, int cartCount) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD, vertical: AppConstants.spaceSM),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isDark ? AppConstants.borderLight : const Color(0xFFE8EDE9),
        ),
        boxShadow: AppConstants.glassShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DIAMOND SHAPES',
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isDark ? AppConstants.accentColorDark : const Color(0xFF2E6F40),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Every Shape Tells a Story',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2E6F40),
            ),
          ),
          const SizedBox(height: 16),
          
          // Shape Cards grid (5 columns for compact mobile layout)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _diamondShapes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 0.65,
            ),
            itemBuilder: (context, index) {
              final shape = _diamondShapes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => DiamondSearchPage(
                        currentCartCount: cartCount,
                        onCartUpdated: (_) {},
                        userId: widget.userId,
                        userName: widget.userName,
                        userEmail: widget.userEmail,
                        initialSelectedShapes: [shape['name'] as String],
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C24) : const Color(0xFFFAFBF9),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: isDark ? AppConstants.borderLight : const Color(0xFFE2EBE5),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Diamond Shape outline drawing from assets
                      Image.asset(
                        shape['image'] as String,
                        width: 24,
                        height: 24,
                        color: isDark ? Colors.white : const Color(0xFF2E6F40),
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shape['name'] as String,
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppConstants.lightTextPrimary,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 4. Process steps ("A Seamless Path from Inquiry to Delivery")
  Widget _buildProcessSection(BuildContext context, bool isDark, Color accentColor) {
    final List<Map<String, dynamic>> steps = [
      {'title': 'Inquiry', 'icon': Icons.mail_outline_rounded},
      {'title': 'Selection', 'icon': Icons.diamond_outlined},
      {'title': 'Quotation', 'icon': Icons.description_outlined},
      {'title': 'Confirm', 'icon': Icons.check_circle_outline_rounded},
      {'title': 'Shipping', 'icon': Icons.local_shipping_outlined},
      {'title': 'Delivery', 'icon': Icons.flag_outlined},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD, vertical: AppConstants.spaceSM),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isDark ? AppConstants.borderLight : const Color(0xFFE8EDE9),
        ),
        boxShadow: AppConstants.glassShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'OUR PROCESS LOGISTICS',
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isDark ? AppConstants.accentColorDark : const Color(0xFF2E6F40),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Inquiry to Delivery Path',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2E6F40),
            ),
          ),
          const SizedBox(height: 16),
          
          // Horizontal Process steps
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                return Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1C1C24) : const Color(0xFFEAF1ED),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark ? AppConstants.borderLight : const Color(0xFFD2E2D8),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            step['icon'] as IconData,
                            color: isDark ? AppConstants.accentColorDark : const Color(0xFF398860),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step['title'] as String,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (index < steps.length - 1)
                      Container(
                        width: 24,
                        height: 1.5,
                        margin: const EdgeInsets.fromLTRB(8, 0, 8, 20),
                        color: isDark ? AppConstants.borderLight : const Color(0xFFD2E2D8),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 5. Featured Inventory ("Exceptional Diamonds, Ready to Ship")
  Widget _buildFeaturedInventorySection(
    BuildContext context,
    bool isDark,
    Color accentColor,
    List<DiamondModel> diamonds,
    int cartCount,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD, vertical: AppConstants.spaceSM),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isDark ? AppConstants.borderLight : const Color(0xFFE8EDE9),
        ),
        boxShadow: AppConstants.glassShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FEATURED STOCKS',
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isDark ? AppConstants.accentColorDark : const Color(0xFF2E6F40),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Exceptional Diamonds',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2E6F40),
            ),
          ),
          const SizedBox(height: 16),
          
          // Vertical Cards list (Max 3 diamonds)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: diamonds.length,
            itemBuilder: (context, index) {
              final d = diamonds[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1C24) : const Color(0xFFFAFBF9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppConstants.borderLight : const Color(0xFFE2EBE5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.diamond_rounded, color: Color(0xFF398860), size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${d.weight ?? "0.00"} ct ${d.shape ?? "Diamond"}',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppConstants.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        // Lab Certification Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF398860),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            d.lab ?? 'GIA',
                            style: GoogleFonts.nunito(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(color: isDark ? AppConstants.borderLight : const Color(0xFFE2EBE5), height: 1),
                    const SizedBox(height: 12),
                    
                    // Specific characteristics values
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailCell(isDark, 'Carat', d.weight ?? '-'),
                        _buildDetailCell(isDark, 'Color', d.color ?? '-'),
                        _buildDetailCell(isDark, 'Clarity', d.grade ?? '-'),
                        _buildDetailCell(isDark, 'Cut', d.cut ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    
                    // View Details Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.userId == 'guest'
                              ? 'Login to view price'
                              : '\$${d.totalPrice != null ? (double.tryParse(d.totalPrice!) ?? 0.0).toStringAsFixed(2) : "N/A"}',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: widget.userId == 'guest'
                                ? Colors.grey
                                : (isDark ? AppConstants.accentColorDark : const Color(0xFF398860)),
                          ),
                        ),
                        SizedBox(
                          height: 36,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DiamondDetailPage(diamond: d),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppConstants.accentColorDark.withOpacity(0.12)
                                  : const Color(0xFF398860).withOpacity(0.08),
                              foregroundColor: isDark ? AppConstants.accentColorDark : const Color(0xFF398860),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View Details',
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCell(bool isDark, String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppConstants.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  // 6. Certifications Section ("Certification You Can Trust")
  Widget _buildCertificationsSection(BuildContext context, bool isDark, Color accentColor) {
    final List<String> labs = ['GIA', 'IGI', 'HRD', 'IGI-INDIA'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD, vertical: AppConstants.spaceSM),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: isDark ? AppConstants.borderLight : const Color(0xFFE8EDE9),
        ),
        boxShadow: AppConstants.glassShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CERTIFICATE LABS',
            style: GoogleFonts.nunito(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: isDark ? AppConstants.accentColorDark : const Color(0xFF2E6F40),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Certifications You Can Trust',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF2E6F40),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: labs.map((lab) {
              return Expanded(
                child: Container(
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C24) : const Color(0xFFFAFBF9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? AppConstants.borderLight : const Color(0xFFE2EBE5),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    lab,
                    style: GoogleFonts.playfairDisplay(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white70 : const Color(0xFF398860),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
