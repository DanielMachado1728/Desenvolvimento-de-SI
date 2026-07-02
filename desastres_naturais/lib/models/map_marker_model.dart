import 'package:cloud_firestore/cloud_firestore.dart';
import 'users_model.dart'; 

class MapMarker {
  final String id;
  final String tipo; 
  final String descricao; 
  final GeoPoint localizacao;
  final DateTime criadoEm;
  final DateTime? expiraEm;
  final bool ativo;
  final String? fotoUrl;
  
  // AQUI ESTÁ A COMPOSIÇÃO DE OO: O Marcador TEM UM Usuário
  final Usuario autor; 

  MapMarker({
    required this.id,
    required this.tipo,
    required this.descricao, 
    required this.localizacao,
    required this.criadoEm,
    this.expiraEm,
    required this.ativo,
    this.fotoUrl,
    required this.autor, // Substituiu o usuarioId
  });

  // O factory agora recebe o DocumentSnapshot E o objeto Usuario correspondente
  factory MapMarker.fromFirestore(DocumentSnapshot doc, Usuario autorDoAlerta) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return MapMarker(
      id: doc.id,
      tipo: data['tipo'] ?? 'risco',
      descricao: data['descricao'] ?? '', 
      
      localizacao: data['localizacao'] is GeoPoint 
          ? data['localizacao'] 
          : const GeoPoint(0, 0),
      
      criadoEm: data['criadoEm'] is Timestamp 
          ? (data['criadoEm'] as Timestamp).toDate() 
          : DateTime.now(),
          
      expiraEm: data['expiraEm'] is Timestamp 
          ? (data['expiraEm'] as Timestamp).toDate() 
          : null,
          
      ativo: data['ativo'] ?? true,
      fotoUrl: data['fotoUrl'],
      autor: autorDoAlerta, // Atribuindo o objeto completo
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tipo': tipo,
      'descricao': descricao,
      'localizacao': localizacao,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'expiraEm': expiraEm != null ? Timestamp.fromDate(expiraEm!) : null,
      'ativo': ativo,
      'fotoUrl': fotoUrl,
      // Ao salvar no banco, mandamos apenas o ID para economizar espaço e manter o padrão NoSQL, 
      // mas na memória do celular, mantemos o objeto completo!
      'usuarioId': autor.id, 
    };
  }
}
















/*
import 'package:cloud_firestore/cloud_firestore.dart';

class MapMarker {
  final String id;
  final String tipo; 
  final String descricao; 
  final GeoPoint localizacao;
  final DateTime criadoEm;
  final DateTime? expiraEm;
  final bool ativo;
  final String usuarioId;
  final String? fotoUrl;

  MapMarker({
    required this.id,
    required this.tipo,
    required this.descricao, 
    required this.localizacao,
    required this.criadoEm,
    this.expiraEm,
    required this.ativo,
    required this.usuarioId,
    this.fotoUrl,
  });

  factory MapMarker.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return MapMarker(
      id: doc.id,
      tipo: data['tipo'] ?? 'risco',
      descricao: data['descricao'] ?? '', // Proteção contra null
      
      localizacao: data['localizacao'] is GeoPoint 
          ? data['localizacao'] 
          : const GeoPoint(0, 0),
      
      criadoEm: data['criadoEm'] is Timestamp 
          ? (data['criadoEm'] as Timestamp).toDate() 
          : DateTime.now(),
          
      expiraEm: data['expiraEm'] is Timestamp 
          ? (data['expiraEm'] as Timestamp).toDate() 
          : null,
          
      ativo: data['ativo'] ?? true,
      usuarioId: data['usuarioId'] ?? 'anonimo',
      fotoUrl: data['fotoUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tipo': tipo,
      'descricao': descricao, // <--- NOVO
      'localizacao': localizacao,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'expiraEm': expiraEm != null ? Timestamp.fromDate(expiraEm!) : null,
      'ativo': ativo,
      'usuarioId': usuarioId,
      'fotoUrl': fotoUrl,
    };
  }
}
*/














































































//Tudo funcionando
/*
import 'package:cloud_firestore/cloud_firestore.dart';

class MapMarker {
  final String id;
  final String tipo; 
  final String descricao; 
  final GeoPoint localizacao;
  final DateTime criadoEm;
  final DateTime? expiraEm;
  final bool ativo;
  final String usuarioId;

  MapMarker({
    required this.id,
    required this.tipo,
    required this.descricao, 
    required this.localizacao,
    required this.criadoEm,
    this.expiraEm,
    required this.ativo,
    required this.usuarioId,
  });

  factory MapMarker.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return MapMarker(
      id: doc.id,
      tipo: data['tipo'] ?? 'risco',
      descricao: data['descricao'] ?? '', // Proteção contra null
      
      localizacao: data['localizacao'] is GeoPoint 
          ? data['localizacao'] 
          : const GeoPoint(0, 0),
      
      criadoEm: data['criadoEm'] is Timestamp 
          ? (data['criadoEm'] as Timestamp).toDate() 
          : DateTime.now(),
          
      expiraEm: data['expiraEm'] is Timestamp 
          ? (data['expiraEm'] as Timestamp).toDate() 
          : null,
          
      ativo: data['ativo'] ?? true,
      usuarioId: data['usuarioId'] ?? 'anonimo',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'tipo': tipo,
      'descricao': descricao, // <--- NOVO
      'localizacao': localizacao,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'expiraEm': expiraEm != null ? Timestamp.fromDate(expiraEm!) : null,
      'ativo': ativo,
      'usuarioId': usuarioId,
    };
  }
}
*/























