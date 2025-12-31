import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../login_page.dart'; 

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  // Controlador apenas para exibir a data no campo de texto
  final _dateController = TextEditingController(); 
  
  DateTime? _birthDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      final data = doc.data();
      if (data != null) {
        _nameController.text = data['nome'] ?? '';
        _phoneController.text = data['telefone'] ?? '';
        _addressController.text = data['endereco'] ?? '';
        
        final ts = data['data_nascimento'];
        if (ts != null) {
          _birthDate = (ts as Timestamp).toDate();
          _dateController.text = DateFormat('dd/MM/yyyy').format(_birthDate!);
        }
      }
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Fecha o teclado para melhor UX
    FocusScope.of(context).unfocus();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .update({
        'nome': _nameController.text.trim(),
        'telefone': _phoneController.text.trim(),
        'endereco': _addressController.text.trim(),
        'data_nascimento': _birthDate != null ? Timestamp.fromDate(_birthDate!) : null,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar dados.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    
    if (!mounted) return;

    // Remove todas as rotas e vai para o Login
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.blueAccent),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  // Widget auxiliar padronizado (Igual ao Cadastro/Login)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        validator: (value) {
          if (label == 'Nome' && (value == null || value.isEmpty)) {
            return 'Por favor, informe seu nome';
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar do Usuário (Visual)
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Campos do Formulário
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nome',
                      icon: Icons.person_outline,
                    ),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Telefone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: _addressController,
                      label: 'Endereço',
                      icon: Icons.location_on_outlined,
                    ),
                    
                    // Campo de Data Clicável
                    _buildTextField(
                      controller: _dateController,
                      label: 'Data de Nascimento',
                      icon: Icons.calendar_today,
                      readOnly: true, // Impede digitar, só abre o calendário
                      onTap: _pickBirthDate,
                    ),

                    const SizedBox(height: 24),

                    // Botão Salvar
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _saveUserData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          'SALVAR ALTERAÇÕES',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Botão Sair
                    TextButton.icon(
                      onPressed: _logout,
                      icon: const Icon(Icons.logout, color: Colors.redAccent),
                      label: const Text(
                        'Sair da conta',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}










