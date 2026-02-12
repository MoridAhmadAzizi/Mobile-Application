import 'package:events/features/add_new_event/cubit/add_event_cubit.dart';
import 'package:events/features/add_new_event/ui/widgets/button_section.dart';
import 'package:events/features/add_new_event/ui/widgets/event_type_selector.dart';
import 'package:events/features/add_new_event/ui/widgets/image_picker.dart';
import 'package:events/features/add_new_event/ui/widgets/tool_selector.dart';
import 'package:events/features/events/model/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddEventScreen extends StatefulWidget {
  final EventModel? initialEvent;
  const AddEventScreen({this.onAdded, super.key, this.initialEvent});
  final VoidCallback? onAdded;

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _descriptionTextController = TextEditingController();
  AddEventCubit get addEventCubit => AddEventCubit(widget.initialEvent ?? EventModel.empty);

  void _showSnackBarMessage(String msg, {bool success = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green.shade600 : Colors.red.shade600,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.initialEvent != null) {
      final eventToUpdate = widget.initialEvent!;
      _titleTextController.text = eventToUpdate.title;
      _descriptionTextController.text = eventToUpdate.desc;
    }
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    _descriptionTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialEvent != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'ویرایش محصول' : 'محصول جدید',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[50],
      body: BlocProvider<AddEventCubit>.value(
        value: addEventCubit,
        child: BlocConsumer<AddEventCubit, AddEventState>(
          listener: (context, state) {
            if (state is EventAddingFailed) {
              _showSnackBarMessage(state.message, success: false);
            } else {
              if (state is EventPostingSuccess) {
                _showSnackBarMessage(state.message);
                widget.onAdded?.call();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    context.pop();
                  }
                });
              }
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          ImagePickerWidget(state.eventModel.imagePaths),
                          const SizedBox(height: 24),
                          _buildTextField(
                            label: 'نام محصول',
                            icon: Icons.badge_outlined,
                            controller: _titleTextController,
                            hint: 'نام محصول را وارد کنید',
                          ),
                          const SizedBox(height: 20),
                          EventTypeSelector(eventType: state.eventModel.type),
                          const SizedBox(height: 20),
                          ToolSelector(state.eventModel.tools),
                          const SizedBox(height: 20),
                          _buildTextField(
                            label: 'توضیحات',
                            textType: TextInputType.multiline,
                            icon: Icons.description_outlined,
                            controller: _descriptionTextController,
                            hint: 'توضیحات محصول (اختیاری)',
                            maxLines: 1,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: ButtonSection(
                      isEditing: isEditing,
                      isPosting: state is EventPosting || state is EventPostingSuccess,
                      onReset: () {
                        _titleTextController.clear();
                        _descriptionTextController.clear();
                        context.read<AddEventCubit>().restFrom();
                      },
                      onSubmit: () {
                        context
                            .read<AddEventCubit>()
                            .postForm(title: _titleTextController.text, description: _descriptionTextController.text, isEditing: isEditing);
                      },
                    )),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String hint,
    TextInputType? textType,
    int maxLines = 3,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: Colors.grey[300]!, width: 2),
            ),
            child: TextField(
              maxLines: textType != null ? null : 1,
              expands: textType != null,
              controller: controller,
              keyboardType: textType,
              decoration: InputDecoration(
                hintText: hint,
                prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(7), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
