import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/workshop_model.dart';
import '../../domain/usecases/workshop_usecases.dart';
import 'workshop_state.dart';

class WorkshopCubit extends Cubit<WorkshopState> {
  final CreateWorkshopUseCase createUseCase;
  final UpdateWorkshopUseCase updateUseCase;
  final DeleteWorkshopUseCase deleteUseCase;
  final GetOwnerWorkshopsUseCase getOwnerWorkshopsUseCase;
  final GetAllWorkshopsUseCase getAllWorkshopsUseCase;

  StreamSubscription? _workshopsSubscription;
  List<WorkshopModel> _cachedWorkshops = [];

  WorkshopCubit({
    required this.createUseCase,
    required this.updateUseCase,
    required this.deleteUseCase,
    required this.getOwnerWorkshopsUseCase,
    required this.getAllWorkshopsUseCase,
  }) : super(WorkshopInitial());

  void loadOwnerWorkshops(String ownerId) {
    emit(WorkshopLoading());
    _workshopsSubscription?.cancel();
    _workshopsSubscription = getOwnerWorkshopsUseCase(ownerId).listen(
      (workshops) {
        _cachedWorkshops = workshops;
        emit(WorkshopLoaded(workshops));
      },
      onError: (error) {
        emit(WorkshopError(_cleanErrorMessage(error.toString())));
      },
    );
  }

  void loadAllWorkshops() {
    emit(WorkshopLoading());
    _workshopsSubscription?.cancel();
    _workshopsSubscription = getAllWorkshopsUseCase().listen(
      (workshops) {
        _cachedWorkshops = workshops;
        emit(WorkshopLoaded(workshops));
      },
      onError: (error) {
        emit(WorkshopError(_cleanErrorMessage(error.toString())));
      },
    );
  }

  void filterWorkshops({
    required String query,
    required String category,
    required String format,
    required double maxPrice,
  }) {
    final filteredList = _cachedWorkshops.where((w) {
      final matchesQuery = query.isEmpty ||
          w.title.toLowerCase().contains(query.toLowerCase()) ||
          w.description.toLowerCase().contains(query.toLowerCase()) ||
          (w.location != null && w.location!.toLowerCase().contains(query.toLowerCase()));
      
      final matchesCategory = category == 'All' || w.category.toLowerCase() == category.toLowerCase();
      
      final matchesFormat = format == 'All' ||
          (format == 'Online' && w.isOnline) ||
          (format == 'In-person' && !w.isOnline);
      
      final matchesPrice = w.price <= maxPrice;
      
      return matchesQuery && matchesCategory && matchesFormat && matchesPrice;
    }).toList();

    emit(WorkshopLoaded(filteredList));
  }

  Future<void> createWorkshop(WorkshopModel workshop, File? imageFile) async {
    emit(WorkshopActionLoading());
    try {
      await createUseCase(workshop, imageFile);
      emit(const WorkshopActionSuccess('Workshop created successfully!'));
    } catch (e) {
      emit(WorkshopError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> updateWorkshop(WorkshopModel workshop, File? newImageFile) async {
    emit(WorkshopActionLoading());
    try {
      await updateUseCase(workshop, newImageFile);
      emit(const WorkshopActionSuccess('Workshop updated successfully!'));
    } catch (e) {
      emit(WorkshopError(_cleanErrorMessage(e.toString())));
    }
  }

  Future<void> deleteWorkshop(String workshopId) async {
    emit(WorkshopActionLoading());
    try {
      await deleteUseCase(workshopId);
      emit(const WorkshopActionSuccess('Workshop deleted efficiently.'));
    } catch (e) {
      emit(WorkshopError(_cleanErrorMessage(e.toString())));
    }
  }

  String _cleanErrorMessage(String rawError) {
    return rawError.replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }

  @override
  Future<void> close() {
    _workshopsSubscription?.cancel();
    return super.close();
  }
}
