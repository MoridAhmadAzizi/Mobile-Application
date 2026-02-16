import 'package:events/core/extension/navigator_extension.dart';
import 'package:events/features/add_new_event/ui/add_event_screen.dart';
import 'package:events/features/events/model/event_model.dart';
import 'package:events/features/events/ui/widgets/image_slider.dart';
import 'package:events/utils/date_utils.dart';
import 'package:flutter/material.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel eventModel;
  const EventDetailScreen({super.key, required this.eventModel});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late ValueNotifier<EventModel> eventModelNotifier = ValueNotifier(widget.eventModel);

  String getEventType(int type) {
    if (EventType.isForKids(type)) {
      return EventType.kids.name;
    }
    return EventType.teens.name;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('deventaDDED build ${widget.eventModel.imagePaths.length}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('جزئیات برنامه'),
        actions: [
          InkWell(
            onTap: () {
              context.navigatorPush(AddEventScreen(
                  eventToUpdate: eventModelNotifier.value,
                  onAdded: (postedEvent) {
                    debugPrint('deventaDDED listener ${postedEvent.imagePaths.length}');
                    eventModelNotifier.value = postedEvent;
                  }));
            },
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.edit_rounded),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: eventModelNotifier,
          builder: (context, eventValue, child) {
            final created = eventValue.createdAt;
            final updated = eventValue.updatedAt;
            final showEdited = updated != null && (created == null || updated.isAfter(created));
            final theme = Theme.of(context);
            return Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  spacing: 15,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageSlider(eventValue.imagePaths),
                    Text(
                      eventValue.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    _chip(context, 'بخش: ${getEventType(eventValue.type)}'),
                    Text('توضحیات', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    if (eventValue.desc.isEmpty)
                      Center(child: _chip(context, 'توضیحاتی درباره این محصول وجود ندارد!'))
                    else
                      Text(eventValue.desc, style: theme.textTheme.titleSmall),
                    Text('ابزارها', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        for (final text in eventValue.tools) _chip(context, text),
                        if (eventValue.tools.isEmpty) Center(child: _chip(context, 'هیچ ابزاری هنوز اضافه نشده!')),
                      ],
                    ),
                    if (created != null) _chip(context, 'ایجاد:  ${DateUtilsFa.dateYmd(created)} - ${DateUtilsFa.timeHm(created)}'),
                    if (showEdited) _chip(context, 'آخرین ویرایش: ${DateUtilsFa.dateYmd(updated)} - ${DateUtilsFa.timeHm(updated)}'),
                  ],
                ),
              ),
            );
          }),
    );
  }

  Widget _chip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          )),
    );
  }
}
