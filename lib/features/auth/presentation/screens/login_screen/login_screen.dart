import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gestion_inventario/features/auth/presentation/providers/providers.dart';
import 'package:gestion_inventario/features/auth/presentation/screens/screens.dart';

import 'package:gestion_inventario/features/auth/presentation/widgets/widgets.dart';
import 'package:gestion_inventario/features/shared/shared.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  static const route = 'login_screen';

  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SingleChildScrollView(
              child: CustomBackground(
            color: colors.primary,
          )),
          SingleChildScrollView(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    top: 150,
                    bottom: 80,
                  ),
                  child: FormIcon(),
                ),
                FormContainerBackground(
                  color: colors.background,
                  child: const _LoginForm(),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }
}

class _LoginForm extends ConsumerWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginForm = ref.watch(loginFormProvider);
    ref.listen(authProvider, (previous, next) {
      if (next.errorMessage.isEmpty) return;
      customErrorMessage(context, next.errorMessage);
    });

    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: FormTitle(title: 'INICIA SESIÓN'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              CustomTextFormField(
                label: 'Correo',
                hint: 'juandpt@mail.com',
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) =>
                    ref.read(loginFormProvider.notifier).onEmailChanged(value),
                errorMessage: loginForm.isFormPosted
                    ? loginForm.email.errorMessage
                    : null,
              ),
              CustomTextFormField(
                label: 'Contraseña',
                subfixIcon: IconButton(
                  icon: ref.watch(obscureTextProvider)
                      ? const Icon(size: 25, FontAwesomeIcons.eye)
                      : const Icon(
                          FontAwesomeIcons.eyeSlash,
                          size: 25,
                        ),
                  onPressed: () {
                    ref
                        .read(obscureTextProvider.notifier)
                        .update((state) => !state);
                  },
                ),
                onFieldSubmitted: (_) async {
                  await ref
                      .read(loginFormProvider.notifier)
                      .onFormSubmit()
                      .then((_) {
                    if (ref.read(authProvider).authStatus ==
                        AuthStatus.authenticated) {
                      context.pushReplacementNamed(WelcomeScreen.route);
                    }
                  });
                },
                obscureText: ref.watch(obscureTextProvider),
                onChanged: (value) => ref
                    .read(loginFormProvider.notifier)
                    .onPasswordChanged(value),
                errorMessage: loginForm.isFormPosted
                    ? loginForm.password.errorMessage
                    : null,
              ),
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 250,
          height: 60,
          child: CustomFilledButton(
            text: 'INGRESAR',
            buttonColor: colors.primary,
            onPressed: loginForm.isPosting
                ? null
                : () async {
                    await ref
                        .read(loginFormProvider.notifier)
                        .onFormSubmit()
                        .then((_) {
                      if (ref.read(authProvider).authStatus ==
                          AuthStatus.authenticated) {
                        context.pushReplacementNamed(WelcomeScreen.route);
                      }
                    });
                  },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('¿No tienes cuenta?'),
            TextButton(
              onPressed: () {
                context.pushNamed(RegisterScreen.route);
                ref.invalidate(obscureTextProvider);
              },
              child: const Text('Crea una aquí'),
            ),
          ],
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
