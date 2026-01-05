/// Command Protocol Utility
/// 
/// Defines the command protocol format for communication with ESP32 hardware.
/// 
/// Protocol Format:
/// - Commands FROM hardware: `keyword,d#,e#[,optional_data]`
///   Examples: `start,d0,e0`, `stop,d1,e2,12:34:56:789`
/// 
/// - Commands TO hardware for finish/disqualify: `d#,e#`
///   Examples: `d1,e0`, `d1,e2`
/// 
/// - Commands TO hardware for start/pause/resume: `keyword,d#,e#`
///   Examples: `start,d0,e0`, `pause,d1,e1`, `resume,d0,e3`
/// 
/// Where:
/// - keyword: start, stop, pause, resume
/// - d0 = start action, d1 = stop action
/// - e0 = Mounted Start/Finish
/// - e1 = Mounted Start/Verify/Finish
/// - e2 = Show Jumping Top Score
/// - e3 = Show Jumping Normal

class CommandProtocol {
  // Event type constants
  static const String eventMountedStartFinish = 'e0';
  static const String eventMountedStartVerifyFinish = 'e1';
  static const String eventShowJumpingTopScore = 'e2';
  static const String eventShowJumpingNormal = 'e3';

  // Action constants
  static const String actionStart = 'd0';
  static const String actionStop = 'd1';

  // Command keywords
  static const String keywordStart = 'start';
  static const String keywordStop = 'stop';
  static const String keywordPause = 'pause';
  static const String keywordResume = 'resume';

  // Regex patterns
  /// Pattern for incoming commands from hardware: keyword,d[0-1],e[0-3][,optional_data]
  static final RegExp incomingCommandPattern = RegExp(
    r'^(start|stop|pause|resume),d[0-1],e[0-3](?:,.*)?$',
    caseSensitive: false,
  );

  /// Pattern for outgoing finish/disqualify commands: d[0-1],e[0-3]
  static final RegExp finishCommandPattern = RegExp(r'^d[0-1],e[0-3]$');

  /// Pattern to extract command parts
  static final RegExp commandPartsPattern = RegExp(
    r'^(start|stop|pause|resume),d([0-1]),e([0-3])(?:,(.*))?$',
    caseSensitive: false,
  );

  // ========== VALIDATION METHODS ==========

  /// Validates if the message matches the expected incoming command format
  static bool isValidIncomingCommand(String message) {
    return incomingCommandPattern.hasMatch(message.trim());
  }

  /// Validates if the command matches the finish command format (d#,e#)
  static bool isValidFinishCommand(String command) {
    return finishCommandPattern.hasMatch(command.trim());
  }

  // ========== PARSING METHODS ==========

  /// Parses an incoming command and returns a map with its components
  /// Returns null if the command is invalid
  /// 
  /// Returns:
  /// {
  ///   'keyword': 'start'|'stop'|'pause'|'resume',
  ///   'action': 'd0'|'d1',
  ///   'event': 'e0'|'e1'|'e2'|'e3',
  ///   'data': optional additional data (e.g., timestamp)
  /// }
  static Map<String, String>? parseCommand(String message) {
    final match = commandPartsPattern.firstMatch(message.trim());
    if (match == null) return null;

    return {
      'keyword': match.group(1)!.toLowerCase(),
      'action': 'd${match.group(2)}',
      'event': 'e${match.group(3)}',
      if (match.group(4) != null) 'data': match.group(4)!,
    };
  }

  /// Extracts the event code from a command
  /// Returns null if invalid
  static String? getEventCode(String message) {
    final parsed = parseCommand(message);
    return parsed?['event'];
  }

  /// Extracts the keyword from a command
  /// Returns null if invalid
  static String? getKeyword(String message) {
    final parsed = parseCommand(message);
    return parsed?['keyword'];
  }

  /// Extracts optional data (like timestamp) from a command
  /// Returns null if no data or invalid command
  static String? getData(String message) {
    final parsed = parseCommand(message);
    return parsed?['data'];
  }

  // ========== COMMAND BUILDING METHODS ==========

  /// Builds a START command: start,d0,e#
  static String buildStartCommand(String eventCode) {
    return '$keywordStart,$actionStart,$eventCode';
  }

  /// Builds a STOP command: stop,d1,e#
  static String buildStopCommand(String eventCode) {
    return '$keywordStop,$actionStop,$eventCode';
  }

  /// Builds a PAUSE command: pause,d1,e#
  static String buildPauseCommand(String eventCode) {
    return '$keywordPause,$actionStop,$eventCode';
  }

  /// Builds a RESUME command: resume,d0,e#
  static String buildResumeCommand(String eventCode) {
    return '$keywordResume,$actionStart,$eventCode';
  }

  /// Builds a FINISH command (for buttons): d1,e#
  static String buildFinishCommand(String eventCode) {
    return '$actionStop,$eventCode';
  }

  // ========== VALIDATION HELPERS ==========

  /// Checks if the command matches the expected event code
  static bool matchesEventCode(String message, String expectedEventCode) {
    final eventCode = getEventCode(message);
    return eventCode == expectedEventCode;
  }

  /// Checks if the command is a START command
  static bool isStartCommand(String message) {
    return getKeyword(message) == keywordStart;
  }

  /// Checks if the command is a STOP command
  static bool isStopCommand(String message) {
    return getKeyword(message) == keywordStop;
  }

  /// Checks if the command is a PAUSE command
  static bool isPauseCommand(String message) {
    return getKeyword(message) == keywordPause;
  }

  /// Checks if the command is a RESUME command
  static bool isResumeCommand(String message) {
    return getKeyword(message) == keywordResume;
  }
}
