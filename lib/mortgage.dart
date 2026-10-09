class Mortgage {
  double amount;
  int years;

  // Stored as a decimal.
  // Example: 3.5% is stored as 0.035.
  double rate;

  Mortgage({
    this.amount = 100000.0,
    this.years = 30,
    this.rate = 0.035,
  });

  void setAmount(double newAmount) {
    if (newAmount >= 0) {
      amount = newAmount;
    }
  }

  void setYears(int newYears) {
    if (newYears >= 0) {
      years = newYears;
    }
  }

  void setRate(double newRate) {
    if (newRate >= 0) {
      rate = newRate;
    }
  }

  double monthlyPayment() {
    final double monthlyRate = rate / 12;
    final int numberOfPayments = years * 12;

    if (numberOfPayments == 0) {
      return 0;
    }

    if (monthlyRate == 0) {
      return amount / numberOfPayments;
    }

    final double temp =
        _power(1 / (1 + monthlyRate), numberOfPayments.toDouble());

    return amount * monthlyRate / (1 - temp);
  }

  double totalPayment() {
    return monthlyPayment() * years * 12;
  }

  String formattedAmount() {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String formattedMonthlyPayment() {
    return '\$${monthlyPayment().toStringAsFixed(2)}';
  }

  String formattedTotalPayment() {
    return '\$${totalPayment().toStringAsFixed(2)}';
  }

  String formattedRate() {
    return '${(rate * 100).toStringAsFixed(2)}%';
  }

  double _power(double base, double exponent) {
    num result = 1;

    for (int i = 0; i < exponent.toInt(); i++) {
      result *= base;
    }

    return result.toDouble();
  }
}