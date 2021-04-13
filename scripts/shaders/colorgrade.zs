/*
 * Copyright (C) 2019-2020 Dennis "Exl" Meuwissen
 *
 * This work is licensed under the Creative Commons
 * Attribution-NonCommercial-ShareAlike 4.0 International License. To view a
 * copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/4.0/
 *
 * You are free to copy and redistribute the material in any medium or format;
 * and remix, transform, and build upon the material. If you do so, you must
 * give appropriate credit, provide a link to the license, and indicate if
 * changes were made. You may do so in any reasonable manner, but not in any way
 * that suggests the licensor endorses you or your use. You may not use the
 * material for commercial purposes. If you remix, transform, or build upon the
 * material, you must distribute your contributions under the same license as
 * the original.
**/

/**
 * Current state of a player's color grade effect.
 */
struct ColorGradeState {

  // LUT currently visible or being transitioned to.
  int currentLut;
  double currentSpeed;

  // Once the current transition has finished, this will be the next LUT transitioned to.
  int nextLut;
  double nextSpeed;

  // How far along the transition the state is.
  double alpha;
}


/**
 * Initializes color grading state for new players.
 */
class ColorGradeEventHandler : EventHandler {
  override void PlayerEntered(PlayerEvent e) {
    let thinker = ColorGradeThinker.Get();
    thinker.InitPlayer(e.PlayerNumber);
  }
}


/**
 * Main thinker for initializing and updating the color grading shader.
 */
class ColorGradeThinker : Thinker {

  // Default transition speed.
  const DEFAULT_SPEED_TICKS = 70;

  // State for all possible players.
  ColorGradeState playerStates[MAXPLAYERS];

  // Was color grading enabled on the previous tick?
  bool wasEnabled;

  /**
   * Thinker initialization.
   */
  ColorGradeThinker Init() {
    self.wasEnabled = bool(CVar.FindCVar('boa_colorgrading').GetInt());

    return self;
  }

  /**
   * Returns the only thinker instance.
   */
  static ColorGradeThinker Get() {
    ThinkerIterator it = ThinkerIterator.Create("ColorGradeThinker");
    let p = ColorGradeThinker(it.Next());
    if (p == null) {
      p = new("ColorGradeThinker").Init();
    }
    return p;
  }

  override void Tick() {
    bool enabled = bool(CVar.FindCVar('boa_colorgrading').GetInt());
    if (!enabled && !wasEnabled) {
      return;
    }

    for (int i = 0; i < MAXPLAYERS; i++) {
      if (!playeringame[i]) {
        continue;
      }

      // Toggle shader state from the current console variable state.
      if (!enabled && wasEnabled) {
        Shader.SetEnabled(players[i], "ColorGrade", false);
        continue;
      } else if (enabled && !wasEnabled) {
        Shader.SetEnabled(players[i], "ColorGrade", true);
      }

      // Transition is completed.
      if (playerStates[i].alpha >= 1.0) {
        if (playerStates[i].currentLut == playerStates[i].nextLut) {
          continue;
        }

        // Transition to the next queued lut.
        Shader.SetUniform1i(players[i], "ColorGrade", "lutA", playerStates[i].currentLut);
        Shader.SetUniform1i(players[i], "ColorGrade", "lutB", playerStates[i].nextLut);
        Shader.SetUniform1f(players[i], "ColorGrade", "alpha", 0.0);

        playerStates[i].currentLut = playerStates[i].nextLut;
        playerStates[i].currentSpeed = playerStates[i].nextSpeed;
        playerStates[i].alpha = 0.0;

        continue;
      }

      // Update current transition and adjust shader.
      playerStates[i].alpha += playerStates[i].currentSpeed;
      if (playerStates[i].alpha >= 1.0) {
        playerStates[i].alpha = 1.0;
      }
      Shader.SetUniform1f(players[i], "ColorGrade", "alpha", playerStates[i].alpha);
    }

    self.wasEnabled = enabled;
  }

  /**
   * Initializes color grading for a single player.
   */
  void InitPlayer(int playerNumber) {
    self.PlayerSet(playerNumber, 0);
    Shader.SetEnabled(players[playerNumber], "ColorGrade", true);
  }

  /**
   * Sets up a transition from the current LUT to a new one.
   */
  void PlayerTransitionTo(int playerNumber, int newLut, int speed) {
    if (speed == 0) {
      speed = DEFAULT_SPEED_TICKS;
    }

    playerStates[playerNumber].nextLut = newLut;
    playerStates[playerNumber].nextSpeed = 1.0 / double(speed);
  }

  /**
   * Immediately sets a new LUT.
   */
  void PlayerSet(int playerNumber, int lut) {
    playerStates[playerNumber].currentLut = lut;
    playerStates[playerNumber].currentSpeed = 0.0;

    playerStates[playerNumber].nextLut = lut;
    playerStates[playerNumber].nextSpeed = 0.0;

    playerStates[playerNumber].alpha = 1.0;

    Shader.SetUniform1i(players[playerNumber], "ColorGrade", "lutA", lut);
    Shader.SetUniform1i(players[playerNumber], "ColorGrade", "lutB", lut);
    Shader.SetUniform1f(players[playerNumber], "ColorGrade", "alpha", 1.0);
  }

  /**
   * Transition to new LUT for given player, callable from ACS.
   */
  static void TransitionTo(int playerNumber, int lutNew, int speed) {
    let thinker = ColorGradeThinker.Get();
    thinker.PlayerTransitionTo(playerNumber, lutNew, speed);
  }

  /**
   * Set new LUT for given player, callable from ACS.
   */
  static void Set(int playerNumber, int lut) {
    let thinker = ColorGradeThinker.Get();
    thinker.PlayerSet(playerNumber, lut);
  }
}
