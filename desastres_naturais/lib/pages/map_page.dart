import 'dart:async'; // Adicionado para StreamSubscription
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../services/map_marker_service.dart';
import '../models/map_marker_model.dart';

import 'dart:io'; 
import 'package:image_picker/image_picker.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _initialPosition = LatLng(-8.0476, -34.8770); // Recife

  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  LatLng _cameraCenterPosition = _initialPosition;

  // --- MUDANÇA AQUI: Gerenciamento de Marcadores em Camadas ---
  final Set<Marker> _markers = {}; // O conjunto final que vai pro mapa
  
  Marker? _myLocationMarker;           // Camada 1: Eu
  Set<Marker> _hazardMarkers = {};     // Camada 2: Alagamentos/Riscos
  Set<Marker> _dangerMarkers = {};     // Camada 3: Pessoas em Perigo (NOVO)

  final MapMarkerService _markerService = MapMarkerService();
  StreamSubscription? _usersSubscription; // Para ouvir o perigo (NOVO)
  
  bool _isSelectingLocation = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _listenFirestoreMarkers(); // Escuta os relatórios (Alagamento, etc)
    _monitorarEmergencias();   // Escuta as pessoas (NOVO)
  }

  @override
  void dispose() {
    _usersSubscription?.cancel(); // Cancelar a escuta ao sair
    super.dispose();
  }

  // Função auxiliar para juntar todas as camadas e atualizar a tela
  void _atualizarMapa() {
    setState(() {
      _markers.clear();
      if (_myLocationMarker != null) _markers.add(_myLocationMarker!);
      _markers.addAll(_hazardMarkers);
      _markers.addAll(_dangerMarkers);
    });
  }

  // Localização do Usuário

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      if (!_isSelectingLocation) {
        _cameraCenterPosition = _currentPosition!;
      }
    });

    _criarMarcadorUsuario(); // Função renomeada levemente para clareza

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 15),
    );
  }

  void _criarMarcadorUsuario() {
    if (_currentPosition == null) return;
    
    // Atualiza a variavel isolada
    _myLocationMarker = Marker(
      markerId: const MarkerId('current_location'),
      position: _currentPosition!,
      infoWindow: const InfoWindow(title: 'Você está aqui'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      zIndex: 2,
    );

    _atualizarMapa(); // Reconstrói o set final
  }

  
  // Ler Relatórios
  
  void _listenFirestoreMarkers() {
    _markerService.streamMarkers().listen((markersFromFirestore) {
      final user = FirebaseAuth.instance.currentUser; // adicionado
      final novosHazardMarkers = markersFromFirestore.map((marker) {
        final bool souDono = user != null && marker.usuarioId == user.uid; //adicionado
        return Marker(
          markerId: MarkerId(marker.id),
          position: LatLng(
            marker.localizacao.latitude, 
            marker.localizacao.longitude
          ),
          infoWindow: InfoWindow(
            title: marker.tipo.toUpperCase(),
            snippet: souDono ? '(Toque para editar) ${marker.descricao}' : marker.descricao,
            //snippet: marker.descricao.isNotEmpty ? marker.descricao : 'Sem descrição', codigo antigo
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(marker.tipo),
          ),
          onTap: () {
            _mostrarDetalhesDoMarcador(marker); // mostra detalhes para todos agora
            //if (souDono) {
              //mostrarOpcoesDoMarcador(marker);      // Nova função
              //}
            },
        );
      }).toSet();

      // Atualiza apenas a camada de perigos estáticos
      _hazardMarkers = novosHazardMarkers;
      _atualizarMapa();
    });
  }


  // Função que abre o painel para ver a foto e detalhes (e opções se for dono)
  void _mostrarDetalhesDoMarcador(MapMarker marker) {
    final user = FirebaseAuth.instance.currentUser;
    final bool souDono = user != null && marker.usuarioId == user.uid;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white, // Mantendo a estética limpa
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView( // Para não dar erro de espaço na tela
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Título
                Text(
                  marker.tipo.toUpperCase(), 
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),

                // A MÁGICA AQUI: Exibir a foto vinda do Supabase
                if (marker.fotoUrl != null && marker.fotoUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      marker.fotoUrl!,
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.blueAccent)
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const SizedBox(
                        height: 100, 
                        child: Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey))
                      ),
                    ),
                  ),
                
                const SizedBox(height: 15),

                // Descrição em caixa cinza claro
                if (marker.descricao.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      marker.descricao,
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Botões de Gerenciar (Aparece SOMENTE para o dono)
                if (souDono) ...[
                  const Divider(),
                  const Text("Gerenciar Alerta", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.edit, color: Colors.blueAccent),
                    title: const Text("Editar Informações", style: TextStyle(color: Colors.black87)),
                    onTap: () {
                      Navigator.pop(context); 
                      _abrirEdicao(marker);  
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete, color: Colors.redAccent),
                    title: const Text("Remover Alerta", style: TextStyle(color: Colors.black87)),
                    onTap: () async {
                      Navigator.pop(context); 
                      await _markerService.deactivateMarker(marker.id);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Alerta removido do mapa.")),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }



  // Função que abre o menu de Gerenciar Alerta (Editar/Excluir)
  // Função usada antes do supabase


/*
  void _mostrarOpcoesDoMarcador(MapMarker marker) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Gerenciar: ${marker.tipo.toUpperCase()}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              // Botão Editar
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Editar Informações"),
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  _abrirEdicao(marker);   // Abre o formulário
                },
              ),
              
              // Botão Excluir (Desativar)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Remover Alerta"),
                onTap: () async {
                  Navigator.pop(context); // Fecha o menu
                  await _markerService.deactivateMarker(marker.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Alerta removido do mapa.")),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
*/

  // Função que abre o formulário preenchido
  void _abrirEdicao(MapMarker marker) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => _FormularioAlerta(
        localizacao: LatLng(marker.localizacao.latitude, marker.localizacao.longitude),
        tipoInicial: marker.tipo,           // Passa dados atuais
        descricaoInicial: marker.descricao, // Passa dados atuais
        isEditing: true,                    // Avisa que é edição
        onSalvar: (novoTipo, novaDesc, _, imageUrl) async {
          // Chama o update no service
          await _markerService.updateMarker(marker.id, novoTipo, novaDesc);
          if (mounted) {
            Navigator.pop(context); // Fecha o form
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Alerta atualizado!")),
            );
          }
        },
      ),
    );
  }




  // Ler Pessoas em Perigo (SOS) 

  void _monitorarEmergencias() {
    final userLogado = FirebaseAuth.instance.currentUser;

    _usersSubscription = FirebaseFirestore.instance
        .collection('usuarios')
        .snapshots()
        .listen((snapshot) {
      
      Set<Marker> novosPinosDePerigo = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Verifica se tem GPS e Flag de Perigo
        if (data.containsKey('latitude') && data.containsKey('longitude')) {
          final bool emPerigo = data['em_perigo'] == true;
          
          // Opcional: Filtro de tempo (ex: só mostra alertas da última 1 hora)
          bool alertaRecente = true;
          if (data['inicio_perigo'] != null) {
            final Timestamp ts = data['inicio_perigo'];
            final diferenca = DateTime.now().difference(ts.toDate());
            if (diferenca.inMinutes > 60) alertaRecente = false; 
          }

          if (emPerigo && alertaRecente) {
            final double lat = data['latitude'];
            final double lng = data['longitude'];
            final String nome = data['nome'] ?? 'Usuário';
            final String uid = data['uid'] ?? doc.id;
            
            // Não mostramos a nós mesmos como perigo violeta (já temos a bolinha azul)
            // Mas se quiser ver seu próprio pino violeta para teste, remova a checagem do uid
            if (userLogado != null && uid != userLogado.uid) {
               final marker = Marker(
                markerId: MarkerId('SOS_$uid'), // Prefixo SOS para não confundir ID
                position: LatLng(lat, lng),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet), 
                zIndex: 3, // Fica por cima de tudo
                infoWindow: InfoWindow(
                  title: 'PEDIDO DE SOCORRO',
                  snippet: '$nome precisa de ajuda!',
                ),
              );
              novosPinosDePerigo.add(marker);
            }
          }
        }
      }

      // Atualiza a camada de pessoas
      _dangerMarkers = novosPinosDePerigo;
      _atualizarMapa();
    });
  }

  
  // --- Fluxo de criar alerta (código original mantido) ---

  void _iniciarSelecaoLocal() {
    setState(() {
      _isSelectingLocation = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Arraste o mapa para o local do incidente')),
    );
  }

  void _confirmarLocalEabrirFormulario() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FormularioAlerta(
        localizacao: _cameraCenterPosition, 
        onSalvar: _salvarNoFirebase,
      ),
    );
  }

  Future<void> _salvarNoFirebase(String tipo, String descricao, LatLng local, String? imageUrl) async {
    final dataCriacao = DateTime.now();
    final dataExpiracao = dataCriacao.add(const Duration(hours: 48));
    final user = FirebaseAuth.instance.currentUser; // Pegando usuário real

    final novoMarcador = MapMarker(
      id: '',
      tipo: tipo,
      descricao: descricao,
      localizacao: GeoPoint(local.latitude, local.longitude),
      criadoEm: dataCriacao,
      expiraEm: dataExpiracao, 
      ativo: true,
      usuarioId: user?.uid ?? 'anonimo',
      fotoUrl: imageUrl,
    );

    try {
      await _markerService.addMarker(novoMarcador);
      
      setState(() {
        _isSelectingLocation = false; 
      });
      
      if (mounted) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerta criado com sucesso! Duração: 48h'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar.'), backgroundColor: Colors.red),
      );
    }
  }

  // UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mapa',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87), // seta para voltar 
      ),
      
      
      /*
      appBar: AppBar(
        title: Text(_isSelectingLocation ? 'Escolha o Local' : 'Mapa'),
        backgroundColor: _isSelectingLocation ? Colors.orange : Colors.white, 
        elevation: 0,
        titleTextStyle: TextStyle(
            color: _isSelectingLocation ? Colors.white : Colors.black87, 
            fontWeight: FontWeight.bold, fontSize: 20
        ),
        iconTheme: IconThemeData(color: _isSelectingLocation ? Colors.white : Colors.black87),
        leading: _isSelectingLocation 
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isSelectingLocation = false),
            )
          : null,
      ),
      */

      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true, 
            zoomControlsEnabled: false,
            
            onCameraMove: (position) {
              _cameraCenterPosition = position.target;
            },
          ),
          
          if (_isSelectingLocation)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 50, color: Colors.red),
                  Container(
                    width: 10, 
                    height: 10, 
                    decoration: const BoxDecoration(
                      color: Colors.black, 
                      shape: BoxShape.circle
                    ),
                  ), 
                  const SizedBox(height: 50), 
                ],
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSelectingLocation 
            ? _confirmarLocalEabrirFormulario 
            : _iniciarSelecaoLocal,
        // 1. Aumentamos a letra, deixamos em negrito e com bom espaçamento
        label: Text(
          _isSelectingLocation ? 'CONFIRMAR AQUI' : 'COMPARTILHAR EVENTO',
          style: const TextStyle(
            fontSize: 20, // <-- Tamanho da fonte maior
            fontWeight: FontWeight.bold, // <-- Letra mais grossa para leitura rápida
            letterSpacing: 1.1,
            color: Colors.white, // <-- Garante contraste perfeito
          ),
        ),
        // 2. Aumentamos o ícone para ficar proporcional ao texto
        icon: Icon(
          _isSelectingLocation ? Icons.check : Icons.add_alert,
          size: 28, // <-- Ícone maior
          color: Colors.white,
        ),
        backgroundColor: _isSelectingLocation ? Colors.green : Colors.redAccent,
        elevation: 6, // <-- Sombra um pouco maior para o botão "saltar" na tela
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,


      /*
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSelectingLocation 
            ? _confirmarLocalEabrirFormulario 
            : _iniciarSelecaoLocal,
        label: Text(_isSelectingLocation ? 'CONFIRMAR AQUI' : 'COMPARTILHAR EVENTO'),
        icon: Icon(_isSelectingLocation ? Icons.check : Icons.add_alert),
        backgroundColor: _isSelectingLocation ? Colors.green : Colors.redAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      */



    );
  }
      

  double _getMarkerColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'alagamento': return BitmapDescriptor.hueBlue;
      case 'abrigo':     return BitmapDescriptor.hueGreen;
      case 'risco':      return BitmapDescriptor.hueRed;
      case 'base_apoio': return BitmapDescriptor.hueOrange;
      default:           return BitmapDescriptor.hueMagenta; // Cor padrão caso não ache
    }
  }
}

// Widget do formulário 
class _FormularioAlerta extends StatefulWidget {
  final LatLng localizacao;
  // final Function(String, String, LatLng) onSalvar;
  final Function(String, String, LatLng, String?) onSalvar; // String? foi adicionado no final

  final String? tipoInicial;
  final String? descricaoInicial;
  final bool isEditing;

  const _FormularioAlerta({
    required this.localizacao, 
    required this.onSalvar,
    this.tipoInicial,
    this.descricaoInicial,
    this.isEditing = false,
  });

  //const _FormularioAlerta({required this.localizacao, required this.onSalvar}); do código antigo

  @override
  State<_FormularioAlerta> createState() => _FormularioAlertaState();
}

class _FormularioAlertaState extends State<_FormularioAlerta> {
  final _descController = TextEditingController();
  File? _imagemSelecionada;
  bool _isLoading = false;
  //String _tipoSelecionado = 'alagamento'; codigo antigo


  String _tipoSelecionado = 'alagamento'; 

  @override
  void initState() {
    super.initState();
    if (widget.tipoInicial != null) {
      _tipoSelecionado = widget.tipoInicial!;
    }
    if (widget.descricaoInicial != null) {
      _descController.text = widget.descricaoInicial!;
    }
  } 

  final List<Map<String, dynamic>> _opcoes = [
    {'valor': 'alagamento', 'label': 'Alagamento', 'icon': Icons.water_drop, 'cor': Colors.blue},
    {'valor': 'risco', 'label': 'Risco/Deslizamento', 'icon': Icons.warning, 'cor': Colors.red},
    {'valor': 'abrigo', 'label': 'Abrigo Seguro', 'icon': Icons.home, 'cor': Colors.green},
    {'valor': 'base_apoio', 'label': 'Ponto de Apoio', 'icon': Icons.local_hospital, 'cor': Colors.orange},
  ];

  Future<void> _tirarFoto() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
    if (foto != null) setState(() => _imagemSelecionada = File(foto.path));
  }

//PARTE ANTIGA
/*
  Future<String?> _fazerUpload() async {
  if (_imagemSelecionada == null) return null;
  final nomeArquivo = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  
  await Supabase.instance.client.storage
      .from('fotos_alertas')
      .uploadBinary(nomeArquivo, await _imagemSelecionada!.readAsBytes());
      
  return Supabase.instance.client.storage.from('fotos_alertas').getPublicUrl(nomeArquivo);
}
*/

Future<String?> _fazerUpload() async {
    if (_imagemSelecionada == null) return null;
    
    try {
      print('1. Iniciando processo de upload...');
      final nomeArquivo = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      print('2. Lendo a imagem como bytes...');
      final bytes = await _imagemSelecionada!.readAsBytes();
      
      print('3. Enviando para o Supabase...');
      await Supabase.instance.client.storage
          .from('fotos_alertas')
          .uploadBinary(nomeArquivo, bytes);
          
      print('4. Pegando o link público...');
      final link = Supabase.instance.client.storage.from('fotos_alertas').getPublicUrl(nomeArquivo);
      
      print('5. Sucesso! Link gerado: $link');
      return link;
      
    } catch (e) {
      print('ERRO CAPTURADO NO TRY/CATCH: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no Supabase: $e'), backgroundColor: Colors.red),
        );
      }
      return null;
    }
  }




  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Detalhes do Alerta",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _opcoes.length,
              itemBuilder: (context, index) {
                final item = _opcoes[index];
                final isSelected = _tipoSelecionado == item['valor'];
                
                return GestureDetector(
                  onTap: () => setState(() => _tipoSelecionado = item['valor']),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 80,
                    decoration: BoxDecoration(
                      color: isSelected ? item['cor'].withOpacity(0.2) : Colors.grey[100],
                      border: Border.all(
                        color: isSelected ? item['cor'] : Colors.transparent, 
                        width: 2
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item['icon'], color: item['cor']),
                        const SizedBox(height: 5),
                        Text(
                          item['label'], 
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Descrição (Opcional)',
              hintText: 'Ex: Água na altura do joelho...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 20),


          // codigo novo da camera
          if (!widget.isEditing) 
            InkWell(
              onTap: _tirarFoto,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _imagemSelecionada == null ? Icons.camera_alt : Icons.check_circle, 
                      color: Colors.blueAccent
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _imagemSelecionada == null ? "Anexar Foto do Local" : "Foto Anexada (Toque para trocar)",
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            
          if (_imagemSelecionada != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(_imagemSelecionada!, height: 120, fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: 20),
          // novo até aqui



          ElevatedButton(
            onPressed: _isLoading 
                ? null 
                : () async {
                    setState(() => _isLoading = true); // Mostra o carregando
                    
                    // Sobe a foto e pega o link
                    String? linkDaFoto = await _fazerUpload(); 
                    
                    // Chama a função principal passando o link da foto junto
                    widget.onSalvar(
                      _tipoSelecionado, 
                      _descController.text, 
                      widget.localizacao,
                      linkDaFoto
                    );
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: _isLoading 
                ? const SizedBox(
                    height: 20, 
                    width: 20, 
                    child: CircularProgressIndicator(strokeWidth: 2)
                  )
                : Text(
                    widget.isEditing ? "ATUALIZAR ALERTA" : "SALVAR ALERTA", 
                    style: const TextStyle(fontSize: 16)
                  ),
          ),
/* antigo antes das fotos
          ElevatedButton(
            onPressed: () {
              widget.onSalvar(
                _tipoSelecionado, 
                _descController.text, 
                widget.localizacao
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            //child: const Text("SALVAR ALERTA", style: TextStyle(fontSize: 16)), codigo antigo
            
            child: Text(widget.isEditing ? "ATUALIZAR ALERTA" : "SALVAR ALERTA", style: const TextStyle(fontSize: 16)),

          ),
*/



          const SizedBox(height: 20),
        ],
      ),
    );
  }
}


