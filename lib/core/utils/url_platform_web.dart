import 'dart:js_interop';

@JS('window.location.assign')
external void _assignLocation(JSString url);

void platformLaunchUrl(String url) {
  try {
    _assignLocation(url.toJS);
  } catch (_) {}
}
