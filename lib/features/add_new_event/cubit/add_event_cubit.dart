import 'package:bloc/bloc.dart';
import 'package:events/features/add_new_event/services/add_event_service.dart';
import 'package:events/features/events/model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

part 'add_event_state.dart';

class AddEventCubit extends Cubit<AddEventState> {
  AddEventCubit(this.eventModel) : super(AddEventInitial(eventModel));
  final EventModel eventModel;
  bool saving = false;
  bool pickingImage = false;
  EventModel get stateEvent => state.eventModel;

  EventModel addImages(List<String> imagePath) {
    final updatedEvent = stateEvent.copyWith(imagePaths: imagePath);
    emit(EventUpdating(updatedEvent));
    return updatedEvent;
  }

  void removeImageFroList(int index) {
    final updateImageList = List<String>.from(state.eventModel.imagePaths);
    updateImageList.removeAt(index);
    final updatedEvent = stateEvent.copyWith(imagePaths: updateImageList);
    emit(EventUpdating(updatedEvent));
  }

  Future<void> pickImages() async {
    if (pickingImage) return;
    pickingImage = true;
    final picker = ImagePicker();
    final imageList = List<String>.from(stateEvent.imagePaths);
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isEmpty) {
      pickingImage = false;
      return;
    }

    for (final img in images) {
      final path = img.path;
      if (imageList.length >= 10) break;
      if (!imageList.contains(path)) {
        imageList.add(path);
      }
    }
    pickingImage = false;
    final updatedEvent = stateEvent.copyWith(imagePaths: imageList);
    emit(EventUpdating(updatedEvent));
  }

  void addTool(String toolText) {
    final updatedTools = List<String>.from(stateEvent.tools);
    if (!updatedTools.contains(toolText) && toolText.isNotEmpty) {
      updatedTools.add(toolText);
      final updatedEvent = stateEvent.copyWith(tools: updatedTools);
      emit(EventUpdating(updatedEvent));
    }
  }

  void removeTool(int index) {
    final updatedTools = List<String>.from(stateEvent.tools);
    updatedTools.removeAt(index);
    final updatedEvent = stateEvent.copyWith(tools: updatedTools);
    emit(EventUpdating(updatedEvent));
  }

  void changeEventType(int eventType) {
    final updatedEvent = stateEvent.copyWith(type: eventType);
    emit(EventUpdating(updatedEvent));
  }

  Future<void> postForm({
    String title = '',
    String description = '',
    bool isEditing = false,
  }) async {
    if (title.isEmpty) {
      emit(EventAddingFailed('لطفاً نام برنامه را وارد کنید', stateEvent));

      return;
    }
    emit(EventPosting(stateEvent));

    saving = true;

    try {
      final newEvent = stateEvent.copyWith(title: title, desc: description);
      final postedEvent = await AddEventService().upsert(newEvent);

      if (postedEvent == null) {
        emit(EventAddingFailed('ثبت برنامه ثبت نشد، دوباره سعی کنید!', stateEvent));
        saving = false;

        return;
      }
      emit(EventPostingSuccess(isEditing ? 'برنامه موفقانه ویرایش شد!' : 'برنامه موفقانه اضافه شد!', stateEvent));
    } catch (e) {
      debugPrint('posting data error is: $e');
      emit(EventAddingFailed('ثبت برنامه ثبت نشد، دوباره سعی کنید!', stateEvent));
    } finally {
      saving = false;
    }
  }

  void restFrom() {
    saving = false;
    pickingImage = false;
    emit(EventUpdating(EventModel.empty));
  }




}
