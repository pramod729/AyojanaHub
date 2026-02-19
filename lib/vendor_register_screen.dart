import 'package:ayojana_hub/auth_provider.dart';
import 'package:ayojana_hub/vendor_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VendorRegisterScreen extends StatefulWidget {
  const VendorRegisterScreen({super.key});

  @override
  State<VendorRegisterScreen> createState() => _VendorRegisterScreenState();
}

class _VendorRegisterScreenState extends State<VendorRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Form state
  String _selectedCategory = 'Catering';
  final List<String> _selectedServices = [];
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;
  String _passwordStrength = '';

  final List<String> _categories = [
    'Catering',
    'Photography',
    'DJ & Music',
    'Decoration',
    'Venue',
    'Planning',
  ];

  final Map<String, List<String>> _servicesByCategory = {
    'Catering': [
      'North Indian',
      'South Indian',
      'Continental',
      'Chinese',
      'Desserts',
      'Beverages'
    ],
    'Photography': [
      'Wedding Photography',
      'Candid Photography',
      'Video Coverage',
      'Pre-wedding',
      'Drone Photography'
    ],
    'DJ & Music': [
      'DJ Service',
      'Live Band',
      'Sound System',
      'Lighting',
      'MC Service'
    ],
    'Decoration': [
      'Stage Decoration',
      'Flower Arrangements',
      'Thematic Decor',
      'Lighting Design',
      'Setup & Dismantling'
    ],
    'Venue': [
      'Indoor Venue',
      'Outdoor Venue',
      'Catering Available',
      'Event Management',
      'Parking'
    ],
    'Planning': [
      'Complete Planning',
      'Vendor Coordination',
      'Day Management',
      'Custom Themes',
      'Budget Management'
    ],
  };

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Calculate password strength
  void _updatePasswordStrength() {
    final password = _passwordController.text;
    setState(() {
      if (password.isEmpty) {
        _passwordStrength = '';
      } else if (password.length < 8) {
        _passwordStrength = 'weak';
      } else if (password.length < 12) {
        _passwordStrength = 'medium';
      } else {
        _passwordStrength = 'strong';
      }
    });
  }

  // Get password strength color
  Color _getPasswordStrengthColor() {
    switch (_passwordStrength) {
      case 'weak':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'strong':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Get password strength text
  String _getPasswordStrengthText() {
    switch (_passwordStrength) {
      case 'weak':
        return 'Weak password';
      case 'medium':
        return 'Good password';
      case 'strong':
        return 'Strong password';
      default:
        return '';
    }
  }

  // Validate email format
  bool _isValidEmail(String email) {
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    return RegExp(emailPattern).hasMatch(email);
  }

  // Validate phone number (10 digits for Indian numbers)
  bool _isValidPhone(String phone) {
    const phonePattern = r'^[0-9]{10}$';
    return RegExp(phonePattern).hasMatch(phone.replaceAll(RegExp(r'\D'), ''));
  }

  Future<void> _registerVendor() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields correctly')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Password mismatch', 'Passwords do not match. Please check and try again.');
      return;
    }

    if (_selectedServices.isEmpty) {
      _showErrorDialog('No services selected', 'Please select at least one service');
      return;
    }

    if (!_agreedToTerms) {
      _showErrorDialog('Terms not agreed', 'Please agree to the Terms and Conditions');
      return;
    }

    FocusScope.of(context).unfocus();
    
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final vendorProvider = Provider.of<VendorProvider>(context, listen: false);

      // First, register the user account with vendor role
      final registerError = await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        role: 'vendor',
      );

      if (!mounted) return;

      if (registerError != null) {
        _showErrorDialog('Registration failed', registerError);
        setState(() => _isLoading = false);
        return;
      }

      // Then update vendor profile in users collection
      final vendorProfileError = await authProvider.updateVendorProfile(
        businessName: _businessNameController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        services: _selectedServices,
      );

      if (!mounted) return;

      if (vendorProfileError != null) {
        _showErrorDialog('Profile update failed', vendorProfileError);
        setState(() => _isLoading = false);
        return;
      }

      // Finally, create vendor document in vendors collection
      final userId = authProvider.user?.uid;
      if (userId != null) {
        final vendorCreationError = await vendorProvider.createVendorFromRegistration(
          userId: userId,
          businessName: _businessNameController.text.trim(),
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          location: _locationController.text.trim(),
          services: _selectedServices,
        );

        if (!mounted) return;

        if (vendorCreationError != null) {
          _showErrorDialog('Vendor creation failed', vendorCreationError);
          setState(() => _isLoading = false);
          return;
        }
      }

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Error', 'An unexpected error occurred. Please try again.');
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Expanded(child: Text('Registration Successful!')),
          ],
        ),
        content: const Text(
          'Your vendor account has been created successfully. You can now log in with your credentials and manage your business profile.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Vendor'),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Personal Information Section
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 16),
              _buildNameField(),
              const SizedBox(height: 12),
              _buildEmailField(),
              const SizedBox(height: 12),
              _buildPhoneField(),
              const SizedBox(height: 12),
              _buildPasswordField(),
              const SizedBox(height: 8),
              _buildPasswordStrengthIndicator(),
              const SizedBox(height: 12),
              _buildConfirmPasswordField(),
              const SizedBox(height: 24),
              
              // Business Information Section
              _buildSectionHeader('Business Information'),
              const SizedBox(height: 16),
              _buildBusinessNameField(),
              const SizedBox(height: 12),
              _buildCategoryDropdown(),
              const SizedBox(height: 12),
              _buildLocationField(),
              const SizedBox(height: 12),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              
              // Services Section
              _buildSectionHeader('Services Offered'),
              const SizedBox(height: 12),
              _buildServicesCheckboxes(),
              const SizedBox(height: 16),
              
              // Terms and Conditions
              _buildTermsCheckbox(),
              const SizedBox(height: 24),
              
              // Submit Button
              _buildSubmitButton(),
              const SizedBox(height: 12),
              
              // Login Link
              _buildLoginLink(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Full Name *',
        hintText: 'e.g., John Doe',
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Full name is required';
        }
        final parts = value!.trim().split(' ');
        if (parts.length < 2) {
          return 'Please enter first and last name';
        }
        if (value.length < 3) {
          return 'Name must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Email Address *',
        hintText: 'e.g., vendor@example.com',
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Email is required';
        }
        if (!_isValidEmail(value!)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      maxLength: 10,
      decoration: InputDecoration(
        labelText: 'Phone Number *',
        hintText: 'e.g., 9876543210',
        prefixIcon: const Icon(Icons.phone_outlined),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Phone number is required';
        }
        if (!_isValidPhone(value!)) {
          return 'Please enter a valid 10-digit phone number';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Password *',
        hintText: 'Min. 8 characters with uppercase, lowercase, number & symbol',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Password is required';
        }
        if ((value?.length ?? 0) < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    if (_passwordStrength.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _passwordStrength == 'weak' ? 0.33 : _passwordStrength == 'medium' ? 0.66 : 1.0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getPasswordStrengthColor()),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _getPasswordStrengthText(),
          style: TextStyle(
            color: _getPasswordStrengthColor(),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Confirm Password *',
        hintText: 'Re-enter your password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Please confirm your password';
        }
        if (value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildBusinessNameField() {
    return TextFormField(
      controller: _businessNameController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Business Name *',
        hintText: 'e.g., Elite Catering Services',
        prefixIcon: const Icon(Icons.business_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Business name is required';
        }
        if (value!.length < 3) {
          return 'Business name must be at least 3 characters';
        }
        return null;
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      decoration: InputDecoration(
        labelText: 'Business Category *',
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: _categories.map((category) {
        return DropdownMenuItem(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedCategory = value;
            _selectedServices.clear();
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a category';
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    return TextFormField(
      controller: _locationController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: 'Location *',
        hintText: 'e.g., Mumbai, Maharashtra',
        prefixIcon: const Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Location is required';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 4,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        labelText: 'Business Description *',
        hintText: 'Describe your business, experience, and specialties',
        prefixIcon: const Icon(Icons.description_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        alignLabelWithHint: true,
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Business description is required';
        }
        if (value!.length < 20) {
          return 'Please provide at least 20 characters';
        }
        return null;
      },
    );
  }

  Widget _buildServicesCheckboxes() {
    final services = _servicesByCategory[_selectedCategory] ?? [];
    
    if (services.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No services available for this category'),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: services.map((service) {
        return FilterChip(
          label: Text(service),
          selected: _selectedServices.contains(service),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                if (!_selectedServices.contains(service)) {
                  _selectedServices.add(service);
                }
              } else {
                _selectedServices.remove(service);
              }
            });
          },
          backgroundColor: Colors.transparent,
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.12),
          side: BorderSide(
            color: _selectedServices.contains(service)
                ? Theme.of(context).primaryColor
                : Colors.grey[400]!,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTermsCheckbox() {
    return CheckboxListTile(
      title: Text(
        'I agree to Terms and Conditions *',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      value: _agreedToTerms,
      onChanged: (value) {
        setState(() => _agreedToTerms = value ?? false);
      },
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: (_isLoading) ? null : _registerVendor,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text('Register as Vendor'),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Already have an account? '),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
            child: const Text(
              'Log In',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}


