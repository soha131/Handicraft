import 'dart:io';
import 'package:uuid/uuid.dart';

import '../models/workshop_model.dart';
import '../../domain/repositories/workshop_repository.dart';
import '../datasources/workshop_remote_data_source.dart';

class WorkshopRepositoryImpl implements WorkshopRepository {
  final WorkshopRemoteDataSource remoteDataSource;
  final Uuid _uuid = const Uuid();

  // In-memory fallback for dev mode when Firebase is not connected
  final List<WorkshopModel> _devWorkshops = [];

  WorkshopRepositoryImpl({required this.remoteDataSource});

  bool _isFirebaseConfigError(Object e) {
    final msg = e.toString();
    return msg.contains('no-app') ||
        msg.contains('core/') ||
        msg.contains('FirebaseException') ||
        msg.contains('cloud_firestore');
  }

  @override
  Future<void> createWorkshop(WorkshopModel workshop, File? imageFile) async {
    try {
      final docId = _uuid.v4();
      String? imageUrl = workshop.imageUrl;

      if (imageFile != null) {
        imageUrl = await remoteDataSource.uploadWorkshopImage(docId, imageFile);
      }

      final newWorkshop = workshop.copyWith(id: docId, imageUrl: imageUrl);
      await remoteDataSource.createWorkshop(newWorkshop.toMap(), docId);
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        // Fallback for Development mode
        final docId = _uuid.v4();
        _devWorkshops.add(workshop.copyWith(id: docId));
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> updateWorkshop(WorkshopModel workshop, File? newImageFile) async {
    try {
      String? imageUrl = workshop.imageUrl;

      if (newImageFile != null) {
        imageUrl = await remoteDataSource.uploadWorkshopImage(workshop.id, newImageFile);
      }

      final updatedWorkshop = workshop.copyWith(imageUrl: imageUrl);
      await remoteDataSource.updateWorkshop(updatedWorkshop.id, updatedWorkshop.toMap());
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        final index = _devWorkshops.indexWhere((w) => w.id == workshop.id);
        if (index != -1) {
          _devWorkshops[index] = workshop;
        }
        return;
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteWorkshop(String workshopId) async {
    try {
      await remoteDataSource.deleteWorkshop(workshopId);
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        _devWorkshops.removeWhere((w) => w.id == workshopId);
        return;
      }
      rethrow;
    }
  }

  @override
  Stream<List<WorkshopModel>> getOwnerWorkshops(String ownerId) {
    try {
      return remoteDataSource.getWorkshopsByOwner(ownerId).map((list) {
        return list.map((map) => WorkshopModel.fromMap(map, map['id'] as String)).toList();
      }).handleError((e) {
        if (_isFirebaseConfigError(e)) {
          // Fallback stream if failed in catch early
          return Stream.value(_devWorkshops.where((w) => w.ownerId == ownerId).toList());
        }
        throw e;
      });
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        return Stream.value(_devWorkshops.where((w) => w.ownerId == ownerId).toList());
      }
      rethrow;
    }
  }

  @override
  Stream<List<WorkshopModel>> getAllWorkshops() {
    try {
      return remoteDataSource.getAllWorkshops().map((list) {
        return list.map((map) => WorkshopModel.fromMap(map, map['id'] as String)).toList();
      }).handleError((e) {
        if (_isFirebaseConfigError(e)) {
          return Stream.value(_devWorkshops);
        }
        throw e;
      });
    } catch (e) {
      if (_isFirebaseConfigError(e)) {
        return Stream.value(_devWorkshops);
      }
      rethrow;
    }
  }
}
