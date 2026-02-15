import 'package:events/features/events/model/event_model.dart';
import 'package:events/features/events/repository/event_repository.dart';
import 'package:events/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventServices {
  const EventServices(this.eventRepository);
  final EventRepository eventRepository;
  Future<List<EventModel>> fetchEventsFromServer() async {
    final supabase = Supabase.instance.client;
    final data = await supabase
        .from(SupabaseConfig.productColumn)
        .select('id,title,description,type,tools,image_paths,created_at,updated_at')
        .order('created_at');
    final events = data.map(EventModel.formJson).toList();
    eventRepository.storeEvents(events);
    return events;
  }

  Future<List<EventModel>> reloadEvents() async {
    await fetchEventsFromServer();
    return eventRepository.getActiveEvents().toList();
  }
}
