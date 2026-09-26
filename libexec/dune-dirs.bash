# Sourced by the Bash tools: this project's data and config roots. DUNE_DATA_DIR and DUNE_CONFIG_DIR, when set, win
# (game-specific overrides); otherwise the XDG base directories, falling back to ~/.local/share and ~/.config. Only
# absolute XDG values count (a relative one is invalid per the XDG spec). Sets DUNE_DATA_ROOT and DUNE_CONFIG_ROOT;
# each narrower DUNE_*_DIR variable (DUNE_STATE_DIR, DUNE_UNPACKED_DIR, ...) still overrides its own directory.
case "${XDG_DATA_HOME:-}" in /*) DUNE_DATA_ROOT=$XDG_DATA_HOME/dune_awakening_server ;; *) DUNE_DATA_ROOT=$HOME/.local/share/dune_awakening_server ;; esac
case "${XDG_CONFIG_HOME:-}" in /*) DUNE_CONFIG_ROOT=$XDG_CONFIG_HOME/dune_awakening_server ;; *) DUNE_CONFIG_ROOT=$HOME/.config/dune_awakening_server ;; esac
DUNE_DATA_ROOT=${DUNE_DATA_DIR:-$DUNE_DATA_ROOT}
DUNE_CONFIG_ROOT=${DUNE_CONFIG_DIR:-$DUNE_CONFIG_ROOT}
