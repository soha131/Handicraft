import 'dart:io';
import '../../data/models/workshop_model.dart';

abstract class WorkshopRepository {
  Future<void> createWorkshop(WorkshopModel workshop, File? imageFile);
  Future<void> updateWorkshop(WorkshopModel workshop, File? newImageFile);
  Future<void> deleteWorkshop(String workshopId);
  Stream<List<WorkshopModel>> getOwnerWorkshops(String ownerId);
  Stream<List<WorkshopModel>> getAllWorkshops();
}
