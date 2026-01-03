import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddContactPage extends StatefulWidget {
  final String? contactId;
  final Map<String, dynamic>? contactData;

  const AddContactPage({super.key, this.contactId, this.contactData});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _addressController = TextEditingController();
  final _relationController = TextEditingController();
  final _noteController = TextEditingController();
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Se veio dados, é edição
    if (widget.contactData != null) {
      _nameController.text = widget.contactData!['nome'] ?? '';
      _numberController.text = widget.contactData!['telefone'] ?? '';
      _addressController.text = widget.contactData!['endereco'] ?? '';
      _relationController.text = widget.contactData!['relacao'] ?? '';
      _noteController.text = widget.contactData!['observacao'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _addressController.dispose();
    _relationController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // Lógica de Salvar/Atualizar
  void _saveOrUpdateContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: Usuário não logado.')),
        );
        return;
      }

      final collection = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('contatos');

      final dados = {
        'nome': _nameController.text.trim(),
        'telefone': _numberController.text.trim(),
        'endereco': _addressController.text.trim(),
        'relacao': _relationController.text.trim(),
        'observacao': _noteController.text.trim(),
        'atualizado_em': Timestamp.now(),
        // Contatos criados manualmente NUNCA são fixos do sistema
        'fixo': false, 
      };

      if (widget.contactId == null) {
        // CRIAR
        dados['criado_em'] = Timestamp.now();
        await collection.add(dados);
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contato salvo com sucesso!')),
        );
      } else {
        // ATUALIZAR
        await collection.doc(widget.contactId).update(dados);
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contato atualizado com sucesso!')),
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar o contato.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.contactId != null;
    final Color primaryYellow = Colors.amber[700]!; 

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Editar Contato' : 'Novo Contato',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.amber, 
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, 'Nome', Icons.person, required: true),
              _buildTextField(_numberController, 'Telefone', Icons.phone, inputType: TextInputType.phone, required: true),
              _buildTextField(_addressController, 'Endereço', Icons.location_on),
              _buildTextField(_relationController, 'Relação (ex: Mãe)', Icons.people),
              _buildTextField(_noteController, 'Observação', Icons.note, maxLines: 2),

              const SizedBox(height: 24),
              
              _isLoading
                  ? Center(child: CircularProgressIndicator(color: primaryYellow))
                  : SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveOrUpdateContact,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryYellow,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          isEditing ? 'ATUALIZAR CONTATO' : 'SALVAR CONTATO',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    {bool required = false, TextInputType inputType = TextInputType.text, int maxLines = 1}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.amber[800]),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.amber, width: 2)),
        ),
        validator: required ? (value) => value!.isEmpty ? 'Campo obrigatório' : null : null,
      ),
    );
  }
}