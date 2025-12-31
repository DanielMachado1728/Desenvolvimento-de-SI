import 'dart:async'; // Adicionado para StreamSubscription
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Adicionado para Auth
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../services/map_marker_service.dart';
import '../models/map_marker_model.dart';

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

  // --- 1. Localização do Usuário ---

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

  
  // --- 2. Ler Relatórios (Seu código original adaptado) ---
  
  void _listenFirestoreMarkers() {
    _markerService.streamMarkers().listen((markersFromFirestore) {
      final novosHazardMarkers = markersFromFirestore.map((marker) {
        return Marker(
          markerId: MarkerId(marker.id),
          position: LatLng(
            marker.localizacao.latitude, 
            marker.localizacao.longitude
          ),
          infoWindow: InfoWindow(
            title: marker.tipo.toUpperCase(), 
            snippet: marker.descricao.isNotEmpty ? marker.descricao : 'Sem descrição',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(marker.tipo),
          ),
        );
      }).toSet();

      // Atualiza apenas a camada de perigos estáticos
      _hazardMarkers = novosHazardMarkers;
      _atualizarMapa();
    });
  }

  // --- 3. (NOVO) Ler Pessoas em Perigo (SOS) ---

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
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet), // VIOLETA!
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

  
  // --- Fluxo de criar alerta (Seu código original mantido) ---

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

  Future<void> _salvarNoFirebase(String tipo, String descricao, LatLng local) async {
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

  // --- UI (Seu código original mantido) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSelectingLocation ? 'Escolha o Local' : 'Mapa'),
        backgroundColor: _isSelectingLocation ? Colors.orange : Colors.white, // Mudei pra branco pra ficar clean
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
        label: Text(_isSelectingLocation ? 'CONFIRMAR AQUI' : 'REPORTAR PERIGO'),
        icon: Icon(_isSelectingLocation ? Icons.check : Icons.add_alert),
        backgroundColor: _isSelectingLocation ? Colors.green : Colors.redAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

// Widget do formulário (Mantido igual, apenas copiando para garantir integridade)
class _FormularioAlerta extends StatefulWidget {
  final LatLng localizacao;
  final Function(String, String, LatLng) onSalvar;

  const _FormularioAlerta({required this.localizacao, required this.onSalvar});

  @override
  State<_FormularioAlerta> createState() => _FormularioAlertaState();
}

class _FormularioAlertaState extends State<_FormularioAlerta> {
  final _descController = TextEditingController();
  String _tipoSelecionado = 'alagamento'; 

  final List<Map<String, dynamic>> _opcoes = [
    {'valor': 'alagamento', 'label': 'Alagamento', 'icon': Icons.water_drop, 'cor': Colors.blue},
    {'valor': 'risco', 'label': 'Risco/Deslizamento', 'icon': Icons.warning, 'cor': Colors.red},
    {'valor': 'abrigo', 'label': 'Abrigo Seguro', 'icon': Icons.home, 'cor': Colors.green},
    {'valor': 'base_apoio', 'label': 'Ponto de Apoio', 'icon': Icons.local_hospital, 'cor': Colors.orange},
  ];

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
            child: const Text("SALVAR ALERTA", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
























































/*
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../services/map_marker_service.dart';
import '../models/map_marker_model.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _initialPosition = LatLng(-8.0476, -34.8770); // Recife

  GoogleMapController? _mapController;
  LatLng? _currentPosition; // Posição do GPS do usuário
  LatLng _cameraCenterPosition = _initialPosition; // Onde a "mira" está apontando

  final Set<Marker> _markers = {};
  final MapMarkerService _markerService = MapMarkerService();
  
  // Controle de Estado da UI
  bool _isSelectingLocation = false; // Se true, mostra a mira no meio

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _listenFirestoreMarkers();
  }


  // Localização e mapa

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
      // Se não estivermos escolhendo local, centraliza no usuário
      if (!_isSelectingLocation) {
        _cameraCenterPosition = _currentPosition!;
      }
    });

    _atualizarMarcadorUsuario();

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition!, 15),
    );
  }

  void _atualizarMarcadorUsuario() {
    if (_currentPosition == null) return;
    
    final currentLocationMarker = Marker(
      markerId: const MarkerId('current_location'),
      position: _currentPosition!,
      infoWindow: const InfoWindow(title: 'Você está aqui'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      zIndex: 2,
    );

    setState(() {
      _markers.removeWhere((m) => m.markerId.value == 'current_location');
      _markers.add(currentLocationMarker);
    });
  }

  
  // Ler do Firebase
  
  void _listenFirestoreMarkers() {
    _markerService.streamMarkers().listen((markersFromFirestore) {
      final firestoreMarkers = markersFromFirestore.map((marker) {
        return Marker(
          markerId: MarkerId(marker.id),
          position: LatLng(
            marker.localizacao.latitude, 
            marker.localizacao.longitude
          ),
          // Janela de info mostra TIPO e DESCRIÇÃO
          infoWindow: InfoWindow(
            title: marker.tipo.toUpperCase(), 
            snippet: marker.descricao.isNotEmpty ? marker.descricao : 'Sem descrição',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(marker.tipo),
          ),
        );
      }).toSet();

      setState(() {
        _markers.removeWhere((m) => m.markerId.value != 'current_location');
        _markers.addAll(firestoreMarkers);
      });
    });
  }

  
  // Fluxo de criar alerta
  

  // Passo A: Ativa o modo de seleção (mira)
  void _iniciarSelecaoLocal() {
    setState(() {
      _isSelectingLocation = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Arraste o mapa para o local do incidente')),
    );
  }

  // Passo B: Usuário confirmou o local, abre o formulário
  void _confirmarLocalEabrirFormulario() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que o teclado empurre o modal
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _FormularioAlerta(
        localizacao: _cameraCenterPosition, // Passa a coordenada da mira
        onSalvar: _salvarNoFirebase,
      ),
    );
  }

  // Passo C: Salvar no Banco de dados
  Future<void> _salvarNoFirebase(String tipo, String descricao, LatLng local) async {
    // 48 horas de duração
    final dataCriacao = DateTime.now();
    final dataExpiracao = dataCriacao.add(const Duration(hours: 48));

    final novoMarcador = MapMarker(
      id: '',
      tipo: tipo,
      descricao: descricao,
      localizacao: GeoPoint(local.latitude, local.longitude),
      criadoEm: dataCriacao,
      expiraEm: dataExpiracao, // logica de 48h
      ativo: true,
      usuarioId: 'usuario_logado_id', // Futuramente virá do Auth???
    );

    try {
      await _markerService.addMarker(novoMarcador);
      
      setState(() {
        _isSelectingLocation = false; // Sai do modo de seleção
      });
      
      if (mounted) {
        Navigator.pop(context); // Fecha o modal
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
        title: Text(_isSelectingLocation ? 'Escolha o Local' : 'Mapa'),
        backgroundColor: _isSelectingLocation ? Colors.orange : Colors.purple,
        leading: _isSelectingLocation 
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() => _isSelectingLocation = false),
            )
          : null,
      ),
      
      // STACK permite colocar a "mira" flutuando sobre o mapa
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
            myLocationButtonEnabled: true, // botão padrão para relinhar/centralizar mapa na minha localização
            zoomControlsEnabled: false,
            
            // ATUALIZA A POSIÇÃO DA MIRA CONFORME O USUÁRIO ARRASTA
            onCameraMove: (position) {
              _cameraCenterPosition = position.target;
            },
          ),
          
          // Mira central (Só aparece se estiver selecionando)
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
                  ), // Sombra/Ponto exato
                  const SizedBox(height: 50), // Offset para o pino ficar na ponta
                ],
              ),
            ),
        ],
      ),

      // Botão de Ação
      floatingActionButton: FloatingActionButton.extended(
        // Se estiver selecionando, o botão é "Confirmar". Se não, é "Novo Alerta"
        onPressed: _isSelectingLocation 
            ? _confirmarLocalEabrirFormulario 
            : _iniciarSelecaoLocal,
        label: Text(_isSelectingLocation ? 'CONFIRMAR AQUI' : 'REPORTAR PERIGO'),
        icon: Icon(_isSelectingLocation ? Icons.check : Icons.add_alert),
        backgroundColor: _isSelectingLocation ? Colors.green : Colors.redAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  double _getMarkerColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'alagamento': return BitmapDescriptor.hueBlue;
      case 'abrigo':     return BitmapDescriptor.hueGreen;
      case 'risco':      return BitmapDescriptor.hueRed;
      case 'base_apoio': return BitmapDescriptor.hueOrange;
      default:           return BitmapDescriptor.hueViolet;
    }
  }
}


// Widget do formulário

class _FormularioAlerta extends StatefulWidget {
  final LatLng localizacao;
  final Function(String, String, LatLng) onSalvar;

  const _FormularioAlerta({required this.localizacao, required this.onSalvar});

  @override
  State<_FormularioAlerta> createState() => _FormularioAlertaState();
}

class _FormularioAlertaState extends State<_FormularioAlerta> {
  final _descController = TextEditingController();
  String _tipoSelecionado = 'alagamento'; // Valor padrão

  final List<Map<String, dynamic>> _opcoes = [
    {'valor': 'alagamento', 'label': 'Alagamento', 'icon': Icons.water_drop, 'cor': Colors.blue},
    {'valor': 'risco', 'label': 'Risco/Deslizamento', 'icon': Icons.warning, 'cor': Colors.red},
    {'valor': 'abrigo', 'label': 'Abrigo Seguro', 'icon': Icons.home, 'cor': Colors.green},
    {'valor': 'base_apoio', 'label': 'Ponto de Apoio', 'icon': Icons.local_hospital, 'cor': Colors.orange},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Padding para o teclado não cobrir
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
            textAlign: TextAlign.center, // erro corrigido
          ),
          const SizedBox(height: 20),
          
          // Seletor de tipo
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

          // Campo de descrição
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

          // botão salvar
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
            child: const Text("SALVAR ALERTA", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

*/
















