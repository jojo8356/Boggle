import 'package:flutter/material.dart';

/// Centralized color constants used throughout the Froggle app.
class AppColors {
  AppColors._();

  // --- Green (word chips, valid states) ---
  static final Color green50 = Colors.green[50]!;
  static final Color green100 = Colors.green[100]!;
  static final Color green300 = Colors.green[300]!;
  static final Color green500 = Colors.green[500]!;
  static final Color green700 = Colors.green[700]!;
  static final Color green800 = Colors.green[800]!;

  // --- Grey (containers, disabled states) ---
  static final Color grey100 = Colors.grey[100]!;
  static final Color grey200 = Colors.grey[200]!;
  static final Color grey300 = Colors.grey[300]!;
  static final Color grey400 = Colors.grey[400]!;
  static final Color grey600 = Colors.grey[600]!;
  static final Color grey700 = Colors.grey[700]!;

  // --- Brown (grid, dice) ---
  static final Color brown50 = Colors.brown[50]!;
  static final Color brown100 = Colors.brown[100]!;
  static final Color brown200 = Colors.brown[200]!;
  static final Color brown300 = Colors.brown[300]!;
  static final Color brown400 = Colors.brown[400]!;
  static final Color brown600 = Colors.brown[600]!;
  static final Color brown700 = Colors.brown[700]!;
  static final Color brown800 = Colors.brown[800]!;
  static final Color brown900 = Colors.brown[900]!;
  static const Color brown = Colors.brown;

  // --- Purple (accent, buttons, score) ---
  static const Color purple = Colors.purple;
  static final Color purple400 = Colors.purple[400]!;
  static final Color purple600 = Colors.purple[600]!;
  static final Color purple700 = Colors.purple[700]!;

  // --- Blue (selection path, timer, new game section) ---
  static final Color blue50 = Colors.blue[50]!;
  static final Color blue100 = Colors.blue[100]!;
  static final Color blue200 = Colors.blue[200]!;
  static final Color blue400 = Colors.blue[400]!;
  static final Color blue700 = Colors.blue[700]!;
  static const Color blue = Colors.blue;

  // --- Red (error, cancel, invalid) ---
  static final Color red50 = Colors.red[50]!;
  static final Color red100 = Colors.red[100]!;
  static final Color red200 = Colors.red[200]!;
  static final Color red300 = Colors.red[300]!;
  static final Color red400 = Colors.red[400]!;
  static final Color red500 = Colors.red[500]!;
  static final Color red600 = Colors.red[600]!;
  static final Color red700 = Colors.red[700]!;
  static final Color red900 = Colors.red[900]!;
  static const Color red = Colors.red;

  // --- Amber / Orange (dice default, replay, shake button) ---
  static final Color amber100 = Colors.amber[100]!;
  static final Color amber300 = Colors.amber[300]!;
  static final Color amber600 = Colors.amber[600]!;
  static final Color amber700 = Colors.amber[700]!;
  static const Color amber = Colors.amber;
  static const Color orange = Colors.orange;
  static final Color orange50 = Colors.orange[50]!;
  static final Color orange100 = Colors.orange[100]!;
  static final Color orange200 = Colors.orange[200]!;
  static final Color orange300 = Colors.orange[300]!;
  static final Color orange600 = Colors.orange[600]!;
  static final Color orange700 = Colors.orange[700]!;
  static final Color orange800 = Colors.orange[800]!;
  static final Color orange900 = Colors.orange[900]!;

  // --- Amber (replay section) ---
  static final Color amber50 = Colors.amber[50]!;

  // --- Gradients ---
  static List<Color> purpleGradient = [purple400, purple600];
  static List<Color> homeGradient = [Colors.blue[400]!, purple400];
  static List<Color> gameEndGradient = [Colors.orange[400]!, red400];
}

/// Centralized BoxDecoration factories used throughout the Froggle app.
class AppDecorations {
  AppDecorations._();

  // --- Grey container (word list background, ranking items) ---
  /// Standard grey container: grey[100] background, grey[300] border, borderRadius 8.
  static BoxDecoration greyContainer({
    double borderRadius = 8,
    Color? borderColor,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.grey100,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? AppColors.grey300),
    );
  }

  // --- Green word chip ---
  /// Word chip decoration: green[100] background, green[300] border, borderRadius 4.
  static BoxDecoration wordChip({
    bool isSelected = false,
    double borderRadius = 4,
  }) {
    return BoxDecoration(
      color: isSelected ? AppColors.green300 : AppColors.green100,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: isSelected ? AppColors.green700 : AppColors.green300,
      ),
    );
  }

  // --- Circular action button (validate / cancel) ---
  /// Circular button with shadow, used for validate (green) and cancel (red) buttons.
  static BoxDecoration circularActionButton({
    required Color color,
    double alphaValue = 0.4,
  }) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: alphaValue),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Green validate button (circle).
  static BoxDecoration validateButton() {
    return circularActionButton(color: AppColors.green500);
  }

  /// Red cancel button (circle).
  static BoxDecoration cancelButton() {
    return circularActionButton(color: AppColors.red500);
  }

  // --- Grid container ---
  /// Brown grid background with shadow.
  static BoxDecoration gridContainer() {
    return BoxDecoration(
      color: AppColors.brown100,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.brown.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // --- Grid cell ---
  /// Individual grid cell decoration.
  static BoxDecoration gridCell({
    required Color cellColor,
    bool isSelected = false,
  }) {
    return BoxDecoration(
      color: cellColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(
        color: isSelected ? AppColors.brown700 : AppColors.brown400,
        width: isSelected ? 3 : 2,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.brown.withValues(alpha: 0.2),
          blurRadius: 2,
          offset: const Offset(1, 1),
        ),
      ],
    );
  }

  // --- Path index badge (circle with number in grid) ---
  /// Small circle badge showing path order number.
  static BoxDecoration pathIndexBadge({Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.blue700,
      shape: BoxShape.circle,
    );
  }

  // --- Feedback container (success / error message) ---
  /// Feedback message container.
  static BoxDecoration feedbackContainer({required bool isError}) {
    return BoxDecoration(
      color: isError ? AppColors.red100 : AppColors.green100,
      borderRadius: BorderRadius.circular(8),
    );
  }

  // --- Score display gradient ---
  /// Purple gradient decoration for score display.
  static BoxDecoration scoreDisplay() {
    return BoxDecoration(
      gradient: LinearGradient(colors: AppColors.purpleGradient),
      borderRadius: BorderRadius.circular(12),
    );
  }

  // --- Results round title ---
  /// Purple gradient container for round title on results screen.
  static BoxDecoration roundTitle() {
    return BoxDecoration(
      gradient: LinearGradient(colors: AppColors.purpleGradient),
      borderRadius: BorderRadius.circular(12),
    );
  }

  // --- Review grid container ---
  /// Container for the review grid on results screen.
  static BoxDecoration reviewGrid() {
    return BoxDecoration(
      color: AppColors.brown50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.brown200),
    );
  }

  // --- Selected word pill (review grid) ---
  /// Pill-shaped decoration showing the currently selected word.
  static BoxDecoration selectedWordPill() {
    return BoxDecoration(
      color: AppColors.green100,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.green300),
    );
  }

  // --- New game section ---
  /// Blue container for the "new game" voting section.
  static BoxDecoration newGameSection() {
    return BoxDecoration(
      color: AppColors.blue50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.blue),
    );
  }

  // --- Replay section ---
  /// Amber container for "replay same grid" section.
  static BoxDecoration replaySection() {
    return BoxDecoration(
      color: AppColors.amber50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.amber300),
    );
  }

  // --- Possible words section ---
  /// Orange container for the "missed words" section.
  static BoxDecoration possibleWordsSection() {
    return BoxDecoration(
      color: AppColors.orange50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.orange300),
    );
  }

  // --- Purple score badge ---
  /// Purple badge for total score display in ranking.
  static BoxDecoration scoreBadge() {
    return BoxDecoration(
      color: AppColors.purple,
      borderRadius: BorderRadius.circular(16),
    );
  }

  // --- Home screen gradient ---
  /// Gradient background for home screen.
  static BoxDecoration homeBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: AppColors.homeGradient,
      ),
    );
  }

  // --- Game end transition gradient ---
  /// Gradient background for game end transition screen.
  static BoxDecoration gameEndBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: AppColors.gameEndGradient,
      ),
    );
  }

  // --- Zoom slider container ---
  /// White container with shadow for the zoom slider popup.
  static BoxDecoration zoomSlider() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}

/// Centralized TextStyle constants used throughout the Froggle app.
class AppTextStyles {
  AppTextStyles._();

  // --- Word chip text ---
  /// Text style for word chips in the game screen band.
  static TextStyle wordChip = TextStyle(
    fontSize: 14,
    color: AppColors.green800,
    fontWeight: FontWeight.w600,
  );

  /// Text style for word chips in expanded player results (smaller).
  static TextStyle wordChipSmall = TextStyle(
    fontSize: 12,
    color: AppColors.green800,
    fontWeight: FontWeight.normal,
  );

  // --- Titles ---
  /// Main title (FROGGLE on home screen).
  static const TextStyle appTitle = TextStyle(
    fontSize: 56,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        offset: Offset(2, 2),
        blurRadius: 4,
        color: Colors.black26,
      ),
    ],
  );

  /// Large title for transition screen (TEMPS ECOUL).
  static const TextStyle transitionTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [
      Shadow(
        offset: Offset(2, 2),
        blurRadius: 4,
        color: Colors.black26,
      ),
    ],
  );

  /// Round result title.
  static const TextStyle roundTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  /// Section title (fontSize 20, bold).
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  /// Sub-section title (fontSize 18, bold).
  static const TextStyle subSectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  // --- Feedback text ---
  /// Generic feedback text style builder.
  static TextStyle feedback({required bool isError}) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: isError ? AppColors.red700 : AppColors.green700,
    );
  }

  // --- Grid cell letter ---
  /// Letter text on grid cells.
  static TextStyle gridLetter({double fontSize = 22}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: AppColors.brown900,
    );
  }

  // --- Path index number ---
  /// Small white number shown on path index badges.
  static const TextStyle pathIndex = TextStyle(
    color: Colors.white,
    fontSize: 10,
    fontWeight: FontWeight.bold,
  );

  // --- Score ---
  /// Score value in score display.
  static const TextStyle scoreValue = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  /// Score label in score display.
  static const TextStyle scoreLabel = TextStyle(
    fontSize: 12,
    color: Colors.white70,
  );

  /// Score badge text in ranking.
  static const TextStyle scoreBadge = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // --- Placeholder / hint ---
  /// Placeholder text for empty word list.
  static TextStyle placeholder = TextStyle(
    color: AppColors.grey400,
    fontStyle: FontStyle.italic,
    fontSize: 12,
  );

  /// Italic hint text.
  static TextStyle hint = TextStyle(
    fontSize: 12,
    color: AppColors.brown600,
    fontStyle: FontStyle.italic,
  );

  // --- Subtitle / caption ---
  /// Subtitle text (grey, 12px).
  static TextStyle subtitle = TextStyle(
    color: AppColors.grey600,
    fontSize: 12,
  );

  /// White subtitle for home screen.
  static const TextStyle homeSubtitle = TextStyle(
    fontSize: 18,
    color: Colors.white70,
  );

  // --- Shake button ---
  /// Shake button main text.
  static const TextStyle shakeButtonTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  /// Shake button description.
  static const TextStyle shakeButtonSubtitle = TextStyle(
    fontSize: 14,
    color: Colors.white70,
  );

  // --- Review grid title ---
  /// Review grid section title.
  static TextStyle reviewGridTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.brown800,
  );

  // --- Game end transition stats ---
  /// Stats text on game end transition screen.
  static TextStyle transitionStats({required Color color}) {
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }
}
