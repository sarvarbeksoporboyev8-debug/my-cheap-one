/// Driver settings model for persisting driver preferences
class DriverSettings {
  // Availability & Jobs
  final bool autoGoOnline;
  final bool autoAccept;
  final double maxPickupKm;
  final double minFee;
  final String preferredJobType; // food, grocery, both
  
  // Navigation & Maps
  final String navApp; // in_app, google_maps, waze
  final bool voiceNav;
  final bool avoidTolls;
  final String units; // km, mi
  final bool keepScreenAwake;
  
  // Notifications
  final bool notifRequests;
  final bool notifSound;
  final bool notifVibration;
  final bool notifChat;
  final int quietStartMinutes; // e.g., 22:00 = 1320
  final int quietEndMinutes;   // e.g., 07:00 = 420
  
  // Safety
  final bool shareLiveLocation;
  final bool safetyReminders;
  final String emergencyName;
  final String emergencyPhone;

  const DriverSettings({
    this.autoGoOnline = false,
    this.autoAccept = false,
    this.maxPickupKm = 10.0,
    this.minFee = 2.0,
    this.preferredJobType = 'both',
    this.navApp = 'in_app',
    this.voiceNav = true,
    this.avoidTolls = false,
    this.units = 'km',
    this.keepScreenAwake = true,
    this.notifRequests = true,
    this.notifSound = true,
    this.notifVibration = true,
    this.notifChat = true,
    this.quietStartMinutes = -1, // -1 means disabled
    this.quietEndMinutes = -1,
    this.shareLiveLocation = true,
    this.safetyReminders = true,
    this.emergencyName = '',
    this.emergencyPhone = '',
  });

  DriverSettings copyWith({
    bool? autoGoOnline,
    bool? autoAccept,
    double? maxPickupKm,
    double? minFee,
    String? preferredJobType,
    String? navApp,
    bool? voiceNav,
    bool? avoidTolls,
    String? units,
    bool? keepScreenAwake,
    bool? notifRequests,
    bool? notifSound,
    bool? notifVibration,
    bool? notifChat,
    int? quietStartMinutes,
    int? quietEndMinutes,
    bool? shareLiveLocation,
    bool? safetyReminders,
    String? emergencyName,
    String? emergencyPhone,
  }) {
    return DriverSettings(
      autoGoOnline: autoGoOnline ?? this.autoGoOnline,
      autoAccept: autoAccept ?? this.autoAccept,
      maxPickupKm: maxPickupKm ?? this.maxPickupKm,
      minFee: minFee ?? this.minFee,
      preferredJobType: preferredJobType ?? this.preferredJobType,
      navApp: navApp ?? this.navApp,
      voiceNav: voiceNav ?? this.voiceNav,
      avoidTolls: avoidTolls ?? this.avoidTolls,
      units: units ?? this.units,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      notifRequests: notifRequests ?? this.notifRequests,
      notifSound: notifSound ?? this.notifSound,
      notifVibration: notifVibration ?? this.notifVibration,
      notifChat: notifChat ?? this.notifChat,
      quietStartMinutes: quietStartMinutes ?? this.quietStartMinutes,
      quietEndMinutes: quietEndMinutes ?? this.quietEndMinutes,
      shareLiveLocation: shareLiveLocation ?? this.shareLiveLocation,
      safetyReminders: safetyReminders ?? this.safetyReminders,
      emergencyName: emergencyName ?? this.emergencyName,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
    );
  }

  Map<String, dynamic> toJson() => {
    'autoGoOnline': autoGoOnline,
    'autoAccept': autoAccept,
    'maxPickupKm': maxPickupKm,
    'minFee': minFee,
    'preferredJobType': preferredJobType,
    'navApp': navApp,
    'voiceNav': voiceNav,
    'avoidTolls': avoidTolls,
    'units': units,
    'keepScreenAwake': keepScreenAwake,
    'notifRequests': notifRequests,
    'notifSound': notifSound,
    'notifVibration': notifVibration,
    'notifChat': notifChat,
    'quietStartMinutes': quietStartMinutes,
    'quietEndMinutes': quietEndMinutes,
    'shareLiveLocation': shareLiveLocation,
    'safetyReminders': safetyReminders,
    'emergencyName': emergencyName,
    'emergencyPhone': emergencyPhone,
  };

  factory DriverSettings.fromJson(Map<String, dynamic> json) => DriverSettings(
    autoGoOnline: json['autoGoOnline'] as bool? ?? false,
    autoAccept: json['autoAccept'] as bool? ?? false,
    maxPickupKm: (json['maxPickupKm'] as num?)?.toDouble() ?? 10.0,
    minFee: (json['minFee'] as num?)?.toDouble() ?? 2.0,
    preferredJobType: json['preferredJobType'] as String? ?? 'both',
    navApp: json['navApp'] as String? ?? 'in_app',
    voiceNav: json['voiceNav'] as bool? ?? true,
    avoidTolls: json['avoidTolls'] as bool? ?? false,
    units: json['units'] as String? ?? 'km',
    keepScreenAwake: json['keepScreenAwake'] as bool? ?? true,
    notifRequests: json['notifRequests'] as bool? ?? true,
    notifSound: json['notifSound'] as bool? ?? true,
    notifVibration: json['notifVibration'] as bool? ?? true,
    notifChat: json['notifChat'] as bool? ?? true,
    quietStartMinutes: json['quietStartMinutes'] as int? ?? -1,
    quietEndMinutes: json['quietEndMinutes'] as int? ?? -1,
    shareLiveLocation: json['shareLiveLocation'] as bool? ?? true,
    safetyReminders: json['safetyReminders'] as bool? ?? true,
    emergencyName: json['emergencyName'] as String? ?? '',
    emergencyPhone: json['emergencyPhone'] as String? ?? '',
  );

  /// Check if quiet hours are enabled
  bool get quietHoursEnabled => quietStartMinutes >= 0 && quietEndMinutes >= 0;

  /// Format quiet hours for display
  String get quietHoursDisplay {
    if (!quietHoursEnabled) return 'Off';
    final startHour = quietStartMinutes ~/ 60;
    final startMin = quietStartMinutes % 60;
    final endHour = quietEndMinutes ~/ 60;
    final endMin = quietEndMinutes % 60;
    return '${startHour.toString().padLeft(2, '0')}:${startMin.toString().padLeft(2, '0')} - ${endHour.toString().padLeft(2, '0')}:${endMin.toString().padLeft(2, '0')}';
  }
}
