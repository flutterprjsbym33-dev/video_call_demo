extension UrlValidator on String {
  bool get isUrl {
    // Regular expression for basic URL validation
    final urlRegex = RegExp(
      r'^(https?:\/\/)?'
      r'([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+'
      r'[a-zA-Z]{2,}'
      r'(:[0-9]{1,5})?'
      r'(\/.*)?$',
      caseSensitive: false,
    );

    return urlRegex.hasMatch(this);
  }
}