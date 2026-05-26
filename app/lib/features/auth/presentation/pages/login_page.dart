import 'package:app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:app/features/auth/presentation/bloc/auth_event.dart';
import 'package:app/features/auth/presentation/bloc/auth_state.dart';
import 'package:app/features/auth/presentation/widgets/auth_button.dart';
import 'package:app/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:app/features/auth/presentation/widgets/login_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      BlocProvider.of<AuthBloc>(context).add(
        LoginEvent(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthInputField(
                  hint: "Email",
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Email is required";
                    }
                    if (!value.contains("@")) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                  controller: _emailController,
                ),
                SizedBox(height: 20),
                AuthInputField(
                  hint: "Password",
                  icon: Icons.password,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Password is required";
                    }
                    return null;
                  },
                  controller: _passwordController,
                  isPassword: true,
                ),
                SizedBox(height: 20),
            
                // 🔥 BlocConsumer giống Register
                BlocConsumer<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Center(child: CircularProgressIndicator());
                    }
                    return AuthButton(onPressed: _onLogin, text: "Login");
                  },
                  listener: (context, state) {
                    if (state is AuthSuccess) {
                      Navigator.pushNamedAndRemoveUntil(context, "/conversationsPage", (route) => false);
                    } else if (state is AuthFailure) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(state.error)));
                    }
                  },
                ),
            
                SizedBox(height: 10),
            
                LoginPrompt(
                  title: "Don't have an account? ",
                  subtitle: "Register",
                  onTap: () {
                    Navigator.pushNamed(context, "/register");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
