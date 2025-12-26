import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:url_launcher/url_launcher.dart'; usar no futuro quando launcher estiver ok
// import '../models/contact_model.dart'; // Mantido, mas não necessário neste widget

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  // Método de exclusão agora faz parte do State
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

/*
  // Função para ligar (melhoria de UX)
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^\d]'), ''), // Remove formatação
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // Exibe um erro se não puder ligar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível iniciar a chamada.')),
      );
    }
  }
*/


  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final primaryColor = Theme.of(context).colorScheme.primary;

    if (user == null) {
      return const Center(child: Text('Usuário não autenticado.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contatos de Confiança',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('contatos')
            .orderBy('nome')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar contatos'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final contatos = snapshot.data!.docs;

          if (contatos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_alt_1,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nenhum contato cadastrado ainda.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adicione pessoas para contatá-las rapidamente em caso de emergência.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // A lista de contatos agora usa um Padding para não tocar nas bordas
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: contatos.length,
            itemBuilder: (context, index) {
              final contato = contatos[index];
              final data = contato.data() as Map<String, dynamic>;
              final phoneNumber = data['telefone'] ?? '';

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Dismissible(
                  key: Key(contato.id),
                  direction: DismissDirection.endToStart,
                  // Fundo mais visualmente agradável para exclusão
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Excluir',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.delete_sweep, color: Colors.white),
                      ],
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    // Adiciona uma confirmação (melhoria de UX/segurança)
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirmar Exclusão"),
                          content: Text("Tem certeza que deseja remover ${data['nome'] ?? 'este contato'}?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Excluir", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (_) async {
                    await _deleteContact(contato.id);
                    // Feedback mais claro
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${data['nome'] ?? 'Contato'} excluído com sucesso!')),
                    );
                  },
                  child: Card(
                    elevation: 3, // Adiciona sombra
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nome do Contato em destaque
                          Row(
                            children: [
                              Icon(Icons.person, color: primaryColor, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  data['nome'] ?? 'Sem nome',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              if (phoneNumber.isNotEmpty) 
                                IconButton(
                                  icon: const Icon(Icons.call, color: Colors.grey),
                                  tooltip: 'Ligação temporariamente desativada',
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar( 
                                      const SnackBar(
                                        content: Text(
                                          'Funcionalidade de ligação temporariamente indisponível.',
                                        ),
                                      ),
                                    );
                                  },
                                ),                            
                                
                              /*
                              // Botão de ligar (principal ação de emergência)
                              if (phoneNumber.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.call, color: Colors.green),
                                  onPressed: () => _makePhoneCall(phoneNumber),
                                  tooltip: 'Ligar para ${data['nome']}',
                                ),
                              */

                            ],
                          ),
                          const Divider(height: 16, thickness: 1), // Separador visual
                          
                          // Telefone
                          _buildDetailRow(
                            icon: Icons.phone_android,
                            label: 'Telefone:',
                            value: phoneNumber,
                          ),
                          
                          // Detalhes Opcionais (com verificação de não-vazio)
                          if (data['endereco'] != null && data['endereco'] != '')
                            _buildDetailRow(
                              icon: Icons.house,
                              label: 'Endereço:',
                              value: data['endereco'],
                            ),
                          if (data['relacao'] != null && data['relacao'] != '')
                            _buildDetailRow(
                              icon: Icons.group,
                              label: 'Relação:',
                              value: data['relacao'],
                            ),
                          if (data['observacao'] != null && data['observacao'] != '')
                            _buildDetailRow(
                              icon: Icons.info_outline,
                              label: 'Observação:',
                              value: data['observacao'],
                              isObservation: true,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      // FloatingActionButton aprimorado
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_contact');
        },
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add),
        tooltip: 'Adicionar Contato',
      ),
    );
  }
  
  // Widget helper para criar linhas de detalhe consistentes
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isObservation = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontStyle: isObservation ? FontStyle.italic : FontStyle.normal,
                color: isObservation ? Colors.orange.shade700 : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis, // Evita estouro de texto
              maxLines: isObservation ? 2 : 1,
            ),
          ),
        ],
      ),
    );
  }
}












/////// 2222222
/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contact_model.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Usuário não autenticado.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Contatos de Confiança')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(user.uid)
            .collection('contatos')
            .orderBy('nome')
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar contatos'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final contatos = snapshot.data!.docs;

          if (contatos.isEmpty) {
            return const Center(child: Text('Nenhum contato cadastrado ainda.'));
          }

          return ListView.builder(
            itemCount: contatos.length,
            itemBuilder: (context, index) {
              final contato = contatos[index];
              final data = contato.data() as Map<String, dynamic>;

              return Dismissible(
                key: Key(contato.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await _deleteContact(contato.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contato excluído')),
                  );
                },
                child: ListTile(
                  title: Text(data['nome'] ?? 'Sem nome'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Telefone: ${data['telefone'] ?? '-'}'),
                      if (data['endereco'] != null && data['endereco'] != '')
                        Text('Endereço: ${data['endereco']}'),
                      if (data['relacao'] != null && data['relacao'] != '')
                        Text('Relação: ${data['relacao']}'),
                      if (data['observacao'] != null && data['observacao'] != '')
                        Text('Obs: ${data['observacao']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add_contact');

          //Navigator.push(
          //context,
          //MaterialPageRoute(builder: (context) => const AddContactPage()),
          //);

        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Contato',
      ),
      
    );
  }
}
*/