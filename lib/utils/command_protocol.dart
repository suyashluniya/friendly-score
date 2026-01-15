/// Command Protocol Utility
/// 
/// Defines the command protocol format for communication with ESP32 hardware.
/// 
/// Protocol Format:
/// - Commands FROM hardware: 
///   * Start signal: Just the keyword `start`
///   * Stop signal with time: `Stop,hh:mm:ss:msmsms`
///   Example: `start`, `Stop,01:23:45:123`
/// 
/// - Commands TO hardware for beacon/finish/disqualify: `d#,e#`
///   Examples: `d0,e0`, `d1,e2`
/// 
/// - Commands TO hardware with time for show jumping top score: `d0,e#,t##`
///   Examples: `d0,e2,t45` (45 seconds time allowed)
/// 
/// - Commands TO hardware for pause/resume: Just the keyword
///   Examples: `pause`, `resume`
/// 
/// Where:
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
  /// Pattern for beacon/finish commands: d[0-1],e[0-3]
  static final RegExp beaconCommandPattern = RegExp(r'^d[0-1],e[0-3]$');

  // ========== VALIDATION METHODS ==========

  /// Validates if the message is a START command (just the keyword)
  static bool isValidIncomingCommand(String message) {
    return message.trim().toLowerCase() == 'start';
  }

  /// Validates if the command matches the beacon format (d#,e#)
  static bool isValidBeaconCommand(String command) {
    return beaconCommandPattern.hasMatch(command.trim());
  }

  // ========== COMMAND BUILDING METHODS ==========

  /// Builds a START beacon command: d0,e#
  static String buildStartCommand(String eventCode) {
    return '$actionStart,$eventCode';
  }

  /// Builds a PAUSE command: just 'pause'
  static String buildPauseCommand() {
    return keywordPause;
  }

  /// Builds a RESUME command: just 'resume'
  static String buildResumeCommand() {
    return keywordResume;
  }

  /// Builds a FINISH command: d1,e#
  static String buildFinishCommand(String eventCode) {
    return '$actionStop,$eventCode';
  }

  /// Builds a TIME command with seconds: d0,e#,t##
  static String buildTimeCommand(String eventCode, int timeInSeconds) {
    return '$actionStart,$eventCode,t$timeInSeconds';
  }

  // ========== VALIDATION HELPERS ==========

  /// Checks if the command is a START command (just 'start')
  static bool isStartCommand(String message) {
    return message.trim().toLowerCase() == keywordStart;
  }
}
