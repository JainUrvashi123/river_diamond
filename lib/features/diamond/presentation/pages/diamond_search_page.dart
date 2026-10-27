import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../widgets/diamond_share_dialog.dart';
import '../../../../core/bloc/theme_bloc.dart';
import '../../../../core/utils/constants.dart';
import '../../../wishlist/presentation/pages/wishlist_page.dart';
import '../../../../features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import '../../../../features/wishlist/presentation/bloc/wishlist_cubit.dart';
import '../../data/models/diamond_model.dart';
import '../../../dashboard/presentation/widgets/app_drawer.dart';
import '../bloc/diamond_bloc.dart';
import '../bloc/diamond_event.dart';
import '../bloc/diamond_state.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'diamond_detail_page.dart';
import 'compare_page.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/bloc/cart_bloc.dart';
import '../../../cart/presentation/bloc/cart_event.dart';
import '../../../cart/presentation/bloc/cart_state.dart';
import 'package:url_launcher/url_launcher.dart';

class DiamondSearchPage extends StatefulWidget {
  final int currentCartCount;
  final ValueChanged<int> onCartUpdated;
  final String userId;
  final String userName;
  final String userEmail;
  final List<String>? initialSelectedShapes;
  final List<String>? initialSelectedColors;
  final List<String>? initialSelectedClarities;
  final List<String>? initialSelectedCuts;
  final List<String>? initialSelectedPolishes;
  final List<String>? initialSelectedSymmetries;

  const DiamondSearchPage({
    super.key,
    required this.currentCartCount,
    required this.onCartUpdated,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.initialSelectedShapes,
    this.initialSelectedColors,
    this.initialSelectedClarities,
    this.initialSelectedCuts,
    this.initialSelectedPolishes,
    this.initialSelectedSymmetries,
  });

  @override
  State<DiamondSearchPage> createState() => _DiamondSearchPageState();
}

class _DiamondSearchPageState extends State<DiamondSearchPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // State variables for filter values
  bool _isAdvanceExpanded = false;
  int _currentFilteredCount = 0;
  Timer? _debounce;
  bool _isGridView = false;
  final Set<DiamondModel> _selectedDiamonds = {};
  final Set<String> _loadingStockIds = {};
  String _currentSortOption = 'None';
  
  final List<String> _selectedShapes = [];

  // Controllers for basic ranges (Carat & Price From/To)
  final TextEditingController _caratFromController = TextEditingController(text: '0.10');
  final TextEditingController _caratToController = TextEditingController(text: '10.00');
  final TextEditingController _priceFromController = TextEditingController(text: '0');
  final TextEditingController _priceToController = TextEditingController(text: '100000');

  // Controllers for advanced filters (Depth %, Table %, Cert No)
  final TextEditingController _depthMinController = TextEditingController();
  final TextEditingController _depthMaxController = TextEditingController();
  final TextEditingController _tableMinController = TextEditingController();
  final TextEditingController _tableMaxController = TextEditingController();
  final TextEditingController _stockNoController = TextEditingController();
  
  final TextEditingController _ratioFromController = TextEditingController();
  final TextEditingController _ratioToController = TextEditingController();
  final TextEditingController _crAngleFromController = TextEditingController();
  final TextEditingController _crAngleToController = TextEditingController();
  final TextEditingController _crHeightFromController = TextEditingController();
  final TextEditingController _crHeightToController = TextEditingController();
  final TextEditingController _pavAngleFromController = TextEditingController();
  final TextEditingController _pavAngleToController = TextEditingController();
  final TextEditingController _pavHeightFromController = TextEditingController();
  final TextEditingController _pavHeightToController = TextEditingController();
  final TextEditingController _girdleFromController = TextEditingController();
  final TextEditingController _girdleToController = TextEditingController();
  final TextEditingController _starLengthFromController = TextEditingController();
  final TextEditingController _starLengthToController = TextEditingController();

  // Multi-select Lists for basic specifications
  final List<String> _selectedColors = [];
  final List<String> _selectedFancyColors = [];
  final List<String> _selectedClarities = [];
  final List<String> _selectedCuts = [];
  final List<String> _selectedPolishes = [];
  final List<String> _selectedSymmetries = [];
  final List<String> _selectedLabs = [];
  final List<String> _selectedFluorescences = [];
  final List<String> _selectedMakes = [];
  final List<String> _selectedCulets = [];
  // final List<String> _selectedAvailable = [];


  // State cart counter
  late int _localCartCount;

  final List<String> _shapes = [
    'Round', 'Princess', 'Cushion', 'Cushion Modified', 'Cushion Brilliant', 
    'LCU', 'Old Miner', 'Square Emerald', 'Emerald', 'Oval', 
    'Radiant', 'Asscher', 'Marquise', 'Heart', 'Pear', 'Other'
  ];
  final List<String> _colors = ['D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M-', 'FANCY'];
  final List<String> _fancyColors = ['blue', 'green', 'yellow', 'pink', 'purple', 'red', 'orange', 'black', 'brown'];
  final List<String> _clarities = ['FL', 'IF', 'VVS1', 'VVS2', 'VS1', 'VS2', 'SI1', 'SI2', 'I1-'];
  final List<String> _cuts = ['BX', 'I', 'EX', 'VG', 'G', 'F'];
  final List<String> _polishes = ['EX', 'VG', 'G', 'F'];
  final List<String> _symmetries = ['EX', 'VG', 'G', 'F'];
  final List<String> _labs = ['IGI', 'GIA', 'AGS'];
  final List<String> _fluorescences = ['None', 'Faint', 'Medium', 'Strong', 'Very Strong'];
  final List<String> _makes = ['3EX', '3VG+', '3EX-NONE'];
  final List<String> _culets = ['N', 'VSM', 'SML', 'MED', 'LARGE'];

  // Lists for advanced dropdown values
  final List<String> _yesNoOptions = ['All', 'Yes', 'No'];
  final List<String> _shades = ['All', 'White', 'Brown', 'Yellow', 'Other'];
  final List<String> _milkOptions = ['All', 'None', 'M0', 'M1', 'M2', 'M3'];
  final List<String> _lusterOptions = ['All', 'Excellent', 'Very Good', 'Good'];
  final List<String> _bgmOptions = ['All', 'None', 'Brown', 'Green', 'Milky'];
  final List<String> _inclusions = ['All', 'None', 'Center', 'Edge'];
  final List<String> _locations = ['All', 'India', 'USA', 'Belgium', 'Israel'];

  @override
  void initState() {
    super.initState();
    _localCartCount = widget.currentCartCount;
    if (widget.initialSelectedShapes != null) {
      _selectedShapes.addAll(widget.initialSelectedShapes!);
    }
    if (widget.initialSelectedColors != null) {
      _selectedColors.addAll(widget.initialSelectedColors!);
    }
    if (widget.initialSelectedClarities != null) {
      _selectedClarities.addAll(widget.initialSelectedClarities!);
    }
    if (widget.initialSelectedCuts != null) {
      _selectedCuts.addAll(widget.initialSelectedCuts!);
    }
    if (widget.initialSelectedPolishes != null) {
      _selectedPolishes.addAll(widget.initialSelectedPolishes!);
    }
    if (widget.initialSelectedSymmetries != null) {
      _selectedSymmetries.addAll(widget.initialSelectedSymmetries!);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilters();
      context.read<CartBloc>().add(FetchCart()); // Fetch cart to get accurate total quantity
      context.read<WishlistCubit>().fetchWishlist(); // Fetch wishlist to get accurate total quantity
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _caratFromController.dispose();
    _caratToController.dispose();
    _priceFromController.dispose();
    _priceToController.dispose();
    _depthMinController.dispose();
    _depthMaxController.dispose();
    _tableMinController.dispose();
    _tableMaxController.dispose();
    _stockNoController.dispose();
    _ratioFromController.dispose();
    _ratioToController.dispose();
    _crAngleFromController.dispose();
    _crAngleToController.dispose();
    _crHeightFromController.dispose();
    _crHeightToController.dispose();
    _pavAngleFromController.dispose();
    _pavAngleToController.dispose();
    _pavHeightFromController.dispose();
    _pavHeightToController.dispose();
    _girdleFromController.dispose();
    _girdleToController.dispose();
    _starLengthFromController.dispose();
    _starLengthToController.dispose();
    super.dispose();
  }


  void _addToCart(DiamondModel diamond) async {
    final stockId = diamond.stockId ?? "";
    if (stockId.isEmpty) return;

    setState(() {
      _loadingStockIds.add(stockId);
    });

    try {
      final success = await context.read<DiamondBloc>().repository.addToCart(
        stock: stockId,
      );

      if (mounted) {
        if (success) {
          context.read<CartBloc>().add(FetchCart());
          setState(() {
            _loadingStockIds.remove(stockId);
            _localCartCount++; // Optimistic local update
          });
          widget.onCartUpdated(_localCartCount);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${diamond.weight ?? ""} ct ${diamond.shape ?? ""} to cart!'),
              backgroundColor: AppConstants.successColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else {
          setState(() {
            _loadingStockIds.remove(stockId);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to add to cart.'),
              backgroundColor: AppConstants.errorColor,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingStockIds.remove(stockId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to cart: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  String _getShapeAsset(String shape) => AppConstants.getShapeAsset(shape);

  void _resetFilters() {
    setState(() {
      _selectedShapes.clear();
      _caratFromController.text = '0.10';
      _caratToController.text = '10.00';
      _priceFromController.text = '0';
      _priceToController.text = '100000';
      _selectedColors.clear();
      _selectedClarities.clear();
      _selectedCuts.clear();
      _selectedPolishes.clear();
      _selectedSymmetries.clear();
      _selectedLabs.clear();
      _selectedFluorescences.clear();
      _selectedMakes.clear();
      _selectedCulets.clear();
      // _selectedAvailable.clear();

      // Advanced resets
      _depthMinController.clear();
      _depthMaxController.clear();
      _tableMinController.clear();
      _tableMaxController.clear();
      _stockNoController.clear();
      _ratioFromController.clear();
      _ratioToController.clear();
      _crAngleFromController.clear();
      _crAngleToController.clear();
      _crHeightFromController.clear();
      _crHeightToController.clear();
      _pavAngleFromController.clear();
      _pavAngleToController.clear();
      _pavHeightFromController.clear();
      _pavHeightToController.clear();
      _girdleFromController.clear();
      _girdleToController.clear();
      _starLengthFromController.clear();
      _starLengthToController.clear();
    });
    _applyFilters();
  }

  void _applyFilters() {
    context.read<DiamondBloc>().add(FetchDiamonds(
      isRefresh: true,
      stock: _stockNoController.text,
      shapes: _selectedShapes.isEmpty ? null : _selectedShapes.map((s) => s.toUpperCase()).toList(),
      colors: _selectedColors,
      fancyColors: _selectedFancyColors,
      clarities: _selectedClarities,
      cuts: _selectedCuts,
      polishes: _selectedPolishes,
      symmetries: _selectedSymmetries,
      labs: _selectedLabs,
      fluorescences: _selectedFluorescences,
      makes: _selectedMakes,
      culets: _selectedCulets,
      // available: _selectedAvailable,
      caratFrom: _caratFromController.text,
      caratTo: _caratToController.text,
      priceFrom: _priceFromController.text,
      priceTo: _priceToController.text,
      ratioFrom: _ratioFromController.text,
      ratioTo: _ratioToController.text,
      depthFrom: _depthMinController.text,
      depthTo: _depthMaxController.text,
      tableFrom: _tableMinController.text,
      tableTo: _tableMaxController.text,
      crAngleFrom: _crAngleFromController.text,
      crAngleTo: _crAngleToController.text,
      crHeightFrom: _crHeightFromController.text,
      crHeightTo: _crHeightToController.text,
      pavAngleFrom: _pavAngleFromController.text,
      pavAngleTo: _pavAngleToController.text,
      pavHeightFrom: _pavHeightFromController.text,
      pavHeightTo: _pavHeightToController.text,
      girdleFrom: _girdleFromController.text,
      girdleTo: _girdleToController.text,
      starLengthFrom: _starLengthFromController.text,
      starLengthTo: _starLengthToController.text,
    ));
  }

  void _onFilterChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _applyFilters();
      }
    });
  }

  void _loadMore() {
    context.read<DiamondBloc>().add(FetchDiamonds(
      isRefresh: false,
      stock: _stockNoController.text,
      shapes: _selectedShapes.isEmpty ? null : _selectedShapes.map((s) => s.toUpperCase()).toList(),
      colors: _selectedColors,
      fancyColors: _selectedFancyColors,
      clarities: _selectedClarities,
      cuts: _selectedCuts,
      polishes: _selectedPolishes,
      symmetries: _selectedSymmetries,
      labs: _selectedLabs,
      fluorescences: _selectedFluorescences,
      makes: _selectedMakes,
      culets: _selectedCulets,
      caratFrom: _caratFromController.text,
      caratTo: _caratToController.text,
      priceFrom: _priceFromController.text,
      priceTo: _priceToController.text,
      ratioFrom: _ratioFromController.text,
      ratioTo: _ratioToController.text,
      depthFrom: _depthMinController.text,
      depthTo: _depthMaxController.text,
      tableFrom: _tableMinController.text,
      tableTo: _tableMaxController.text,
      crAngleFrom: _crAngleFromController.text,
      crAngleTo: _crAngleToController.text,
      crHeightFrom: _crHeightFromController.text,
      crHeightTo: _crHeightToController.text,
      pavAngleFrom: _pavAngleFromController.text,
      pavAngleTo: _pavAngleToController.text,
      pavHeightFrom: _pavHeightFromController.text,
      pavHeightTo: _pavHeightToController.text,
      girdleFrom: _girdleFromController.text,
      girdleTo: _girdleToController.text,
      starLengthFrom: _starLengthFromController.text,
      starLengthTo: _starLengthToController.text,
    ));
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        currentPage: 'search',
        userId: widget.userId,
        userName: widget.userName,
        userEmail: widget.userEmail,
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isDark ? AppConstants.surfaceColor : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? AppConstants.borderLight : const Color(0xFFE2EBE5),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppConstants.surfaceLightColor : const Color(0xFFFAFBF9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppConstants.borderLight : const Color(0xFFD3DFDA),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _currentSortOption == 'None' ? null : _currentSortOption,
              hint: Row(
                children: [
                  Text(
                    'Sort By',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              icon: Icon(Icons.arrow_drop_down, color: accentColor),
              isExpanded: true,
              dropdownColor: isDark ? AppConstants.surfaceLightColor : Colors.white,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              items: <String>[
                'None',
                'Price: Low to High',
                'Price: High to Low',
                'Carat: Low to High',
                'Carat: High to Low',
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentSortOption = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ),
      appBar: AppBar(
        backgroundColor: isDark ? AppConstants.surfaceColor : AppConstants.accentColor,
        elevation: 0,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              )
            : IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 20),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
        centerTitle: true,
        title: Text(
          'Lab Grown Diamond Total ( $_currentFilteredCount )',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              context.read<ThemeBloc>().add(const ThemeToggleRequested());
            },
          ),
          BlocBuilder<WishlistCubit, WishlistState>(
            builder: (context, wishlistState) {
              int wishlistCount = 0;
              if (wishlistState is WishlistLoaded) {
                wishlistCount = wishlistState.items.length;
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistPage())).then((_) {
                        if (context.mounted) {
                          context.read<WishlistCubit>().fetchWishlist();
                        }
                      });
                    },
                  ),
                  if (wishlistCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppConstants.accentSecondary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$wishlistCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            }
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.spaceMD),
            child: Center(
              child: BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
                  int totalQty = 0;
                  if (cartState is CartLoaded) {
                    for (var item in cartState.cartItems) {
                      totalQty += int.tryParse(item.quantity ?? '1') ?? 1;
                    }
                  } else {
                    totalQty = _localCartCount;
                  }

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage()));
                        },
                      ),
                      if (totalQty > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppConstants.accentSecondary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$totalQty',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                }
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<DiamondBloc, DiamondState>(
        builder: (context, state) {
          int listLength = 0;
          List<DiamondModel> diamondList = [];
          if (state is DiamondLoaded) {
            listLength = state.totalRecords;
            diamondList = List.from(state.diamonds);
            if (_currentSortOption == 'Price: Low to High') {
              diamondList.sort((a, b) => (double.tryParse(a.totalPrice ?? '0') ?? 0).compareTo(double.tryParse(b.totalPrice ?? '0') ?? 0));
            } else if (_currentSortOption == 'Price: High to Low') {
              diamondList.sort((a, b) => (double.tryParse(b.totalPrice ?? '0') ?? 0).compareTo(double.tryParse(a.totalPrice ?? '0') ?? 0));
            } else if (_currentSortOption == 'Carat: Low to High') {
              diamondList.sort((a, b) => (double.tryParse(a.weight ?? '0') ?? 0).compareTo(double.tryParse(b.weight ?? '0') ?? 0));
            } else if (_currentSortOption == 'Carat: High to Low') {
              diamondList.sort((a, b) => (double.tryParse(b.weight ?? '0') ?? 0).compareTo(double.tryParse(a.weight ?? '0') ?? 0));
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _currentFilteredCount = state.totalRecords;
                });
              }
            });
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildActionBar(context),
          // 2. Search Summary Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD + 4, vertical: AppConstants.spaceSM),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: AppConstants.successColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$listLength Stones Found',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                        ),
                        child: Icon(
                          _isGridView ? Icons.list_rounded : Icons.grid_view_rounded,
                          color: Theme.of(context).brightness == Brightness.dark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _openFilterBottomSheet(context),
                      child: Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Theme.of(context).brightness == Brightness.dark ? AppConstants.accentColorDark : AppConstants.accentColor, (Theme.of(context).brightness == Brightness.dark ? AppConstants.accentColorDark : AppConstants.accentColor).withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: (Theme.of(context).brightness == Brightness.dark ? AppConstants.accentColorDark : AppConstants.accentColor).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: state is DiamondLoading
                ? ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppConstants.spaceMD),
                        child: Shimmer.fromColors(
                          baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
                          highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
                          child: Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : state is DiamondError
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppConstants.spaceMD),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppConstants.errorColor, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                state.message,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.nunito(
                                  color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _applyFilters,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : diamondList.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  'No Diamonds match your criteria.',
                                  style: GoogleFonts.nunito(color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary, fontSize: 14),
                                ),
                              ],
                            ),
                          )
                    : NotificationListener<ScrollNotification>(
                        onNotification: (ScrollNotification scrollInfo) {
                          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                            if (state is DiamondLoaded && !state.hasReachedMax) {
                              _loadMore();
                            }
                          }
                          return false;
                        },
                        child: _isGridView 
                          ? GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
                              physics: const BouncingScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.65,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: diamondList.length + (state is DiamondLoaded && state.hasReachedMax ? 0 : 1),
                              itemBuilder: (context, index) {
                                if (index >= diamondList.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(color: accentColor),
                                    ),
                                  );
                                }
                                final stone = diamondList[index];
                                final isSelected = _selectedDiamonds.contains(stone);
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DiamondDetailPage(diamond: stone),
                                      ),
                                    );
                                  },
                                    child: _DiamondCard(
                                      diamond: stone,
                                      onAddToCart: () => _addToCart(stone),
                                      isLoading: _loadingStockIds.contains(stone.stockId),
                                      isGrid: true,
                                      isSelected: isSelected,
                                      isSelectionMode: _selectedDiamonds.isNotEmpty,
                                      onSelect: (val) {
                                        setState(() {
                                          if (val == true) {
                                            _selectedDiamonds.add(stone);
                                          } else {
                                            _selectedDiamonds.remove(stone);
                                          }
                                        });
                                      },
                                      userId: widget.userId,
                                    ),
                                );
                              },
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
                              physics: const BouncingScrollPhysics(),
                              itemCount: diamondList.length + (state is DiamondLoaded && state.hasReachedMax ? 0 : 1),
                              itemBuilder: (context, index) {
                                if (index >= diamondList.length) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(color: accentColor),
                                    ),
                                  );
                                }
                                final stone = diamondList[index];
                                final isSelected = _selectedDiamonds.contains(stone);
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DiamondDetailPage(diamond: stone),
                                      ),
                                    );
                                  },
                                  child: _DiamondCard(
                                    diamond: stone,
                                    onAddToCart: () => _addToCart(stone),
                                    isLoading: _loadingStockIds.contains(stone.stockId),
                                    isGrid: false,
                                    isSelected: isSelected,
                                    isSelectionMode: _selectedDiamonds.isNotEmpty,
                                    onSelect: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedDiamonds.add(stone);
                                        } else {
                                          _selectedDiamonds.remove(stone);
                                        }
                                      });
                                    },
                                    userId: widget.userId,
                                  ),
                                );
                              },
                            ),
                      ),
          ),
        ],
      );
        },
      ),
    );
  }

  TextStyle _filterLabelStyle(BuildContext context) {
    return GoogleFonts.nunito(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).textTheme.bodyMedium?.color,
    );
  }

  // --- NEW MOBILE DRAWER FILTERS ---
  void _openFilterBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.55),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {

            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F0F12) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
                border: Border.all(
                  color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Pull Handle
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Header Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tune_rounded, color: accentColor, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              'Filter Diamonds',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 22),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Divider(height: 1),

                  // Scrollable parameters content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(AppConstants.spaceLG),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // A. Diamond Shape Selector
                          Text('Diamond Shape', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          SizedBox(
                            height: 98, // Increased height to accommodate larger icon + text centering
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemCount: _shapes.length,
                              itemBuilder: (context, index) {
                                final shape = _shapes[index];
                                final isSelected = _selectedShapes.contains(shape);
                                final isOval = shape.toLowerCase() == 'oval';
                                final imgSize = isOval ? 44.0 : 34.0;

                                return GestureDetector(
                                  onTap: () {
                                    setModalState(() {
                                      if (_selectedShapes.contains(shape)) {
                                        _selectedShapes.remove(shape);
                                      } else {
                                        _selectedShapes.add(shape);
                                      }
                                    });
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: AppConstants.spaceMD),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        // Shape Icon Container
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: isSelected 
                                                ? accentColor.withValues(alpha: 0.1) 
                                                : (isDark ? AppConstants.surfaceLightColor : AppConstants.lightSurfaceLightColor),
                                            border: Border.all(
                                              color: isSelected 
                                                  ? accentColor 
                                                  : (isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                                              width: 1.5,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          alignment: Alignment.center,
                                          child: Image.asset(
                                            _getShapeAsset(shape),
                                            width: imgSize,
                                            height: imgSize,
                                            fit: BoxFit.contain,
                                            color: isSelected
                                                ? accentColor
                                                : (isDark ? Colors.white70 : Colors.black54),
                                            errorBuilder: (context, error, stackTrace) {
                                              // Fallback if image doesn't exist
                                              return Icon(
                                                Icons.diamond_outlined,
                                                color: isSelected ? accentColor : (isDark ? Colors.white70 : Colors.black54),
                                                size: 30,
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        // Shape Label
                                        SizedBox(
                                          width: 60,
                                          child: Text(
                                            shape,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.nunito(
                                              fontSize: 10,
                                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                              color: isSelected ? accentColor : (isDark ? Colors.white70 : Colors.black87),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                           // B. Carat Filter (full width)
                           Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text('Carat (Ct.)', style: _filterLabelStyle(context)),
                               const SizedBox(height: 6),
                               Row(
                                 children: [
                                   Expanded(
                                     child: _buildModalInputBox(
                                       controller: _caratFromController,
                                       hint: 'Min ct',
                                       setModalState: setModalState,
                                     ),
                                   ),
                                   const Padding(
                                     padding: EdgeInsets.symmetric(horizontal: 8),
                                     child: Text('to', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                   ),
                                   Expanded(
                                     child: _buildModalInputBox(
                                       controller: _caratToController,
                                       hint: 'Max ct',
                                       setModalState: setModalState,
                                     ),
                                   ),
                                 ],
                               ),
                             ],
                           ),

                           if (widget.userId != 'guest') ...[
                             const SizedBox(height: AppConstants.spaceMD),
                             Builder(
                               builder: (context) {
                                 double minPriceVal = double.tryParse(_priceFromController.text) ?? 0;
                                 double maxPriceVal = double.tryParse(_priceToController.text) ?? 100000;
                                 
                                 // Clamp values inside standard RangeSlider boundary to prevent assertion crashes
                                 double sliderMin = minPriceVal.clamp(0.0, 100000.0);
                                 double sliderMax = maxPriceVal.clamp(0.0, 100000.0);
                                 if (sliderMin > sliderMax) {
                                   sliderMin = sliderMax;
                                 }

                                 return Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Row(
                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                       children: [
                                         Text('Price (\$)', style: _filterLabelStyle(context)),
                                         Text(
                                           '\$${minPriceVal.toStringAsFixed(0)} - \$${maxPriceVal.toStringAsFixed(0)}',
                                           style: GoogleFonts.nunito(
                                             fontWeight: FontWeight.bold,
                                             color: accentColor,
                                             fontSize: 13,
                                           ),
                                         ),
                                       ],
                                     ),
                                     const SizedBox(height: 6),
                                     Row(
                                       children: [
                                         Expanded(
                                           child: _buildModalInputBox(
                                             controller: _priceFromController,
                                             hint: 'Min Price',
                                             setModalState: setModalState,
                                             keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                           ),
                                         ),
                                         const Padding(
                                           padding: EdgeInsets.symmetric(horizontal: 8),
                                           child: Text('to', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                         ),
                                         Expanded(
                                           child: _buildModalInputBox(
                                             controller: _priceToController,
                                             hint: 'Max Price',
                                             setModalState: setModalState,
                                             keyboardType: const TextInputType.numberWithOptions(decimal: false),
                                           ),
                                         ),
                                       ],
                                     ),
                                     const SizedBox(height: 6),
                                     SliderTheme(
                                       data: SliderTheme.of(context).copyWith(
                                         activeTrackColor: accentColor,
                                         inactiveTrackColor: accentColor.withOpacity(0.2),
                                         thumbColor: accentColor,
                                         overlayColor: accentColor.withOpacity(0.12),
                                         valueIndicatorColor: accentColor,
                                         valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                                       ),
                                       child: RangeSlider(
                                         values: RangeValues(sliderMin, sliderMax),
                                         min: 0,
                                         max: 100000,
                                         divisions: 200,
                                         labels: RangeLabels(
                                           '\$${sliderMin.toStringAsFixed(0)}',
                                           '\$${sliderMax.toStringAsFixed(0)}',
                                         ),
                                         onChanged: (RangeValues values) {
                                           setModalState(() {
                                             _priceFromController.text = values.start.toStringAsFixed(0);
                                             _priceToController.text = values.end.toStringAsFixed(0);
                                           });
                                           setState(() {});
                                         },
                                       ),
                                     ),
                                   ],
                                 );
                               }
                             ),
                           ],

                          const SizedBox(height: AppConstants.spaceMD),

                          // C. Color Grade Multi-selector
                          Text('Color Grade', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _colors,
                            selectedItems: _selectedColors,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedColors.contains(item)) {
                                  _selectedColors.remove(item);
                                } else {
                                  _selectedColors.add(item);
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          // C.2 Fancy Color Multi-selector
                          if (_selectedColors.contains('FANCY')) ...[
                            Text('Fancy Color', style: _filterLabelStyle(context)),
                            const SizedBox(height: AppConstants.spaceSM),
                            SizedBox(
                              height: 48,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: _fancyColors.length,
                                itemBuilder: (context, index) {
                                  final color = _fancyColors[index];
                                  final isSelected = _selectedFancyColors.contains(color);
                                  return GestureDetector(
                                    onTap: () {
                                      setModalState(() {
                                        if (_selectedFancyColors.contains(color)) {
                                          _selectedFancyColors.remove(color);
                                        } else {
                                          _selectedFancyColors.add(color);
                                        }
                                      });
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: AppConstants.spaceSM),
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected ? accentColor : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: isSelected ? [
                                            BoxShadow(
                                              color: accentColor.withValues(alpha: 0.3),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ] : null,
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/images/$color.png',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) => Container(
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.error_outline, size: 20),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: AppConstants.spaceMD),
                          ],

                          // D. Clarity Grade Multi-selector
                          Text('Clarity Grade', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _clarities,
                            selectedItems: _selectedClarities,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedClarities.contains(item)) {
                                  _selectedClarities.remove(item);
                                } else {
                                  _selectedClarities.add(item);
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          Text('Make', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _makes,
                            selectedItems: _selectedMakes,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedMakes.contains(item)) {
                                  _selectedMakes.remove(item);
                                  
                                  // Remove on unselect
                                  if (item == '3EX') {
                                    _selectedCuts.remove('EX');
                                    _selectedPolishes.remove('EX');
                                    _selectedSymmetries.remove('EX');
                                  } else if (item == '3VG+') {
                                    _selectedCuts.remove('VG');
                                    _selectedPolishes.remove('VG');
                                    _selectedSymmetries.remove('VG');
                                  } else if (item == '3EX-NONE') {
                                    _selectedCuts.remove('EX');
                                    _selectedPolishes.remove('EX');
                                    _selectedSymmetries.remove('EX');
                                    _selectedFluorescences.remove('None');
                                  }
                                } else {
                                  // Don't do multiple selection for Make
                                  _selectedMakes.clear();
                                  _selectedMakes.add(item);
                                  
                                  if (item == '3EX') {
                                    _selectedCuts.clear(); _selectedCuts.add('EX');
                                    _selectedPolishes.clear(); _selectedPolishes.add('EX');
                                    _selectedSymmetries.clear(); _selectedSymmetries.add('EX');
                                  } else if (item == '3VG+') {
                                    _selectedCuts.clear(); _selectedCuts.add('VG');
                                    _selectedPolishes.clear(); _selectedPolishes.add('VG');
                                    _selectedSymmetries.clear(); _selectedSymmetries.add('VG');
                                  } else if (item == '3EX-NONE') {
                                    _selectedCuts.clear(); _selectedCuts.add('EX');
                                    _selectedPolishes.clear(); _selectedPolishes.add('EX');
                                    _selectedSymmetries.clear(); _selectedSymmetries.add('EX');
                                    _selectedFluorescences.clear(); _selectedFluorescences.add('None');
                                  }
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          // E. Fluorescence Multi-selector
                          Text('Fluorescence', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _fluorescences,
                            selectedItems: _selectedFluorescences,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedFluorescences.contains(item)) {
                                  _selectedFluorescences.remove(item);
                                } else {
                                  _selectedFluorescences.add(item);
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          // F. Quality Filters (Cut, Polish, Symmetry, Lab)
                          Text('Cut Grade', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _cuts,
                            selectedItems: _selectedCuts,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedCuts.contains(item)) {
                                  _selectedCuts.remove(item);
                                } else {
                                  _selectedCuts.add(item);
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          Text('Polish', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _polishes,
                            selectedItems: _selectedPolishes,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedPolishes.contains(item)) {
                                  _selectedPolishes.remove(item);
                                } else {
                                  _selectedPolishes.add(item);
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          Text('Symmetry', style: _filterLabelStyle(context)),
                          const SizedBox(height: AppConstants.spaceSM),
                          _buildModalMultiSelectRow(
                            items: _symmetries,
                            selectedItems: _selectedSymmetries,
                            onTap: (item) {
                              setModalState(() {
                                if (_selectedSymmetries.contains(item)) {
                                  _selectedSymmetries.remove(item);
                                } else {
                                  _selectedSymmetries.add(item);
                                }
                              });
                              setState(() {});
                            },
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          // Text('Available', style: _filterLabelStyle(context)),
                          // const SizedBox(height: AppConstants.spaceSM),
                          // _buildModalMultiSelectRow(
                          //   items: const ['Yes', 'No'],
                          //   selectedItems: _selectedAvailable,
                          //   onTap: (item) {
                          //     setModalState(() {
                          //       if (_selectedAvailable.contains(item)) {
                          //         _selectedAvailable.remove(item);
                          //       } else {
                          //         _selectedAvailable.add(item);
                          //       }
                          //     });
                          //     setState(() {});
                          //   },
                          // ),

                          const SizedBox(height: AppConstants.spaceMD),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('LAB', style: _filterLabelStyle(context)),
                              const SizedBox(height: AppConstants.spaceSM),
                              _buildModalMultiSelectRow(
                                items: _labs,
                                selectedItems: _selectedLabs,
                                onTap: (item) {
                                  setModalState(() {
                                    if (_selectedLabs.contains(item)) {
                                      _selectedLabs.remove(item);
                                    } else {
                                      _selectedLabs.add(item);
                                    }
                                  });
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spaceMD),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('STOCK NO', style: _filterLabelStyle(context)),
                              const SizedBox(height: AppConstants.spaceSM),
                              _buildModalInputBox(
                                controller: _stockNoController,
                                hint: '',
                                keyboardType: TextInputType.text,
                                setModalState: setModalState,
                              ),
                            ],
                          ),

                          const SizedBox(height: AppConstants.spaceMD),

                          // G. Toggle Advanced Search Button
                          InkWell(
                            onTap: () {
                              setModalState(() {
                                _isAdvanceExpanded = !_isAdvanceExpanded;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppConstants.surfaceLightColor
                                    : AppConstants.lightSurfaceLightColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isAdvanceExpanded
                                        ? Icons.remove_circle_outline_rounded
                                        : Icons.add_circle_outline_rounded,
                                    color: accentColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isAdvanceExpanded ? 'HIDE ADVANCE SEARCH' : 'SHOW ADVANCE SEARCH',
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: accentColor,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // H. Advanced Search Section
                          if (_isAdvanceExpanded) ...[
                            const SizedBox(height: AppConstants.spaceMD),
                            const Divider(color: AppConstants.borderLight),
                            const SizedBox(height: AppConstants.spaceSM),

                            // Culet Multi-selector
                            Text('Culet', style: _filterLabelStyle(context)),
                            const SizedBox(height: AppConstants.spaceSM),
                            _buildModalMultiSelectRow(
                              items: _culets,
                              selectedItems: _selectedCulets,
                              onTap: (item) {
                                setModalState(() {
                                  if (_selectedCulets.contains(item)) {
                                    _selectedCulets.remove(item);
                                  } else {
                                    _selectedCulets.add(item);
                                  }
                                });
                                setState(() {});
                              },
                            ),

                            const SizedBox(height: AppConstants.spaceMD),

                            // Depth & Table Inputs
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Depth %', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _depthMinController,
                                              hint: 'Min %',
                                              setModalState: setModalState,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4),
                                            child: Text('to', style: TextStyle(fontSize: 11)),
                                          ),
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _depthMaxController,
                                              hint: 'Max %',
                                              setModalState: setModalState,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Table %', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _tableMinController,
                                              hint: 'Min %',
                                              setModalState: setModalState,
                                            ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 4),
                                            child: Text('to', style: TextStyle(fontSize: 11)),
                                          ),
                                          Expanded(
                                            child: _buildModalInputBox(
                                              controller: _tableMaxController,
                                              hint: 'Max %',
                                              setModalState: setModalState,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.spaceMD),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Ratio', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _ratioFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _ratioToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Girdle %', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _girdleFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _girdleToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.spaceMD),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Cr. Angle', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _crAngleFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _crAngleToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Cr. Height', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _crHeightFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _crHeightToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.spaceMD),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Pav. Angle', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _pavAngleFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _pavAngleToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Pav. Height', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _pavHeightFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _pavHeightToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: AppConstants.spaceMD),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Star Length', style: _filterLabelStyle(context)),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Expanded(child: _buildModalInputBox(controller: _starLengthFromController, hint: 'From', setModalState: setModalState)),
                                          const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('to', style: TextStyle(fontSize: 11))),
                                          Expanded(child: _buildModalInputBox(controller: _starLengthToController, hint: 'To', setModalState: setModalState)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: SizedBox()),
                              ],
                            ),

                          ],
                        ],
                      ),
                    ),
                  ),

                  // Sticky Bottom Drawer Action Row
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(AppConstants.spaceLG),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextButton.icon(
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            label: const Text('Reset'),
                            onPressed: () {
                              setModalState(() {
                                _resetFilters();
                              });
                              setState(() {});
                              _applyFilters();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppConstants.errorColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            onPressed: () {
                              _applyFilters();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Show Results',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalInputBox({
    required TextEditingController controller,
    required String hint,
    required StateSetter setModalState,
    TextInputType keyboardType = const TextInputType.numberWithOptions(decimal: true),
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.nunito(fontSize: 11, color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          filled: false,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onChanged: (_) {
          setModalState(() {});
          setState(() {});
        },
      ),
    );
  }

  Widget _buildModalMultiSelectRow({
    required List<String> items,
    required List<String> selectedItems,
    required ValueChanged<String> onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;
    
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = selectedItems.contains(item);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(item),
              selected: isSelected,
              onSelected: (val) {
                onTap(item);
              },
              selectedColor: accentColor.withOpacity(0.15),
              backgroundColor: Colors.transparent,
              labelStyle: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? accentColor : Theme.of(context).textTheme.bodyMedium?.color,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(
                  color: isSelected ? accentColor : (isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedShapes.clear();
      _selectedColors.clear();
      _selectedFancyColors.clear();
      _selectedClarities.clear();
      _selectedCuts.clear();
      _selectedPolishes.clear();
      _selectedSymmetries.clear();
      _selectedLabs.clear();
      _selectedFluorescences.clear();
      _selectedMakes.clear();
      _selectedCulets.clear();
      _caratFromController.text = '0.10';
      _caratToController.text = '10.00';
      _priceFromController.text = '0';
      _priceToController.text = '100000';
      _depthMinController.clear();
      _depthMaxController.clear();
      _tableMinController.clear();
      _tableMaxController.clear();
      _stockNoController.clear();
      _ratioFromController.clear();
      _ratioToController.clear();
      _crAngleFromController.clear();
      _crAngleToController.clear();
      _crHeightFromController.clear();
      _crHeightToController.clear();
      _pavAngleFromController.clear();
      _pavAngleToController.clear();
      _pavHeightFromController.clear();
      _pavHeightToController.clear();
      _girdleFromController.clear();
      _girdleToController.clear();
      _starLengthFromController.clear();
      _starLengthToController.clear();
    });
    _applyFilters();
  }

  Widget _buildActionBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppConstants.borderLight : const Color(0xFFE2EBE5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionBarButton(
            icon: Icons.refresh_rounded,
            label: 'Clear Selection',
            onTap: () {
              setState(() {
                _selectedDiamonds.clear();
              });
            },
            color: accentColor,
          ),
          _buildActionBarButton(
            icon: Icons.favorite_rounded,
            label: 'Add to Wishlist',
            onTap: () {
              if (widget.userId == 'guest') {
                DialogUtils.showLoginRequiredDialog(context);
                return;
              }
              if (_selectedDiamonds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select diamonds first')),
                );
                return;
              }
              for (var d in _selectedDiamonds) {
                context.read<WishlistCubit>().addToWishlist(d.stockId ?? '');
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selected diamonds added to Wishlist')),
              );
            },
            color: accentColor,
          ),
          _buildActionBarButton(
            icon: Icons.shopping_cart_rounded,
            label: 'Add to Cart',
            onTap: () {
              if (widget.userId == 'guest') {
                DialogUtils.showLoginRequiredDialog(context);
                return;
              }
              if (_selectedDiamonds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select diamonds first')),
                );
                return;
              }
              for (var d in _selectedDiamonds) {
                _addToCart(d);
              }
              setState(() {
                _selectedDiamonds.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selected diamonds added to Cart')),
              );
            },
            color: accentColor,
          ),
          _buildActionBarButton(
            icon: Icons.compare_arrows_rounded,
            label: 'Compare',
            onTap: () {
              if (_selectedDiamonds.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select diamonds to compare')),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ComparePage(diamonds: _selectedDiamonds.toList()),
                ),
              );
            },
            color: accentColor,
          ),
          _buildActionBarButton(
            icon: Icons.more_horiz_rounded,
            label: 'More',
            onTap: () {
              _showMoreOptions(context);
            },
            color: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildActionBarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).brightness == Brightness.dark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share_rounded),
                title: Text('Share Selected (WhatsApp)', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  if (_selectedDiamonds.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select diamonds to share')),
                    );
                    return;
                  }
                  showDialog(
                    context: context,
                    builder: (context) => DiamondShareDialog(diamonds: _selectedDiamonds.toList()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.tune_rounded),
                title: Text('Filters', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _openFilterBottomSheet(context);
                },
              ),
              ListTile(
                leading: Icon(_isGridView ? Icons.list_rounded : Icons.grid_view_rounded),
                title: Text(_isGridView ? 'Switch to List View' : 'Switch to Grid View', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.filter_alt_off_rounded),
                title: Text('Reset All Filters', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  _clearFilters();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppConstants.surfaceColor : Colors.white,
          title: Text(
            'Search Stock No.',
            style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: TextField(
            controller: _stockNoController,
            autofocus: true,
            style: GoogleFonts.nunito(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Enter stock number...',
              hintStyle: GoogleFonts.nunito(fontSize: 13),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear, size: 16),
                onPressed: () => _stockNoController.clear(),
              ),
            ),
            onSubmitted: (val) {
              Navigator.pop(context);
              _applyFilters();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel', style: TextStyle(color: isDark ? Colors.white60 : Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _applyFilters();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.accentColor),
              child: const Text('Search', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class _DiamondCard extends StatefulWidget {
  final DiamondModel diamond;
  final VoidCallback onAddToCart;
  final bool isGrid;
  final bool isSelected;
  final bool isSelectionMode;
  final ValueChanged<bool?>? onSelect;
  final String userId;
  final bool isLoading;

  const _DiamondCard({
    required this.diamond,
    required this.onAddToCart,
    this.isGrid = false,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onSelect,
    required this.userId,
    this.isLoading = false,
  });

  @override
  State<_DiamondCard> createState() => _DiamondCardState();
}

class _DiamondCardState extends State<_DiamondCard> {
  bool _isWishlisted = false;
  bool _isWishlistLoading = false;
  Widget _buildSpecText(String text, bool isDark) {
    if (text.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(right: 18.0),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  String _formatPrice(String? val) {
    if (val == null || val.isEmpty || val == '0') return '0';
    final double d = double.tryParse(val) ?? 0.0;
    if (d == 0.0) return '0';
    final bool hasFraction = (d - d.truncateToDouble()) != 0.0;
    final String str = d.toStringAsFixed(hasFraction ? 2 : 0);
    final parts = str.split('.');
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String formattedInt = parts[0].replaceAllMapped(reg, (Match m) => '${m[1]},');
    if (parts.length > 1) {
      return '$formattedInt.${parts[1]}';
    }
    return formattedInt;
  }

  @override
  Widget build(BuildContext context) {
    final diamond = widget.diamond;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;

    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, wishlistState) {
        bool isWishlisted = false;
        String? wishlistId;
        if (wishlistState is WishlistLoaded) {
          try {
            final item = wishlistState.items.firstWhere((i) => i.stockId == diamond.stockId);
            isWishlisted = true;
            wishlistId = item.wishlistId;
          } catch (_) {}
        }

        if (widget.isGrid) {
          return Container(
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? (isDark
                      ? accentColor.withValues(alpha: 0.2)
                      : accentColor.withValues(alpha: 0.12))
                  : (isDark ? AppConstants.surfaceLightColor : Colors.white),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: widget.isSelected
                    ? accentColor
                    : (isDark ? AppConstants.borderLight : const Color(0xFFE2EBE5)),
                width: widget.isSelected ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.all(AppConstants.spaceSM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${diamond.stockId ?? ""}',
                        style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DiamondDetailPage(diamond: diamond),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                        child: Icon(
                          Icons.visibility_rounded,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (widget.userId == 'guest') {
                          DialogUtils.showLoginRequiredDialog(context);
                          return;
                        }
                        if (_isWishlistLoading) return;
                        setState(() {
                          _isWishlistLoading = true;
                        });

                        if (isWishlisted && wishlistId != null) {
                          context.read<WishlistCubit>().removeWishlist(wishlistId);
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) {
                              setState(() {
                                _isWishlistLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Removed from Wishlist!'),
                                  duration: Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          });
                        } else {
                          context.read<WishlistCubit>().addToWishlist(diamond.stockId ?? '');
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) {
                              setState(() {
                                _isWishlistLoading = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Added to Wishlist!'),
                                  duration: Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _isWishlistLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 1.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppConstants.errorColor),
                                ),
                              )
                            : Icon(
                                isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isWishlisted ? AppConstants.errorColor : (isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary),
                                size: 20,
                              ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (widget.onSelect != null) {
                          widget.onSelect!(!widget.isSelected);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          widget.isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                          color: widget.isSelected ? accentColor : (isDark ? Colors.white30 : Colors.black26),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (diamond.diamondImage != null && diamond.diamondImage!.isNotEmpty) {
                        DialogUtils.showEnlargedImage(context, diamond.diamondImage!, diamond.shape ?? 'Round');
                      }
                    },
                    child: Center(
                      child: diamond.diamondImage != null && diamond.diamondImage!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: diamond.diamondImage!,
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) => Image.asset(
                              AppConstants.getShapeAsset(diamond.shape ?? 'Round'),
                              color: isDark ? Colors.white24 : Colors.black12,
                            ),
                          )
                        : Image.asset(
                            AppConstants.getShapeAsset(diamond.shape ?? 'Round'),
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(double.tryParse(diamond.weight ?? "0") ?? 0.0).toStringAsFixed(2)} Ct ${diamond.shape ?? ""}',
                  style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${diamond.color ?? ""}, ${diamond.grade ?? ""}',
                  style: GoogleFonts.nunito(fontSize: 10, color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                widget.userId == 'guest'
                     ? Text(
                         'Login for price',
                         style: GoogleFonts.nunito(
                           fontSize: 11,
                           fontWeight: FontWeight.bold,
                           color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                         ),
                         textAlign: TextAlign.center,
                       )
                     : Text(
                         '\$${_formatPrice(diamond.totalPrice)}',
                         style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w900, color: AppConstants.successColor),
                         textAlign: TextAlign.center,
                       ),
              ],
            ),
          );
        }

        String badgeChar = 'A';
        if (diamond.availability != null) {
          final lowerAv = diamond.availability!.toLowerCase();
          if (lowerAv.contains('memo')) {
            badgeChar = 'M';
          } else if (lowerAv.contains('hold')) {
            badgeChar = 'H';
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: AppConstants.spaceMD),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? (isDark
                    ? accentColor.withValues(alpha: 0.2)
                    : accentColor.withValues(alpha: 0.12))
                : (isDark ? AppConstants.surfaceLightColor : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? accentColor
                  : (isDark ? AppConstants.borderLight : const Color(0xFFE2EBE5)),
              width: widget.isSelected ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Image container
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (diamond.diamondImage != null && diamond.diamondImage!.isNotEmpty) {
                        DialogUtils.showEnlargedImage(context, diamond.diamondImage!, diamond.shape ?? 'Round');
                      }
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: isDark ? AppConstants.surfaceColor : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: (diamond.diamondImage != null && diamond.diamondImage!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: diamond.diamondImage!,
                                width: 90,
                                height: 90,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(child: CircularProgressIndicator(color: accentColor, strokeWidth: 2)),
                                errorWidget: (context, url, error) => Image.asset(
                                  AppConstants.getShapeAsset(diamond.shape ?? 'Round'),
                                  color: isDark ? Colors.white38 : Colors.black26,
                                  width: 44,
                                  height: 44,
                                ),
                              )
                            : Image.asset(
                                AppConstants.getShapeAsset(diamond.shape ?? 'Round'),
                                color: isDark ? Colors.white38 : Colors.black26,
                                width: 44,
                                height: 44,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Middle: Info Column
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diamond.stockId ?? '',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${diamond.lab ?? ''} : ${diamond.reportNo ?? ''}',
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          (diamond.shape ?? '').toUpperCase(),
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      ],
                    ),
                  ),

                  // Right: Price Column & Chevron
                  Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 28.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                                    ),
                                    children: [
                                      const TextSpan(text: '\$/CTS: '),
                                      TextSpan(
                                        text: widget.userId == 'guest'
                                            ? '?'
                                            : _formatPrice(diamond.costCarat),
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold,
                                          color: accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                                    ),
                                    children: [
                                      const TextSpan(text: 'Total \$: '),
                                      TextSpan(
                                        text: widget.userId == 'guest'
                                            ? '?'
                                            : _formatPrice(diamond.totalPrice),
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold,
                                          color: accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                RichText(
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  text: TextSpan(
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                                    ),
                                    children: [
                                      const TextSpan(text: 'TOTC: '),
                                      TextSpan(
                                        text: widget.userId == 'guest'
                                            ? '?'
                                            : _formatPrice(diamond.totalPrice),
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold,
                                          color: accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              const Divider(height: 1, thickness: 0.5, color: Colors.black12),
              const SizedBox(height: 8),

              // Middle: Badge and specs (2.54   BLUE   VS2   EX   EX)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      badgeChar,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildSpecText(diamond.weight ?? '', isDark),
                          _buildSpecText(diamond.color ?? '', isDark),
                          _buildSpecText(diamond.grade ?? '', isDark),
                          if (diamond.cut != null && diamond.cut!.isNotEmpty && diamond.cut != 'N/A')
                            _buildSpecText(diamond.cut!, isDark),
                          _buildSpecText(diamond.polish ?? '', isDark),
                          _buildSpecText(diamond.symmetry ?? '', isDark),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Status Text
              Builder(
                builder: (context) {
                  final displayAvailability = (diamond.memotootltip != null && diamond.memotootltip!.isNotEmpty)
                      ? diamond.memotootltip!
                      : (diamond.availability ?? '');
                  if (displayAvailability.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      displayAvailability,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  );
                }
              ),

              const SizedBox(height: 6),
              const Divider(height: 1, thickness: 0.5, color: Colors.black12),
              const SizedBox(height: 6),

              // Bottom Row: T%, D%, measurements, ratio
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'T%: ${diamond.tableD ?? "-"}, D%: ${diamond.depth ?? "-"}, ( ${diamond.measurements ?? "-"} ), Ratio: ${diamond.ratio ?? "-"}',
                      style: GoogleFonts.nunito(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white38 : Colors.black45,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (widget.userId == 'guest') {
                        DialogUtils.showLoginRequiredDialog(context);
                        return;
                      }
                      if (_isWishlistLoading) return;
                      setState(() {
                        _isWishlistLoading = true;
                      });
                      if (isWishlisted && wishlistId != null) {
                        context.read<WishlistCubit>().removeWishlist(wishlistId);
                      } else {
                        context.read<WishlistCubit>().addToWishlist(diamond.stockId ?? '');
                      }
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted) {
                          setState(() {
                            _isWishlistLoading = false;
                          });
                        }
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
                      child: _isWishlistLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 1.5),
                            )
                          : Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              color: isWishlisted ? AppConstants.errorColor : (isDark ? Colors.white38 : Colors.black38),
                              size: 20,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
                top: -4,
                right: -4,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (widget.onSelect != null) {
                      widget.onSelect!(!widget.isSelected);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      widget.isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      color: widget.isSelected ? accentColor : (isDark ? Colors.white30 : Colors.black26),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpecItemCol(String label, String value, bool isDark, Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          value.isNotEmpty ? value : '-',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor.withOpacity(0.9),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
