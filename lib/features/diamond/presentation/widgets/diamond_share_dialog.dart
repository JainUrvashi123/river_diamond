import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/utils/constants.dart';
import '../../data/models/diamond_model.dart';

class DiamondShareDialog extends StatefulWidget {
  final List<DiamondModel> diamonds;

  const DiamondShareDialog({Key? key, required this.diamonds}) : super(key: key);

  @override
  State<DiamondShareDialog> createState() => _DiamondShareDialogState();
}

class _DiamondShareDialogState extends State<DiamondShareDialog> {
  bool _shareImage = false;
  bool _shareVideo = false;
  bool _shareCert = false;

  bool _withPrice = true;
  bool _isGuest = false;

  final TextEditingController _rapMarkupController = TextEditingController();
  final TextEditingController _moneyMarkupController = TextEditingController();
  final TextEditingController _dollarMarkupController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkGuestStatus();
    _checkMediaAvailability();
  }

  void _checkMediaAvailability() {
    final hasImage = widget.diamonds.any((d) => d.diamondImage != null && d.diamondImage!.isNotEmpty);
    final hasVideo = widget.diamonds.any((d) => d.diamondVideo != null && d.diamondVideo!.isNotEmpty);
    final hasCert = widget.diamonds.any((d) => d.reportFilename != null && d.reportFilename!.isNotEmpty);
    setState(() {
      _shareImage = hasImage;
      _shareVideo = hasVideo;
      _shareCert = hasCert;
    });
  }

  Future<void> _checkGuestStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    if (userId == 'guest') {
      setState(() {
        _isGuest = true;
        _withPrice = false;
      });
    }
  }

  @override
  void dispose() {
    _rapMarkupController.dispose();
    _moneyMarkupController.dispose();
    _dollarMarkupController.dispose();
    super.dispose();
  }

  String _formatNumber(String? val, {int decimals = 0}) {
    if (val == null || val.isEmpty || val == '0') return '0';
    final double d = double.tryParse(val) ?? 0.0;
    if (d == 0.0) return '0';
    final String str = d.toStringAsFixed(decimals);
    final parts = str.split('.');
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String formattedInt = parts[0].replaceAllMapped(reg, (Match m) => '${m[1]},');
    if (parts.length > 1) {
      return '$formattedInt.${parts[1]}';
    }
    return formattedInt;
  }

  void _share() async {
    final buffer = StringBuffer();
    
    final bool withPrice = _isGuest ? false : _withPrice;
    
    double rapMarkup = double.tryParse(_rapMarkupController.text) ?? 0.0;
    double moneyMarkup = double.tryParse(_moneyMarkupController.text) ?? 0.0;
    double dollarMarkup = double.tryParse(_dollarMarkupController.text) ?? 0.0;

    for (var diamond in widget.diamonds) {
      buffer.writeln('Stock# - ${diamond.stockId ?? ""}');
      
      if (_shareImage && diamond.diamondImage != null && diamond.diamondImage!.isNotEmpty) {
        buffer.writeln('Image - ${diamond.diamondImage}');
      }
      if (_shareVideo && diamond.diamondVideo != null && diamond.diamondVideo!.isNotEmpty) {
        buffer.writeln('Video - ${diamond.diamondVideo}');
      }
      if (_shareCert && diamond.reportFilename != null && diamond.reportFilename!.isNotEmpty) {
        buffer.writeln('Cert - ${diamond.reportFilename}');
      }

      buffer.writeln('Shape - ${diamond.shape ?? ""}');
      
      final double weightVal = double.tryParse(diamond.weight ?? "0") ?? 0.0;
      buffer.writeln('Weight - ${weightVal.toStringAsFixed(2)} Ct');
      
      buffer.writeln('Color - ${diamond.color ?? ""}');
      buffer.writeln('Grade - ${diamond.grade ?? ""}');
      buffer.writeln('Cut - ${diamond.cut ?? ""}');
      buffer.writeln('Polish - ${diamond.polish ?? ""}');
      buffer.writeln('Symmetry - ${diamond.symmetry ?? ""}');
      buffer.writeln('Fluor - ${diamond.fluorescenceInt ?? ""}');
      buffer.writeln('Ratio - ${diamond.ratio ?? ""}');

      if (withPrice) {
        double discount = double.tryParse(diamond.newDiscount ?? "0") ?? 0.0;
        double costCarat = double.tryParse(diamond.costCarat ?? "0") ?? 0.0;
        double totalPrice = double.tryParse(diamond.totalPrice ?? "0") ?? 0.0;
        double rapnet = double.tryParse(diamond.rapnet ?? "0") ?? 0.0;

        // Fallback for rapnet if it is 0 but we can derive it
        if (rapnet == 0 && costCarat > 0 && discount != 0) {
          rapnet = costCarat / ((100 + discount) / 100);
        }
        if (rapnet == 0) {
          rapnet = costCarat;
        }

        // Apply markups
        if (rapMarkup != 0) {
           discount += rapMarkup;
           double originalMultiplier = (100 + discount - rapMarkup) / 100;
           if (originalMultiplier != 0) {
             double baseTotal = totalPrice / originalMultiplier;
             double newMultiplier = (100 + discount) / 100;
             totalPrice = baseTotal * newMultiplier;
             double weight = double.tryParse(diamond.weight ?? "0") ?? 0.0;
             if (weight > 0) costCarat = totalPrice / weight;
           }
        }

        if (moneyMarkup != 0) {
          totalPrice = totalPrice * (1 + (moneyMarkup / 100));
          double weight = double.tryParse(diamond.weight ?? "0") ?? 0.0;
          if (weight > 0) costCarat = totalPrice / weight;
        }

        if (dollarMarkup != 0) {
          totalPrice += dollarMarkup;
          double weight = double.tryParse(diamond.weight ?? "0") ?? 0.0;
          if (weight > 0) costCarat = totalPrice / weight;
        }

        // Recalculate discount based on final costCarat and rapnet
        if ((moneyMarkup != 0 || dollarMarkup != 0) && rapnet > 0) {
          discount = ((costCarat / rapnet) - 1) * 100;
        }

        String formattedDiscount = "";
        if (discount != 0) {
          String sign = discount > 0 ? '+' : '';
          formattedDiscount = "$sign${discount.toStringAsFixed(0)}% off";
        } else {
          formattedDiscount = "0% off";
        }

        buffer.writeln('Rapnet - ${_formatNumber(rapnet.toString(), decimals: 2)}');
        buffer.writeln('Discount - $formattedDiscount');
        buffer.writeln('P/Ct \$ - ${_formatNumber(costCarat.toString(), decimals: 0)}');
        buffer.writeln('Total \$ - ${_formatNumber(totalPrice.toString(), decimals: 0)}');
      }

      buffer.writeln('Measurements - ${diamond.measurements ?? ""}');
      
      final String depthStr = (diamond.depth != null && diamond.depth!.isNotEmpty) 
          ? (double.tryParse(diamond.depth!)?.toStringAsFixed(2) ?? "") 
          : "";
      buffer.writeln('Depth% - $depthStr');
      
      final String tableStr = (diamond.tableD != null && diamond.tableD!.isNotEmpty) 
          ? (double.tryParse(diamond.tableD!)?.toStringAsFixed(2) ?? "") 
          : "";
      buffer.writeln('Table% - $tableStr');
      
      buffer.writeln('Lab - ${diamond.lab ?? ""}');
      
      buffer.writeln(''); // Empty line between diamonds
    }

    final text = buffer.toString().trim();
    final url = Uri.parse('whatsapp://send?text=${Uri.encodeComponent(text)}');
    final fallbackUrl = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      try {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open WhatsApp')),
          );
        }
      }
    }
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isDark ? Colors.blue[300] : const Color(0xFF0D47A1),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? AppConstants.accentColorDark : AppConstants.accentColor;
    final hasImage = widget.diamonds.any((d) => d.diamondImage != null && d.diamondImage!.isNotEmpty);
    final hasVideo = widget.diamonds.any((d) => d.diamondVideo != null && d.diamondVideo!.isNotEmpty);
    final hasCert = widget.diamonds.any((d) => d.reportFilename != null && d.reportFilename!.isNotEmpty);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasImage || hasVideo || hasCert) ...[
                _buildSectionTitle('MEDIA', isDark),
                const Divider(),
                if (hasImage)
                  CheckboxListTile(
                    title: const Text('Image'),
                    value: _shareImage,
                    onChanged: (v) => setState(() => _shareImage = v ?? true),
                    activeColor: accentColor,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                if (hasVideo)
                  CheckboxListTile(
                    title: const Text('Video'),
                    value: _shareVideo,
                    onChanged: (v) => setState(() => _shareVideo = v ?? true),
                    activeColor: accentColor,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                if (hasCert)
                  CheckboxListTile(
                    title: const Text('Certificate'),
                    value: _shareCert,
                    onChanged: (v) => setState(() => _shareCert = v ?? true),
                    activeColor: accentColor,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                const SizedBox(height: 10),
              ],
              
              if (!_isGuest) ...[
                _buildSectionTitle('DETAILS', isDark),
                const Divider(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _withPrice = true),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _withPrice ? null : Colors.transparent,
                          side: BorderSide(color: _withPrice ? accentColor : Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_withPrice) Icon(Icons.check, size: 16, color: accentColor),
                              if (_withPrice) const SizedBox(width: 4),
                              Text('With Price', style: TextStyle(color: _withPrice ? accentColor : Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _withPrice = false),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: !_withPrice ? null : Colors.transparent,
                          side: BorderSide(color: !_withPrice ? accentColor : Colors.grey.shade300),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_withPrice) Icon(Icons.check, size: 16, color: accentColor),
                              if (!_withPrice) const SizedBox(width: 4),
                              Text('Without Price', style: TextStyle(color: !_withPrice ? accentColor : Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                _buildSectionTitle('MARKUP', isDark),
                const Divider(),
                const SizedBox(height: 10),
                
                Text('Natural Markup Rap %', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                TextField(
                  controller: _rapMarkupController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(
                    hintText: 'markup rap %',
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                
                Text('Natural Markup % (Money Wise)', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                TextField(
                  controller: _moneyMarkupController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(
                    hintText: '% money wise',
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(height: 12),
                
                Text('Natural Markup \$ (Dollar Wise)', style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                TextField(
                  controller: _dollarMarkupController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: InputDecoration(
                    hintText: '\$ dollar wise',
                    filled: true,
                    fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
              
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        side: BorderSide(color: accentColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Cancel', style: TextStyle(color: accentColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _share,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text('Share', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
