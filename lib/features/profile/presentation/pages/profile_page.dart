import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_flutter/core/errors/failures.dart';
import 'package:splito_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:splito_flutter/features/profile/presentation/providers/profile_provider.dart';
import 'package:splito_flutter/shared/widgets/app_text_field.dart';
import 'package:splito_flutter/shared/widgets/primary_button.dart';
import 'package:splito_flutter/shared/widgets/notification_bell.dart';

/// Full screen view displaying user profile details and sign-out actions.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: const [
          NotificationBell(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  user.initials,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: const Text('Name'),
                      subtitle: Text(user.name),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(user.email),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.monetization_on_outlined),
                      title: const Text('Preferred Currency'),
                      subtitle: Text(user.preferredCurrency),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Edit Profile',
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return _EditProfileBottomSheet(
                      initialName: user.name,
                      initialCurrency: user.preferredCurrency,
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileBottomSheet extends ConsumerStatefulWidget {
  final String initialName;
  final String initialCurrency;

  const _EditProfileBottomSheet({
    required this.initialName,
    required this.initialCurrency,
  });

  @override
  ConsumerState<_EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends ConsumerState<_EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedCurrency = widget.initialCurrency;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(updateProfileNotifierProvider.notifier).updateProfile(
            name: _nameController.text.trim(),
            preferredCurrency: _selectedCurrency,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final updateState = ref.watch(updateProfileNotifierProvider);

    ref.listen<AsyncValue<void>>(
      updateProfileNotifierProvider,
      (previous, next) {
        if (next is AsyncData<void>) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully.')),
          );
        } else if (next is AsyncError) {
          final error = next.error;
          final message = error is Failure ? error.message : error.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
    );

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Profile',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                labelText: 'Full Name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (value.length > 100) {
                    return 'Name must be 100 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Preferred Currency',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const ['INR', 'USD', 'EUR', 'GBP'].map((currency) {
                  return ChoiceChip(
                    label: Text(currency),
                    selected: _selectedCurrency == currency,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCurrency = currency;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Save Changes',
                isLoading: updateState.isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
