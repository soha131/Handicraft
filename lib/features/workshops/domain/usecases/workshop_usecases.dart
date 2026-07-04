import 'dart:io';
import '../repositories/workshop_repository.dart';
import '../../data/models/workshop_model.dart';

class CreateWorkshopUseCase {
  final WorkshopRepository repository;
  
  CreateWorkshopUseCase(this.repository);
  
  Future<void> call(WorkshopModel workshop, File? imageFile) {
    return repository.createWorkshop(workshop, imageFile);
  }
}

class UpdateWorkshopUseCase {
  final WorkshopRepository repository;
  
  UpdateWorkshopUseCase(this.repository);
  
  Future<void> call(WorkshopModel workshop, File? newImageFile) {
    return repository.updateWorkshop(workshop, newImageFile);
  }
}

class DeleteWorkshopUseCase {
  final WorkshopRepository repository;
  
  DeleteWorkshopUseCase(this.repository);
  
  Future<void> call(String workshopId) {
    return repository.deleteWorkshop(workshopId);
  }
}

class GetOwnerWorkshopsUseCase {
  final WorkshopRepository repository;
  
  GetOwnerWorkshopsUseCase(this.repository);
  
  Stream<List<WorkshopModel>> call(String ownerId) {
    return repository.getOwnerWorkshops(ownerId);
  }
}

class GetAllWorkshopsUseCase {
  final WorkshopRepository repository;
  
  GetAllWorkshopsUseCase(this.repository);
  
  Stream<List<WorkshopModel>> call() {
    return repository.getAllWorkshops();
  }
}
