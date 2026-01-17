import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckoutData {
  final String name;
  final String email;
  final String address1;
  final String method; // pickup or delivery
  final String payment; // card/wallet/mock
  final bool agreed;
  const CheckoutData({this.name = '', this.email = '', this.address1 = '', this.method = 'pickup', this.payment = 'card', this.agreed = false});

  CheckoutData copyWith({String? name, String? email, String? address1, String? method, String? payment, bool? agreed}) => CheckoutData(
        name: name ?? this.name,
        email: email ?? this.email,
        address1: address1 ?? this.address1,
        method: method ?? this.method,
        payment: payment ?? this.payment,
        agreed: agreed ?? this.agreed,
      );
}

class CheckoutNotifier extends Notifier<CheckoutData> {
  @override
  CheckoutData build() => const CheckoutData();
  void setName(String v) => state = state.copyWith(name: v);
  void setEmail(String v) => state = state.copyWith(email: v);
  void setAddress1(String v) => state = state.copyWith(address1: v);
  void setMethod(String v) => state = state.copyWith(method: v);
  void setPayment(String v) => state = state.copyWith(payment: v);
  void setAgreed(bool v) => state = state.copyWith(agreed: v);
}

final checkoutProvider = NotifierProvider<CheckoutNotifier, CheckoutData>(() => CheckoutNotifier());
