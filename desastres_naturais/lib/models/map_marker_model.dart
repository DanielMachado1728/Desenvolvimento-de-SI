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























