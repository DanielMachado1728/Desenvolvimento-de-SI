import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores de Texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); 
  final _addressController = TextEditingController(); 
  final _passwordController = TextEditingController();

  // Variáveis de Estado
  bool _isLoading = false;
  bool _obscurePassword = true; 

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Adicionar contatos padrão
  Future<void> _adicionarContatosEmergencia(String uid) async {
    final contatos = [
      {
        'nome': 'Bombeiros',
        'telefone': '193',
        'endereco': 'Serviço de Emergência',
        'relacao': 'Emergência',
        'observacao': 'Incêndios, salvamentos e resgates',
        'fixo': true,
      },
      {
        'nome': 'SAMU',
        'telefone': '192',
        'endereco': 'Serviço de Atendimento Móvel de Urgência',
        'relacao': 'Emergência',
        'observacao': 'Urgências médicas',
        'fixo': true,
      },
      {
        'nome': 'Defesa Civil',
        'telefone': '199',
        'endereco': 'Serviço de Proteção Civil',
        'relacao': 'Emergência',
        'observacao': 'Desastres naturais e enchentes',
        'fixo': true,
      },
    ];

    final contatosRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('contatos');

    for (final contato in contatos) {
      await contatosRef.add(contato);
    }
  }

  void _register() async {
    FocusScope.of(context).unfocus(); 

    final nome = _nameController.text.trim();
    final email = _emailController.text.trim();
    final telefone = _phoneController.text.trim();
    final endereco = _addressController.text.trim();
    final senha = _passwordController.text.trim();

    if (nome.isEmpty || email.isEmpty || telefone.isEmpty || endereco.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: senha);

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nome': nome,
        'email': email,
        'telefone': telefone, 
        'endereco': endereco, 
        'uid': uid,
        'criado_em': Timestamp.now(),
      });

      await _adicionarContatosEmergencia(uid);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = 'Erro ao cadastrar.';
      if (e.code == 'email-already-in-use') {
        msg = 'Este e-mail já está cadastrado.';
      } else if (e.code == 'weak-password') {
        msg = 'A senha deve ter pelo menos 6 caracteres.';
      } else if (e.code == 'invalid-email') {
        msg = 'E-mail inválido.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado. Tente novamente.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Widget auxiliar reestilizado para o Tema Claro
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword ? _obscurePassword : false,
        // O style color white, agora usa o padrão (preto) do tema
        textCapitalization: isPassword || keyboardType == TextInputType.emailAddress 
            ? TextCapitalization.none 
            : TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[600]), // Cinza médio
          prefixIcon: Icon(icon, color: Colors.blueAccent), // Azul destaque
          filled: true,
          fillColor: Colors.grey[100], // Cinza claro no fundo
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          // Borda quando clica no campo
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey, // Ícone do olho cinza
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo Branco Limpo
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87), // Seta preta
        titleTextStyle: const TextStyle(
            color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Bem-vindo ao Ark App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.blueAccent, // Azul Royal
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Preencha seus dados para começar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 32),

              _buildTextField(
                controller: _nameController,
                label: 'Nome Completo',
                icon: Icons.person,
              ),
              _buildTextField(
                controller: _emailController,
                label: 'E-mail',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'Telefone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Endereço',
                icon: Icons.home,
              ),
              _buildTextField(
                controller: _passwordController,
                label: 'Senha',
                icon: Icons.lock,
                isPassword: true,
              ),

              const SizedBox(height: 24),

              SizedBox(
                height: 55,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent, // Fundo Azul
                          foregroundColor: Colors.white, // Texto Branco
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2, // Leve sombra para destacar no fundo branco
                        ),
                        child: const Text(
                          'CADASTRAR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
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














/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controladores de Texto
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController(); 
  final _addressController = TextEditingController(); 
  final _passwordController = TextEditingController();

  // Variáveis de Estado
  bool _isLoading = false;
  bool _obscurePassword = true; // Controla se a senha está escondida

  @override
  void dispose() {
    // limpar controladores ao sair da tela
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Adicionar contatos padrão
  Future<void> _adicionarContatosEmergencia(String uid) async {
    final contatos = [
      {
        'nome': 'Bombeiros',
        'telefone': '193',
        'endereco': 'Serviço de Emergência',
        'relacao': 'Emergência',
        'observacao': 'Incêndios, salvamentos e resgates',
        'fixo': true,
      },
      {
        'nome': 'SAMU',
        'telefone': '192',
        'endereco': 'Serviço de Atendimento Móvel de Urgência',
        'relacao': 'Emergência',
        'observacao': 'Urgências médicas',
        'fixo': true,
      },
      {
        'nome': 'Defesa Civil',
        'telefone': '199',
        'endereco': 'Serviço de Proteção Civil',
        'relacao': 'Emergência',
        'observacao': 'Desastres naturais e enchentes',
        'fixo': true,
      },
    ];

    final contatosRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('contatos');

    for (final contato in contatos) {
      await contatosRef.add(contato);
    }
  }

  void _register() async {
    FocusScope.of(context).unfocus(); // Fecha o teclado

    final nome = _nameController.text.trim();
    final email = _emailController.text.trim();
    final telefone = _phoneController.text.trim();
    final endereco = _addressController.text.trim();
    final senha = _passwordController.text.trim();

    // Validação básica
    if (nome.isEmpty || email.isEmpty || telefone.isEmpty || endereco.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Cria o usuário na Autenticação
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: senha);

      final uid = userCredential.user!.uid;

      // Salva os dados extras no Firestore
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nome': nome,
        'email': email,
        'telefone': telefone, 
        'endereco': endereco, 
        'uid': uid,
        'criado_em': Timestamp.now(),
      });

      // adiciona contatos de emergência
      await _adicionarContatosEmergencia(uid);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = 'Erro ao cadastrar.';
      if (e.code == 'email-already-in-use') {
        msg = 'Este e-mail já está cadastrado.';
      } else if (e.code == 'weak-password') {
        msg = 'A senha deve ter pelo menos 6 caracteres.';
      } else if (e.code == 'invalid-email') {
        msg = 'E-mail inválido.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado. Tente novamente.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Widget auxiliar para criar os campos de texto com estilo padrão
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword ? _obscurePassword : false,
        style: const TextStyle(color: Colors.white), // Texto digitado branco
        textCapitalization: isPassword || keyboardType == TextInputType.emailAddress 
            ? TextCapitalization.none 
            : TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.cyanAccent),
          filled: true,
          fillColor: const Color(0xFF112240), // Fundo do input levemente mais claro
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.cyanAccent, width: 2),
          ),
          // Lógica do botão de olho para senha
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white54,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F), // Azul Marinho Profundo
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Junte-se ao Ark App',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Preencha seus dados para começar',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 32),

              // Campos do Formulário
              _buildTextField(
                controller: _nameController,
                label: 'Nome Completo',
                icon: Icons.person,
              ),
              _buildTextField(
                controller: _emailController,
                label: 'E-mail',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _phoneController,
                label: 'Telefone',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _addressController,
                label: 'Endereço',
                icon: Icons.home,
              ),
              _buildTextField(
                controller: _passwordController,
                label: 'Senha',
                icon: Icons.lock,
                isPassword: true,
              ),

              const SizedBox(height: 24),

              // Botão de Cadastrar
              SizedBox(
                height: 55,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.cyanAccent))
                    : ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: const Color(0xFF0A192F), // Texto escuro
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'CADASTRAR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
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
*/













/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false;

  Future<void> _adicionarContatosEmergencia(String uid) async {
    final contatos = [
      {
        'nome': 'Bombeiros',
        'telefone': '193',
        'endereco': 'Serviço de Emergência',
        'relacao': 'Emergência',
        'observacao': 'Incêndios, salvamentos e resgates',
        'fixo': true,
      },
      {
        'nome': 'SAMU',
        'telefone': '192',
        'endereco': 'Serviço de Atendimento Móvel de Urgência',
        'relacao': 'Emergência',
        'observacao': 'Urgências médicas',
        'fixo': true,
      },
      {
        'nome': 'Defesa Civil',
        'telefone': '199',
        'endereco': 'Serviço de Proteção Civil',
        'relacao': 'Emergência',
        'observacao': 'Desastres naturais e enchentes',
        'fixo': true,
      },
    ];

    final contatosRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('contatos');

    for (final contato in contatos) {
      await contatosRef.add(contato);
    }
  }

  void _register() async {
    FocusScope.of(context).unfocus();

    final nome = _nameController.text.trim();
    final email = _emailController.text.trim();
    final senha = _passwordController.text.trim();

    if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, preencha todos os campos')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: senha);

      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('usuarios').doc(uid).set({
        'nome': nome,
        'email': email,
        'uid': uid,
        'criado_em': Timestamp.now(),
      });

      // ➕ Adiciona contatos de emergência
      await _adicionarContatosEmergencia(uid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg = 'Erro ao cadastrar.';
      if (e.code == 'email-already-in-use') {
        msg = 'Este e-mail já está cadastrado.';
      } else if (e.code == 'weak-password') {
        msg = 'A senha é muito fraca.';
      } else if (e.code == 'invalid-email') {
        msg = 'E-mail inválido.';
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro inesperado. Tente novamente.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Cadastrar'),
                  ),
          ],
        ),
      ),
    );
  }
}

*/