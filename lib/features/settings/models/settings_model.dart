class Settings {
  final String theme;
  final String currency;
  final String language;
  final String haptics;
  final String security;
  final String notifications;

  Settings({
    this.theme = 'System',
    this.currency = 'USD',
    this.language = 'English',
    this.haptics = 'On',
    this.security = 'Off',
    this.notifications = 'On',
  });

  Settings copyWith({
    String? theme,
    String? currency,
    String? language,
    String? haptics,
    String? security,
    String? notifications,
  }) {
    return Settings(
      theme: theme ?? this.theme,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      haptics: haptics ?? this.haptics,
      security: security ?? this.security,
      notifications: notifications ?? this.notifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'currency': currency,
      'language': language,
      'haptics': haptics,
      'security': security,
      'notifications': notifications,
    };
  }

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      theme: json['theme'] ?? 'System',
      currency: json['currency'] ?? 'USD',
      language: json['language'] ?? 'English',
      haptics: json['haptics'] ?? 'On',
      security: json['security'] ?? 'Off',
      notifications: json['notifications'] ?? 'On',
    );
  }
} 