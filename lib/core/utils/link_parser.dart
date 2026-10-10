/// Represents the result of parsing a join or meeting link.
class ParsedJoinLink {
  final bool isValid;
  final String? token;
  final String? rawInput;
  final String? error;

  const ParsedJoinLink._({
    required this.isValid,
    this.token,
    this.rawInput,
    this.error,
  });

  factory ParsedJoinLink.success(String token, String rawInput) {
    return ParsedJoinLink._(
      isValid: true,
      token: token,
      rawInput: rawInput,
    );
  }

  factory ParsedJoinLink.failure(String error, String rawInput) {
    return ParsedJoinLink._(
      isValid: false,
      rawInput: rawInput,
      error: error,
    );
  }

  @override
  String toString() => isValid
      ? 'ParsedJoinLink.success(token: $token)'
      : 'ParsedJoinLink.failure(error: $error)';
}

/// Robust parser for TradeMind buyer join links, QR scans, and manual paste.
class LinkParser {
  // Common valid path segments used in web and mobile
  static final _pathKeywords = [
    'buyer-chat',
    'buyer',
    'join',
    'live-chat',
    'r',
    'room',
  ];

  /// Parses raw input string into a valid room/session token.
  /// Handles:
  /// - Full URLs (http, https) with path segments, trailing slashes, query params, fragments
  /// - Custom schemes (trademind://join/<token>, peitho://buyer-chat/<token>)
  /// - Bare alphanumeric tokens and UUIDs
  /// - Whitespace and casing
  /// - Rejects malformed and garbage inputs
  static ParsedJoinLink parse(String? raw) {
    if (raw == null) {
      return ParsedJoinLink.failure('Input is null', '');
    }

    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return ParsedJoinLink.failure('Link or token cannot be empty', raw);
    }

    // 1. Try URI parsing
    try {
      final uri = Uri.tryParse(trimmed);
      if (uri != null) {
        // A. Custom URI Schemes: e.g. trademind://join/<token> or trademind://join?token=<token>
        if (uri.hasScheme && (uri.scheme == 'trademind' || uri.scheme == 'peitho')) {
          // Check query parameters first
          if (uri.queryParameters.containsKey('token') &&
              uri.queryParameters['token']!.trim().isNotEmpty) {
            return _validateToken(uri.queryParameters['token']!, raw);
          }

          // Check path segments
          final segments = uri.pathSegments
              .where((s) => s.trim().isNotEmpty)
              .toList();
          if (segments.isNotEmpty) {
            return _validateToken(segments.last, raw);
          }

          // Host might be used as the token if path is empty e.g. trademind://my-token
          if (uri.host.isNotEmpty && uri.host != 'join' && uri.host != 'buyer') {
            return _validateToken(uri.host, raw);
          }
        }

        // B. HTTP / HTTPS URLs
        if (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https')) {
          // Check query parameters: ?token=XYZ or ?session=XYZ or ?id=XYZ
          for (final param in ['token', 'session', 'sessionId', 'id', 'room']) {
            if (uri.queryParameters.containsKey(param) &&
                uri.queryParameters[param]!.trim().isNotEmpty) {
              return _validateToken(uri.queryParameters[param]!, raw);
            }
          }

          final segments = uri.pathSegments
              .where((s) => s.trim().isNotEmpty)
              .toList();

          if (segments.isNotEmpty) {
            // Find keyword match in segments
            for (int i = 0; i < segments.length; i++) {
              final lower = segments[i].toLowerCase();
              if (_pathKeywords.contains(lower) && i + 1 < segments.length) {
                return _validateToken(segments[i + 1], raw);
              }
            }

            // Fallback: if last segment looks like a token
            final last = segments.last;
            if (_isValidTokenFormat(last)) {
              return _validateToken(last, raw);
            }
          }

          return ParsedJoinLink.failure(
            'URL does not contain a valid session token',
            raw,
          );
        }
      }
    } catch (_) {}

    // 2. Direct Bare Token or Path String e.g. "join/ABC-123" or "40c5fce0-49c0-424b-b0b3-1fcfbf05a3e1"
    var tokenCandidate = trimmed;

    // Strip leading slashes
    while (tokenCandidate.startsWith('/')) {
      tokenCandidate = tokenCandidate.substring(1);
    }

    // Strip trailing slashes, queries, or fragments
    if (tokenCandidate.contains('?')) {
      tokenCandidate = tokenCandidate.split('?').first;
    }
    if (tokenCandidate.contains('#')) {
      tokenCandidate = tokenCandidate.split('#').first;
    }
    while (tokenCandidate.endsWith('/')) {
      tokenCandidate = tokenCandidate.substring(0, tokenCandidate.length - 1);
    }

    // Check if it starts with a keyword path like "buyer-chat/TOKEN"
    for (final kw in _pathKeywords) {
      if (tokenCandidate.toLowerCase().startsWith('$kw/')) {
        tokenCandidate = tokenCandidate.substring(kw.length + 1);
        break;
      }
    }

    if (_isValidTokenFormat(tokenCandidate)) {
      return _validateToken(tokenCandidate, raw);
    }

    return ParsedJoinLink.failure(
      'Invalid link or token format: "$raw"',
      raw,
    );
  }

  static bool _isValidTokenFormat(String s) {
    final clean = s.trim();
    if (clean.length < 3 || clean.length > 128) return false;
    // Disallow pure punctuation or characters not valid in tokens/UUIDs/slugs
    final validChars = RegExp(r'^[a-zA-Z0-9_\-]+$');
    return validChars.hasMatch(clean);
  }

  static ParsedJoinLink _validateToken(String token, String rawInput) {
    final clean = token.trim();
    if (_isValidTokenFormat(clean)) {
      return ParsedJoinLink.success(clean, rawInput);
    }
    return ParsedJoinLink.failure(
      'Token contained invalid characters: "$clean"',
      rawInput,
    );
  }
}
