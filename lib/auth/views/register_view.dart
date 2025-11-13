import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  String _selectedRole = 'ROLE_STUDENT';
  bool _isCaptchaVerified = false;
  bool _isVerifying = false;

  void _verifyCaptcha() async {
    setState(() {
      _isVerifying = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isVerifying = false;
      _isCaptchaVerified = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: size.height * 0.25,
                child: Image.asset(
                  'images/learnhive_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.school, size: 100, color: Colors.blue);
                  },
                ),
              ),
              const SizedBox(height: 40),

              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Crear cuenta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      TextField(
                        controller: _userController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline),
                          labelText: 'Usuario',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: _passController,
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline),
                          labelText: 'Contraseña',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Selecciona tu rol:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('Teacher'),
                            value: 'ROLE_TEACHER',
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('Student'),
                            value: 'ROLE_STUDENT',
                            groupValue: _selectedRole,
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // reCAPTCHA con IMAGEN
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: Row(
                          children: [
                            // Checkbox
                            GestureDetector(
                              onTap: _isVerifying || _isCaptchaVerified
                                  ? null
                                  : _verifyCaptcha,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _isCaptchaVerified
                                        ? Colors.blue
                                        : Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  color: _isCaptchaVerified ? Colors.blue : Colors.white,
                                ),
                                child: _isVerifying
                                    ? const Padding(
                                  padding: EdgeInsets.all(2),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                )
                                    : _isCaptchaVerified
                                    ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                                    : null,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Texto "I'm not a robot"
                            const Expanded(
                              child: Text(
                                "I'm not a robot",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            const SizedBox(width: 8),

                            // reCAPTCHA con IMAGEN
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // IMAGEN reCAPTCHA
                                Image.asset(
                                  'images/reCAPTCHA.png',
                                  width: 70,
                                  height: 24,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback si la imagen no carga
                                    return Container(
                                      width: 70,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey.shade400),
                                        borderRadius: BorderRadius.circular(2),
                                        color: Colors.white,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'reCAPTCHA',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Privacy - Terms',
                                  style: TextStyle(
                                    fontSize: 8,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Indicador visual del estado del reCAPTCHA
                      if (!_isCaptchaVerified && _userController.text.isNotEmpty && _passController.text.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Usuario y contraseña listos - Esperando verificación reCAPTCHA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      if (_isCaptchaVerified && _userController.text.isNotEmpty && _passController.text.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            '¡Todo listo! Puedes registrarte',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                      // Register button - COLOR AZUL ORIGINAL
                      vm.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _isCaptchaVerified &&
                            _userController.text.isNotEmpty &&
                            _passController.text.isNotEmpty
                            ? () {
                          vm.signUp(
                            _userController.text.trim(),
                            _passController.text.trim(),
                            _selectedRole,
                          );
                          Navigator.pop(context);
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blueAccent, // Siempre azul
                          disabledBackgroundColor: Colors.grey.shade400,
                        ),
                        child: const Text(
                          'Registrarse', // Texto simple sin emoji
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      if (vm.error != null)
                        Text(
                          vm.error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),

                      const SizedBox(height: 20),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          '¿Ya tienes cuenta? Inicia sesión',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}