import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    home: SafetyTipsPage(),
    debugShowCheckedModeBanner: false,
  ));
}

// --- MODELO DE DADOS (OO) ---
class DicaSeguranca {
  final String titulo;
  final String conteudo;
  final IconData icone;
  final Color cor; // Cor semântica
  final String categoria; // "Antes", "Durante", "Depois", "Kit"
  final bool isChecklist; // Se for true, renderiza como lista de tarefas

  DicaSeguranca({
    required this.titulo,
    required this.conteudo,
    required this.icone,
    required this.cor,
    required this.categoria,
    this.isChecklist = false,
  });
}

class SafetyTipsPage extends StatefulWidget {
  const SafetyTipsPage({super.key});

  @override
  State<SafetyTipsPage> createState() => _SafetyTipsPageState();
}

class _SafetyTipsPageState extends State<SafetyTipsPage> {
  // Estado para controlar os filtros e inputs
  String _categoriaSelecionada = "Todos";
  String _textoPesquisa = "";
  final TextEditingController _searchController = TextEditingController();

  // Estado para controlar os itens marcados no Checklist (Kit)
  // Usamos um Set para guardar os nomes dos itens que estão "checked"
  final Set<String> _itensMarcados = {};

  // --- MOCK DATA (Simulando o Banco de Dados) ---
  final List<DicaSeguranca> _dicas = [
    DicaSeguranca(
      titulo: "Água subindo rápido?",
      conteudo: "• Desligue a chave geral de energia.\n• Feche o registro de gás.\n• Separe documentos em sacos plásticos.\n• Não use elevadores.",
      icone: Icons.bolt,
      cor: Colors.redAccent,
      categoria: "Durante",
    ),
    DicaSeguranca(
      titulo: "Kit de Sobrevivência",
      conteudo: "Lanterna com pilhas;Água potável (2L/pessoa);Comida enlatada;Rádio à pilha;Apito (para sinalizar);Kit Primeiros Socorros;Canoa ou bote (se tiver)",
      icone: Icons.medical_services_outlined,
      cor: Colors.teal,
      categoria: "Kit",
      isChecklist: true,
    ),
    DicaSeguranca(
      titulo: "Não ande na enxurrada",
      conteudo: "• Apenas 15cm de água podem te derrubar.\n• A água esconde buracos e bueiros abertos.\n• Risco alto de doenças (Leptospirose).",
      icone: Icons.waves,
      cor: Colors.orange,
      categoria: "Durante",
    ),
    DicaSeguranca(
      titulo: "Prepare sua casa",
      conteudo: "• Limpe calhas e ralos.\n• Identifique o ponto mais alto da casa.\n• Combine um ponto de encontro com a família.",
      icone: Icons.home_work_outlined,
      cor: Colors.blue,
      categoria: "Antes",
    ),
    DicaSeguranca(
      titulo: "Volta pra casa",
      conteudo: "• Cuidado com animais peçonhentos (cobras/aranhas).\n• Não beba água da torneira sem ferver.\n• Descarte alimentos que tocaram na água.",
      icone: Icons.cleaning_services,
      cor: Colors.purple,
      categoria: "Depois",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // LÓGICA DE FILTRAGEM (Pesquisa + Categoria)
    final listaFiltrada = _dicas.where((dica) {
      // 1. Filtra por Categoria
      final matchCategoria = _categoriaSelecionada == "Todos" || dica.categoria == _categoriaSelecionada;
      
      // 2. Filtra por Texto (Título ou Conteúdo)
      final textoBusca = _textoPesquisa.toLowerCase();
      final matchTexto = dica.titulo.toLowerCase().contains(textoBusca) || 
                         dica.conteudo.toLowerCase().contains(textoBusca);

      return matchCategoria && matchTexto;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Dicas de Segurança",
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
            ),
            //Text(
              //"Protocolos de Enchente",
              //style: TextStyle(color: Colors.grey, fontSize: 12), 
            //),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.blueGrey),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // 1. BARRA DE PESQUISA FUNCIONAL
          _buildSearchBar(),

          // 2. FILTRO DE CATEGORIAS
          _buildCategoryFilters(),

          // 3. LISTA DE DICAS
          Expanded(
            child: listaFiltrada.isEmpty 
              ? _buildEmptyState() // Mostra algo se a pesquisa não achar nada
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: listaFiltrada.length,
                  itemBuilder: (context, index) {
                    return _buildSafetyCard(listaFiltrada[index]);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _textoPesquisa = value;
          });
        },
        decoration: InputDecoration(
          hintText: "Buscar dica (ex: água, casa...)",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          // Botão de limpar a pesquisa
          suffixIcon: _textoPesquisa.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _textoPesquisa = "");
                },
              ) 
            : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categorias = ["Todos", "Antes", "Durante", "Depois", "Kit"];
    
    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: categorias.length,
        itemBuilder: (context, index) {
          final cat = categorias[index];
          final isSelected = _categoriaSelecionada == cat;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  _categoriaSelecionada = cat;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF1976D2).withOpacity(0.15),
              checkmarkColor: const Color(0xFF1976D2),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF1976D2) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF1976D2) : Colors.grey[300]!,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSafetyCard(DicaSeguranca dica) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(left: BorderSide.none), 
          ),
          child: ExpansionTile(
            initiallyExpanded: dica.isChecklist, // Já abre o Kit expandido para facilitar
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: dica.cor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(dica.icone, color: dica.cor),
            ),
            title: Text(
              dica.titulo,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              dica.categoria.toUpperCase(),
              style: TextStyle(
                color: dica.cor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: dica.isChecklist 
                  ? _buildChecklistContent(dica.conteudo) 
                  : _buildTextContent(dica.conteudo),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(String texto) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.5),
      ),
    );
  }

  // LOGICA DO CHECKLIST (Funcional)
  Widget _buildChecklistContent(String texto) {
    final itens = texto.split(';');
    
    return Column(
      children: itens.map((item) {
        final isChecked = _itensMarcados.contains(item);

        return CheckboxListTile(
          value: isChecked,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _itensMarcados.add(item);
              } else {
                _itensMarcados.remove(item);
              }
            });
          },
          title: Text(
            item, 
            style: TextStyle(
              fontSize: 14,
              decoration: isChecked ? TextDecoration.lineThrough : null, // Risca o texto se marcar
              color: isChecked ? Colors.grey : Colors.black87,
            )
          ),
          dense: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: Colors.teal,
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 10),
          const Text("Nenhuma dica encontrada", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

















/*
import 'package:flutter/material.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dicas de Segurança')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.tips_and_updates, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              'Como se manter seguro durante enchentes:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
                    title: Text('Evite áreas alagadas.'),
                    subtitle: Text('Mesmo com pouca água, há risco de correnteza e contaminação.'),
                  ),
                  ListTile(
                    leading: Icon(Icons.flash_on, color: Colors.red),
                    title: Text('Desligue aparelhos elétricos.'),
                    subtitle: Text('Evite choques e curtos-circuitos em áreas úmidas.'),
                  ),
                  ListTile(
                    leading: Icon(Icons.clean_hands, color: Colors.blue),
                    title: Text('Evite contato com a água.'),
                    subtitle: Text('Pode estar contaminada com esgoto ou produtos tóxicos.'),
                  ),
                  ListTile(
                    leading: Icon(Icons.backpack, color: Colors.brown),
                    title: Text('Tenha uma mochila de emergência.'),
                    subtitle: Text('Inclua lanterna, documentos, remédios, água e alimentos não perecíveis.'),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone_in_talk, color: Colors.purple),
                    title: Text('Mantenha contato com pessoas próximas.'),
                    subtitle: Text('Avise familiares e amigos sobre sua situação e localização.'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/


//22222222
/*
import 'package:flutter/material.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dicas de Segurança')),
      body: const Center(
        child: Text(
          'Tela: Dicas de Segurança',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
*/