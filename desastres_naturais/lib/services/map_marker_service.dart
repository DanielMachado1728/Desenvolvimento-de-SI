import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/map_marker_model.dart';
import '../models/users_model.dart'; // <-- Importando o seu novo modelo de usuário

class MapMarkerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // referência da coleção
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('marcadores');

  // buscar todos os marcadores ativos
  Future<List<MapMarker>> getMarkers() async {
    final querySnapshot = await _collection
        .where('ativo', isEqualTo: true)
        .get();

    return querySnapshot.docs.map((doc) {
      // 1. Lemos os dados brutos do Firebase
      final data = doc.data();
      final String usuarioId = data['usuarioId'] ?? 'anonimo';
      
      // 2. Criamos o objeto Usuario para respeitar a Composição de OO exigida pelo professor
      final autorDoAlerta = Usuario(
        id: usuarioId,
        nome: 'Usuário', // Como o Firebase não tem o nome aqui, preenchemos o objeto com dados padrão
        email: '',
      );

      // 3. Montamos o Marcador completo passando o documento e o objeto Usuario
      return MapMarker.fromFirestore(doc, autorDoAlerta);
    }).toList();
  }

  // escutar marcadores em tempo real (ideal para mapa)
  Stream<List<MapMarker>> streamMarkers() {
    return _collection
        .where('ativo', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            
            // Repetimos a mesma lógica de Composição OO para o fluxo em tempo real
            final data = doc.data();
            final String usuarioId = data['usuarioId'] ?? 'anonimo';
            
            final autorDoAlerta = Usuario(
              id: usuarioId,
              nome: 'Usuário', 
              email: '',
            );

            return MapMarker.fromFirestore(doc, autorDoAlerta);
            
          }).toList(),
        );
  }

  // criar novo marcador
  Future<void> addMarker(MapMarker marker) async {
    await _collection.add(marker.toFirestore());
  }

  // desativar marcador (em vez de deletar)
  Future<void> deactivateMarker(String markerId) async {
    await _collection.doc(markerId).update({
      'ativo': false,
    });
  }

  // Atualizar tipo e descrição de um marcador existente
  Future<void> updateMarker(String markerId, String newType, String newDesc) async {
    await _collection.doc(markerId).update({
      'tipo': newType,
      'descricao': newDesc,
      // Não atualizamos localização nem 'criadoEm' para manter histórico
    });
  }
}











/*
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/map_marker_model.dart';


class MapMarkerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // referência da coleção
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('marcadores');

  // buscar todos os marcadores ativos
  Future<List<MapMarker>> getMarkers() async {
    final querySnapshot = await _collection
        .where('ativo', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => MapMarker.fromFirestore(doc))
        .toList();
  }

  // escutar marcadores em tempo real (ideal para mapa)
  Stream<List<MapMarker>> streamMarkers() {
    return _collection
        .where('ativo', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MapMarker.fromFirestore(doc))
              .toList(),
        );
  }

  // criar novo marcador
  Future<void> addMarker(MapMarker marker) async {
    await _collection.add(marker.toFirestore());
  }

  // desativar marcador (em vez de deletar)
  Future<void> deactivateMarker(String markerId) async {
    await _collection.doc(markerId).update({
      'ativo': false,
    });
  }


  // Atualizar tipo e descrição de um marcador existente
  Future<void> updateMarker(String markerId, String newType, String newDesc) async {
    await _collection.doc(markerId).update({
      'tipo': newType,
      'descricao': newDesc,
      // Não atualizamos localização nem 'criadoEm' para manter histórico
    });
  }
}
*/



















































//tudo funcionando
/*
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/map_marker_model.dart';


class MapMarkerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // referência da coleção
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('marcadores');

  // buscar todos os marcadores ativos
  Future<List<MapMarker>> getMarkers() async {
    final querySnapshot = await _collection
        .where('ativo', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => MapMarker.fromFirestore(doc))
        .toList();
  }

  // escutar marcadores em tempo real (ideal para mapa)
  Stream<List<MapMarker>> streamMarkers() {
    return _collection
        .where('ativo', isEqualTo: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MapMarker.fromFirestore(doc))
              .toList(),
        );
  }

  // criar novo marcador
  Future<void> addMarker(MapMarker marker) async {
    await _collection.add(marker.toFirestore());
  }

  // desativar marcador (em vez de deletar)
  Future<void> deactivateMarker(String markerId) async {
    await _collection.doc(markerId).update({
      'ativo': false,
    });
  }
}
*/