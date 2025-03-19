// form_validation.dart

class FormValidation {
  // Email Validation
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter an email';
    }
    String pattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; // Regular expression for email
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  // Password Validation
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter a password';
    }
    // Check for minimum 6 characters
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // Confirm Password Validation
  static String? validateConfirmPassword(
      String? confirmPassword, String? password) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmPassword != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Contact Number Validation (example: 10 digits)
  static String? validateContact(String? contact) {
    if (contact == null || contact.isEmpty) {
      return 'Please enter a contact number';
    }
    // Regex for 10-digit contact number (you can modify this pattern for specific formats)
    String pattern = r'^[0-9]{10}$';
    RegExp regExp = RegExp(pattern);
    if (!regExp.hasMatch(contact)) {
      return 'Please enter a valid 10-digit contact number';
    }
    return null;
  }

  // Name Validation
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  // Address Validation
  static String? validateAddress(String? address) {
    if (address == null || address.isEmpty) {
      return 'Please enter your address';
    }
    return null;
  }

  // Dropdown Validation
  static String? validateDropdown(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select an option';
    }
    return null;
  }

  static String? validateValue(String? val) {
    if (val == null || val.isEmpty) {
      return 'Please enter a value';
    }
    return null;
  }

  static String? validateGender(String? gender) {
    if (gender == null || gender.isEmpty) {
      return 'Please select a gender';
    }
    return null; // Gender is valid
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a date';
    }

    // Optional: Validate if the date is within a specific range
    DateTime selectedDate = DateTime.parse(value);
    DateTime minDate = DateTime(2000, 1, 1);
    DateTime maxDate = DateTime(2100, 12, 31);

    if (selectedDate.isBefore(minDate) || selectedDate.isAfter(maxDate)) {
      return 'Date must be between ${minDate.year} and ${maxDate.year}';
    }

    return null; // Valid date
  }

  static String? validateCreditCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a credit card number';
    }
    if (!RegExp(r'^\d{16}$').hasMatch(value)) {
      return 'Credit card number must be exactly 16 digits';
    }
    if (!luhnCheck(value)) {
      return 'Invalid credit card number';
    }
    return null;
  }

// Luhn Algorithm to check valid card number
  static bool luhnCheck(String cardNumber) {
    int sum = 0;
    bool alternate = false;
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  static String? validateCardHolderName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter cardholder name';
    }
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(value)) {
      return 'Name must only contain letters and spaces';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter expiry date';
    }
    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value)) {
      return 'Expiry date must be in MM/YY format';
    }

    final now = DateTime.now();
    int month = int.parse(value.split('/')[0]);
    int year = int.parse('20${value.split('/')[1]}');

    final expiryDate = DateTime(year, month);
    if (expiryDate.isBefore(now)) {
      return 'Card has expired';
    }

    return null;
  }

  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter CVV';
    }
    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'CVV must be 3 or 4 digits';
    }
    return null;
  }

  static String? validateUpiId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a UPI ID';
    }
    if (!RegExp(r'^[a-zA-Z0-9.\-_]+@[a-zA-Z]+$').hasMatch(value)) {
      return 'Invalid UPI ID format (e.g., user@bank)';
    }
    return null;
  }
}
