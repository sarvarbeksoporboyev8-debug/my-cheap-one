import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:go_router/go_router.dart';
import 'package:sellingapp/nav.dart';
import 'package:sellingapp/features/cart/presentation/controllers/cart_controller.dart';
import 'package:sellingapp/features/checkout/presentation/state/checkout_state.dart';

class CheckoutFlowPage extends rp.ConsumerStatefulWidget {
  const CheckoutFlowPage({super.key});
  @override
  rp.ConsumerState<CheckoutFlowPage> createState() => _CheckoutFlowPageState();
}

class _CheckoutFlowPageState extends rp.ConsumerState<CheckoutFlowPage> {
  int step = 0;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Stepper(
        currentStep: step,
        onStepContinue: () {
          if (step == 0 && !_formKey.currentState!.validate()) return;
          if (step < 3) {
            setState(() => step++);
          } else {
            final agreed = ref.read(checkoutProvider).agreed;
            if (!agreed) return;
            ref.read(cartControllerProvider.notifier).clear();
            if (mounted) context.go(AppRoutes.confirmation);
          }
        },
        onStepCancel: () => setState(() => step = step > 0 ? step - 1 : 0),
        steps: [
          Step(title: const Text('Details'), isActive: step >= 0, content: _DetailsForm(formKey: _formKey)),
          const Step(title: Text('Delivery/Pickup'), isActive: true, content: _ShippingStep()),
          const Step(title: Text('Payment'), isActive: true, content: _PaymentStep()),
          const Step(title: Text('Summary'), isActive: true, content: _SummaryStep()),
        ],
      ),
    );
  }
}

class _DetailsForm extends rp.ConsumerWidget {
  final GlobalKey<FormState> formKey;
  const _DetailsForm({required this.formKey});
  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final data = ref.watch(checkoutProvider);
    return Form(
      key: formKey,
      child: Column(children: [
        TextFormField(initialValue: data.name, decoration: const InputDecoration(labelText: 'Full name'), onChanged: (v) => ref.read(checkoutProvider.notifier).setName(v), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
        TextFormField(initialValue: data.email, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, onChanged: (v) => ref.read(checkoutProvider.notifier).setEmail(v), validator: (v) => (v == null || !v.contains('@')) ? 'Invalid email' : null),
        TextFormField(initialValue: data.address1, decoration: const InputDecoration(labelText: 'Address line 1'), onChanged: (v) => ref.read(checkoutProvider.notifier).setAddress1(v), validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
      ]),
    );
  }
}

class _ShippingStep extends rp.ConsumerWidget {
  const _ShippingStep();
  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final method = ref.watch(checkoutProvider).method;
    return Column(children: [
      RadioListTile(value: 'pickup', groupValue: method, onChanged: (v) => ref.read(checkoutProvider.notifier).setMethod(v as String), title: const Text('Pickup')),
      RadioListTile(value: 'delivery', groupValue: method, onChanged: (v) => ref.read(checkoutProvider.notifier).setMethod(v as String), title: const Text('Delivery')),
    ]);
  }
}

class _PaymentStep extends rp.ConsumerWidget {
  const _PaymentStep();
  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final payment = ref.watch(checkoutProvider).payment;
    return Column(children: [
      RadioListTile(value: 'card', groupValue: payment, onChanged: (v) => ref.read(checkoutProvider.notifier).setPayment(v as String), title: Row(children: [Icon(Icons.credit_card, color: scheme.primary), const SizedBox(width: 8), const Text('Mock Card')]))
      ,
      RadioListTile(value: 'wallet', groupValue: payment, onChanged: (v) => ref.read(checkoutProvider.notifier).setPayment(v as String), title: Row(children: [Icon(Icons.account_balance_wallet, color: scheme.primary), const SizedBox(width: 8), const Text('Mock Wallet')]))
    ]);
  }
}

class _SummaryStep extends rp.ConsumerWidget {
  const _SummaryStep();
  @override
  Widget build(BuildContext context, rp.WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cart.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final it = cart.items[i];
          return Card(
            child: ListTile(
              title: Text(it.name),
              subtitle: Text('Qty ${it.quantity}'),
              trailing: Text('\$${it.total.toStringAsFixed(2)}'),
            ),
          );
        },
      ),
      const SizedBox(height: 8),
      Align(alignment: Alignment.centerRight, child: Text('Subtotal: \$${cart.subtotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium)),
      const SizedBox(height: 12),
      CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        value: ref.watch(checkoutProvider).agreed,
        onChanged: (v) => ref.read(checkoutProvider.notifier).setAgreed(v ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text('I agree to the terms and conditions'),
      ),
      const SizedBox(height: 8),
      FilledButton(
        onPressed: ref.watch(checkoutProvider).agreed
            ? () {
                ref.read(cartControllerProvider.notifier).clear();
                context.go(AppRoutes.confirmation);
              }
            : null,
        child: const Text('Place Order'),
      ),
      Text('* You must agree to continue', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
    ]);
  }
}
