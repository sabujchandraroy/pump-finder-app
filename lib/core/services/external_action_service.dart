import 'package:url_launcher/url_launcher.dart';

class ExternalActionService {
  const ExternalActionService();

  Future<bool> callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    return launchUrl(uri);
  }

  Future<bool> openDirections({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
