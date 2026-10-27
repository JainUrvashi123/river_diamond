import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/countries_data.dart';
import 'package:river_diamond/core/bloc/theme_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_button.dart';
import 'terms_and_conditions_page.dart';
import 'package:flutter/gestures.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipcodeController = TextEditingController();

  String _selectedCountry = 'United States';
  String _selectedCountryCode = '+1'; // Fully working interactive country code value
  String _selectedCountryCodeISO = 'US';
  bool _termsAccepted = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _zipcodeController.dispose();
    super.dispose();
  }

  void _onSignUpPressed() {
    if (_formKey.currentState!.validate()) {
      if (!_termsAccepted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please accept the terms and conditions.',
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppConstants.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }

      final fullName = _fullNameController.text.trim();
      final parts = fullName.split(' ');
      final firstName = parts.isNotEmpty ? parts.first : '';
      final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      // Prepare unified phone number including country code
      final rawCode = _selectedCountryCode.replaceAll('-', '');
      final fullPhoneNumber = '$rawCode${_phoneController.text.trim()}';

      context.read<AuthBloc>().add(
            AuthSignUpRequested(
              firstName: firstName,
              lastName: lastName,
              email: _emailController.text.trim(),
              password: _passwordController.text,
              company: _companyController.text.trim(),
              address: _addressController.text.trim(),
              unit: 'A-101', // Standard fallback unit for API
              city: _cityController.text.trim(),
              countries: _selectedCountry,
              state: _stateController.text.trim(),
                            zipcode: _zipcodeController.text.trim(),
              phone: fullPhoneNumber,
              website: AppConstants.websiteUrl, // Standard fallback website
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final scaffoldBgColor = Theme.of(context).scaffoldBackgroundColor;

    final brandPrimaryColor = isDark 
        ? Colors.white 
        : Theme.of(context).primaryColor;

    int? phoneMaxLength;
    if (_selectedCountryCode == '+91' || _selectedCountryCode == '+1') {
      phoneMaxLength = 10;
    } else if (_selectedCountryCode == '+61') {
      phoneMaxLength = 10;
    } else if (_selectedCountryCode == '+44') {
      phoneMaxLength = 11;
    } else {
      phoneMaxLength = 15;
    }

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 64,
        leadingWidth: 72,
        leading: Padding(
          padding: const EdgeInsets.only(left: AppConstants.spaceMD, top: 8),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : const Color(0xFF398860),
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? AppConstants.surfaceColor
                  : Colors.white,
              side: BorderSide(
                color: isDark
                    ? AppConstants.borderLight
                    : AppConstants.lightBorderLight,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppConstants.spaceMD, top: 8),
            child: IconButton(
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? Colors.white : const Color(0xFF398860),
                size: 20,
              ),
              onPressed: () {
                context.read<ThemeBloc>().add(const ThemeToggleRequested());
              },
              style: IconButton.styleFrom(
                backgroundColor: isDark
                    ? AppConstants.surfaceColor
                    : Colors.white,
                side: BorderSide(
                  color: isDark ? AppConstants.borderLight : AppConstants.lightBorderLight,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Account successfully created for ${state.user.name}! Please login.',
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                ),
                backgroundColor: AppConstants.successColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
            // Return back to the login page
            Navigator.of(context).pop();
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage,
                  style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
                ),
                backgroundColor: AppConstants.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Core Sign Up Panel
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),

                        // App Logo Header matching screenshot (extra large and clear with zero vertical gap)
                        Center(
                          child: SizedBox(
                            height: 80, // Tight layout height to pull text closer
                            width: 320,
                            child: OverflowBox(
                              minHeight: 180,
                              maxHeight: 180, // Draws the logo extra large
                              minWidth: 320,
                              maxWidth: 320,
                              child: Image.asset(
                                'assets/images/river_diamond-logo.png',
                                fit: BoxFit.contain,
                                color: isDark ? Colors.white : null,
                                colorBlendMode: isDark ? BlendMode.srcIn : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 0),
                        Text(
                          'CREATE ACCOUNT',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: brandPrimaryColor,
                            letterSpacing: 2.0,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 24),

                        // 1. Full Name Input Box (Takes its own line)
                        _buildField(
                          controller: _fullNameController,
                          hintText: 'Full Name',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your full name';
                            }
                            if (val.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 2. Email Input Box (Takes its own line)
                        _buildField(
                          controller: _emailController,
                          hintText: 'Email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(val.trim())) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 3 & 4. Country Code and Phone Number in a single Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 125,
                              decoration: BoxDecoration(
                                color: isDark ? AppConstants.surfaceColor : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: isDark
                                    ? Border.all(color: AppConstants.borderLight, width: 1.2)
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCountryCodeISO,
                                  dropdownColor: isDark ? AppConstants.surfaceLightColor : Colors.white,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 2),
                                      child: Icon(
                                        Icons.phone_rounded,
                                        color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                                        size: 18,
                                      ),
                                    ),
                                    prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    filled: false,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  icon: Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted,
                                      size: 18,
                                    ),
                                  ),
                                  items: CountriesData.allCountries.map((c) {
                                    return DropdownMenuItem<String>(
                                      value: c.code,
                                      child: Text(
                                        '${c.flag} ${c.dialCode}',
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newVal) {
                                    if (newVal != null) {
                                      setState(() {
                                        _selectedCountryCodeISO = newVal;
                                        final matched = CountriesData.allCountries.firstWhere((c) => c.code == newVal);
                                        _selectedCountryCode = matched.dialCode;
                                        _selectedCountry = matched.name;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                controller: _phoneController,
                                hintText: 'Phone Number',
                                prefixIcon: Icons.phone_rounded,
                                keyboardType: TextInputType.phone,
                                maxLength: phoneMaxLength,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter phone number';
                                  }
                                  final cleanPhone = val.replaceAll(RegExp(r'\D'), '');
                                  if (_selectedCountryCode == '+91') {
                                    if (cleanPhone.length != 10) {
                                      return 'Please enter a valid 10-digit Indian phone number';
                                    }
                                  } else if (_selectedCountryCode == '+1') {
                                    if (cleanPhone.length != 10) {
                                      return 'Please enter a valid 10-digit phone number';
                                    }
                                  } else {
                                    if (cleanPhone.length < 7 || cleanPhone.length > 15) {
                                      return 'Please enter a valid phone number (7-15 digits)';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 5. Password Input Field (Takes its own line)
                        _buildField(
                          controller: _passwordController,
                          hintText: 'Password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isPasswordVisible: _passwordVisible,
                          onTogglePassword: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Please enter password';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 6. Confirm Password Input Field (Takes its own line)
                        _buildField(
                          controller: _confirmPasswordController,
                          hintText: 'Confirm password',
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          isPasswordVisible: _confirmPasswordVisible,
                          onTogglePassword: () {
                            setState(() {
                              _confirmPasswordVisible = !_confirmPasswordVisible;
                            });
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Please confirm password';
                            if (val != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 7. Company Name Input (Takes its own line)
                        _buildField(
                          controller: _companyController,
                          hintText: 'Company Name',
                          prefixIcon: Icons.business_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter company name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 8. Company Address Input (Takes its own line)
                        _buildField(
                          controller: _addressController,
                          hintText: 'Company Address',
                          prefixIcon: Icons.location_on_outlined,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter company address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // 9. Country Selection Dropdown (Takes its own line)
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppConstants.surfaceColor : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: isDark
                                ? Border.all(color: AppConstants.borderLight, width: 1.2)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCountry,
                              dropdownColor: isDark ? AppConstants.surfaceLightColor : Colors.white,
                              isExpanded: true,
                              decoration: InputDecoration(
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(left: 12, right: 8),
                                  child: Icon(
                                    Icons.public_rounded,
                                    color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                                    size: 18,
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted,
                                  size: 18,
                                ),
                              ),
                              items: CountriesData.allCountries.map((c) => c.name).map((String val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Text(
                                    val,
                                    style: GoogleFonts.nunito(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newVal) {
                                if (newVal != null) {
                                  setState(() {
                                    _selectedCountry = newVal;
                                    // Sync Country Code automatically
                                    final matched = CountriesData.allCountries.firstWhere((c) => c.name == newVal);
                                    _selectedCountryCode = matched.dialCode;
                                    _selectedCountryCodeISO = matched.code;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 10 & 11. City and State side-by-side in a Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildField(
                                controller: _cityController,
                                hintText: 'City',
                                prefixIcon: Icons.location_city_rounded,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Please enter city';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                controller: _stateController,
                                hintText: 'State',
                                prefixIcon: Icons.map_rounded,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Please enter state';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // 12. Zipcode Input Field (Takes its own line)
                        _buildField(
                          controller: _zipcodeController,
                          hintText: 'Zipcode',
                          prefixIcon: Icons.pin_drop_rounded,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter zipcode';
                            final cleanZip = val.trim().replaceAll(RegExp(r'\s+'), '');
                            if (cleanZip.length < 3 || cleanZip.length > 10) {
                              return 'Please enter a valid zipcode (3-10 characters)';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // 13. Accept Terms Checkbox row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _termsAccepted,
                                activeColor: isDark ? AppConstants.accentColorDark : const Color(0xFF398860),
                                onChanged: (bool? val) {
                                  setState(() {
                                    _termsAccepted = val ?? false;
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                side: BorderSide(
                                  color: isDark 
                                      ? AppConstants.textMuted 
                                      : AppConstants.lightBorderLight,
                                  width: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: RichText(
                                text: TextSpan(
                                  text: 'I have read and accept ',
                                  style: GoogleFonts.nunito(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white70 : const Color(0xFF2E6F40),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'terms and condition.',
                                      style: GoogleFonts.nunito(
                                        color: isDark ? AppConstants.accentColorDark : const Color(0xFF2E6F40),
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const TermsAndConditionsPage(),
                                              fullscreenDialog: true,
                                            ),
                                          );
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // 14. Centered Solid primary AuthButton
                        AuthButton(
                          text: 'Sign Up',
                          isLoading: state is AuthLoading,
                          onTap: _onSignUpPressed,
                        ),

                        const SizedBox(height: 24),

                        // Back to Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account? ",
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: isDark ? AppConstants.accentColorDark : const Color(0xFF398860),
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConstants.surfaceColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: AppConstants.borderLight, width: 1.2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && !isPasswordVisible,
        keyboardType: keyboardType,
        validator: validator,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? AppConstants.textPrimary : AppConstants.lightTextPrimary,
        ),
        decoration: InputDecoration(
          counterText: maxLength != null ? "" : null,
          hintText: hintText,
          hintStyle: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: isDark ? AppConstants.textSecondary : AppConstants.lightTextSecondary,
            size: 18,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: isDark ? AppConstants.textMuted : AppConstants.lightTextMuted,
                    size: 18,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }
}
