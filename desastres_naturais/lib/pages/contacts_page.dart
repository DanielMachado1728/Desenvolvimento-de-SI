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

//222222222222
/*
import 'package:flutter/material.dart';
import 'add_contact_page.dart';

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos de Confiança'),
      ),
      body: const Center(
        child: Text('Nenhum contato salvo ainda.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddContactPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Adicionar Contato',
      ),
    );
  }
}
*/
