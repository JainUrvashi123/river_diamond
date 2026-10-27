import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/dialog_utils.dart';
import '../../data/models/diamond_model.dart';

class ComparePage extends StatelessWidget {
  final List<DiamondModel> diamonds;

  const ComparePage({Key? key, required this.diamonds}) : super(key: key);

  static const double labelColumnWidth = 100.0;
  static const double valueColumnWidth = 135.0;
  static const double rowHeight = 44.0;
  static const double imageHeight = 110.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor;
    final surfaceColor = isDark ? AppConstants.surfaceColor : AppConstants.lightSurfaceColor;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final borderColor = isDark ? Colors.white10 : Colors.black12;
    final headerTextColor = isDark ? Colors.blue[300]! : const Color(0xFF0F3A5F);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Compare Diamond',
          style: GoogleFonts.nunito(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              surfaceColor,
            ],
          ),
        ),
        child: diamonds.isEmpty
            ? Center(
                child: Text(
                  'No diamonds selected to compare',
                  style: GoogleFonts.nunito(color: textColor, fontSize: 16),
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(AppConstants.spaceMD),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppConstants.surfaceLightColor.withOpacity(0.5) : AppConstants.lightSurfaceLightColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left Labels Column (Fixed)
                                _buildLabelsColumn(isDark, borderColor, headerTextColor),
                                // Right Scrollable Columns (Scrollable horizontally)
                                Expanded(
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    physics: const BouncingScrollPhysics(),
                                    child: Row(
                                      children: diamonds.map((diamond) {
                                        return _buildValuesColumn(context, diamond, isDark, borderColor, headerTextColor);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildLabelsColumn(bool isDark, Color borderColor, Color labelColor) {
    final TextStyle labelStyle = GoogleFonts.nunito(
      fontWeight: FontWeight.bold,
      fontSize: 12.5,
      color: labelColor,
    );

    return Container(
      width: labelColumnWidth,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCell('Packet No', labelStyle, isDark, borderColor),
          _buildCell('Image', labelStyle, isDark, borderColor, height: imageHeight),
          _buildCell('Report No', labelStyle, isDark, borderColor),
          _buildCell('Shape', labelStyle, isDark, borderColor),
          _buildCell('Carat', labelStyle, isDark, borderColor),
          _buildCell('Color', labelStyle, isDark, borderColor),
          _buildCell('Clarity', labelStyle, isDark, borderColor),
          _buildCell('Cut', labelStyle, isDark, borderColor),
          _buildCell('Polish', labelStyle, isDark, borderColor),
          _buildCell('Sym', labelStyle, isDark, borderColor),
          _buildCell('Fluor', labelStyle, isDark, borderColor),
          _buildCell('Disc %', labelStyle, isDark, borderColor),
          _buildCell('Rap \$', labelStyle, isDark, borderColor),
          _buildCell('\$/Cts', labelStyle, isDark, borderColor),
          _buildCell('Total \$', labelStyle, isDark, borderColor),
          _buildCell('Meas', labelStyle, isDark, borderColor, isLast: true),
        ],
      ),
    );
  }

  Widget _buildValuesColumn(BuildContext context, DiamondModel diamond, bool isDark, Color borderColor, Color headerColor) {
    final TextStyle textStyle = GoogleFonts.nunito(
      fontWeight: FontWeight.w600,
      fontSize: 13,
      color: isDark ? Colors.white70 : Colors.black87,
    );

    final TextStyle headerStyle = GoogleFonts.nunito(
      fontWeight: FontWeight.bold,
      fontSize: 13.5,
      color: headerColor,
    );

    return Container(
      width: valueColumnWidth,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: borderColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Packet No
          _buildCell(diamond.stockId ?? '-', headerStyle, isDark, borderColor, align: TextAlign.center),
          // Image
          _buildImageCell(context, diamond, isDark, borderColor),
          // Report No
          _buildCell(diamond.reportNo ?? '-', textStyle, isDark, borderColor, align: TextAlign.center),
          // Shape
          _buildCell((diamond.shape ?? '-').toUpperCase(), textStyle, isDark, borderColor, align: TextAlign.center),
          // Carat
          _buildCell(diamond.weight ?? '-', textStyle, isDark, borderColor, align: TextAlign.center),
          // Color
          _buildCell(diamond.color ?? '-', textStyle, isDark, borderColor, align: TextAlign.center),
          // Clarity (Grade)
          _buildCell(diamond.grade ?? '-', textStyle, isDark, borderColor, align: TextAlign.center),
          // Cut
          _buildCell(diamond.cut ?? '-', textStyle, isDark, borderColor, align: TextAlign.center),
          // Polish
          _buildCell(diamond.polish ?? '-', textStyle, isDark, borderColor, align: TextAlign.center),
          // Sym
          _buildCell(diamond.symmetry ?? '-', textStyle, isDark, borderColor, align: TextAlign.center),
          // Fluor
          _buildCell(diamond.fluorescenceInt ?? '-', textStyle, isDark, borderColor, align: TextAlign.center),
          // Disc %
          _buildCell(diamond.newDiscount != null && diamond.newDiscount!.isNotEmpty ? '${diamond.newDiscount}%' : '-', textStyle, isDark, borderColor, align: TextAlign.center),
          // Rap $
          _buildCell(diamond.rapnet != null && diamond.rapnet != '0' && diamond.rapnet!.isNotEmpty ? '\$${double.tryParse(diamond.rapnet!)?.toStringAsFixed(0)}' : '-', textStyle, isDark, borderColor, align: TextAlign.center),
          // $/Cts
          _buildCell(diamond.costCarat != null && diamond.costCarat != '0' && diamond.costCarat!.isNotEmpty ? '\$${double.tryParse(diamond.costCarat!)?.toStringAsFixed(0)}' : '-', textStyle, isDark, borderColor, align: TextAlign.center),
          // Total $
          _buildCell(diamond.totalPrice != null && diamond.totalPrice != '0' && diamond.totalPrice!.isNotEmpty ? '\$${double.tryParse(diamond.totalPrice!)?.toStringAsFixed(0)}' : '-', textStyle, isDark, borderColor, align: TextAlign.center),
          // Meas
          _buildCell(diamond.measurements ?? '-', textStyle, isDark, borderColor, align: TextAlign.center, isLast: true, scrollable: true),
        ],
      ),
    );
  }

  Widget _buildCell(String text, TextStyle style, bool isDark, Color borderColor, {double height = rowHeight, TextAlign align = TextAlign.left, bool isLast = false, bool scrollable = false}) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      alignment: align == TextAlign.left ? Alignment.centerLeft : Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast ? BorderSide.none : BorderSide(color: borderColor),
        ),
      ),
      child: scrollable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Text(
                text,
                style: style,
                textAlign: align,
                maxLines: 1,
              ),
            )
          : Text(
              text,
              style: style,
              textAlign: align,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }

  Widget _buildImageCell(BuildContext context, DiamondModel diamond, bool isDark, Color borderColor) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return Container(
      height: imageHeight,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          if (diamond.diamondImage != null && diamond.diamondImage!.isNotEmpty) {
            DialogUtils.showEnlargedImage(context, diamond.diamondImage!, diamond.shape ?? 'Round');
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: (diamond.diamondImage != null && diamond.diamondImage!.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: diamond.diamondImage!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                    placeholder: (context, url) => Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: accentColor, strokeWidth: 2))),
                    errorWidget: (context, url, error) => Center(
                      child: Image.asset(
                        AppConstants.getShapeAsset(diamond.shape ?? 'Round'),
                        color: isDark ? Colors.white24 : Colors.black12,
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                    ),
                  )
                : Center(
                    child: Image.asset(
                      AppConstants.getShapeAsset(diamond.shape ?? 'Round'),
                      color: isDark ? Colors.white24 : Colors.black12,
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
