import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_contact_page.dart'; 
//import 'package:url_launcher/url_launcher.dart'; usar no futuro quando launcher estiver ok
// import '../models/contact_model.dart'; // Mantido, mas não necessário neste widget


class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  
  // Função de Deletar (Só funciona se o contato não for do sistema)
  Future<void> _deleteContact(String contactId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .collection('contatos')
          .doc(contactId)
          .delete();
    }
  }

  // Função de Navegar para Edição
  void _editContact(String id, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddContactPage(contactId: id, contactData: data),
      ),
    );
  }

  // Função Simulada de Ligar
  void _fazerLigacao(String nome, String numero) {
    // Aqui entraria o url_launcher real. Por enquanto, mensagem simulada.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.phone_in_talk, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text("Ligando para $nome ($numero)...")),
          ],
        ),
        backgroundColor: Colors.green[700], // Verde telefone
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    // Tema Amarelo solicitado
    final Color primaryColor = Colors.amber[900]!; 
    final Color headerColor = Colors.amber;

    if (user == null) {
      return const Center(child: Text('Usuário não autenticado.'));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        title: const Text(
          'Contatos de Confiança',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: headerColor,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('contatos')
            // Ordena para que os contatos do sistema (fixo=true) apareçam primeiro ou por nome
            // Aqui mantive por nome para ficar organizado alfabeticamente
            .orderBy('nome') 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Erro ao carregar contatos'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber));
          }

          final contatos = snapshot.data!.docs;

          if (contatos.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: contatos.length,
            itemBuilder: (context, index) {
              final contato = contatos[index];
              final data = contato.data() as Map<String, dynamic>;
              
              // --- A REGRA DE OURO ---
              // Verificamos se é um contato do sistema (Bombeiros, SAMU, etc)
              // No seu cadastro, você usou a chave 'fixo': true. Vamos usar ela.
              final bool isSystemContact = data['fixo'] == true;

              // Widget visual do card
              Widget cardContent = _buildContactCard(
                id: contato.id, 
                data: data, 
                primaryColor: primaryColor, 
                isSystem: isSystemContact
              );

              // LÓGICA DE BLOQUEIO
              if (isSystemContact) {
                // Se for Bombeiro/SAMU: Retorna APENAS o card (sem Dismissible/Swipe)
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: cardContent, 
                );
              } else {
                // Se for contato comum: Envolve com Dismissible para permitir excluir
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Dismissible(
                    key: Key(contato.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('Excluir', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(width: 8),
                          Icon(Icons.delete_sweep, color: Colors.white),
                        ],
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Excluir Contato"),
                          content: Text("Tem certeza que deseja remover ${data['nome']}?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text("Excluir", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) => _deleteContact(contato.id),
                    child: cardContent,
                  ),
                );
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const AddContactPage())
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  // Widget do Card Visual
  Widget _buildContactCard({
    required String id, 
    required Map<String, dynamic> data, 
    required Color primaryColor, 
    required bool isSystem,
  }) {
    return GestureDetector(
      onTap: () {
        if (isSystem) {
          // BLOQUEIO DE EDIÇÃO: Se for sistema, avisa e não abre a tela de editar
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: const Text('Este contato de emergência oficial não pode ser alterado.'),
              backgroundColor: Colors.grey[800],
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // Se for comum, vai para a tela de editar
          _editContact(id, data);
        }
      },
      child: Card(
        elevation: 2,
        // Cor levemente diferente para contatos do sistema (Visual Hint)
        color: isSystem ? const Color(0xFFFFF8E1) : Colors.white, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Borda dourada se for sistema
          side: isSystem ? BorderSide(color: Colors.amber.shade300, width: 1) : BorderSide.none
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isSystem ? Colors.amber[700] : Colors.amber[100],
                    child: Icon(
                      isSystem ? Icons.security : Icons.person, 
                      color: isSystem ? Colors.white : primaryColor
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['nome'] ?? 'Sem nome',
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.grey[800]
                          ),
                        ),
                        if (data['relacao'] != null && data['relacao'] != '')
                          Text(
                            data['relacao'],
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  
                  // Botão de Ligar (Funciona para todos)
                  IconButton(
                    icon: const Icon(Icons.phone, color: Colors.green),
                    onPressed: () => _fazerLigacao(data['nome'] ?? 'Contato', data['telefone'] ?? ''),
                  ),

                  // Ícone indicativo
                  if (isSystem)
                    const Icon(Icons.lock, color: Colors.grey, size: 20) // Cadeado (Sistema)
                  else
                    const Icon(Icons.edit, color: Colors.amber, size: 20), // Lápis (Usuário)
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(),
              ),
              _buildInfoRow(Icons.phone, data['telefone'] ?? '', primaryColor),
              if (data['endereco'] != null && data['endereco'] != '')
                _buildInfoRow(Icons.location_on, data['endereco'], primaryColor),
              if (data['observacao'] != null && data['observacao'] != '')
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Obs: ${data['observacao']}",
                    style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[600], fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.perm_contact_calendar_outlined, size: 80, color: Colors.amber[200]),
          const SizedBox(height: 16),
          const Text('Sua lista está vazia.', style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }
}
