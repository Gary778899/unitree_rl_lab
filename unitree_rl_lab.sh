#!/usr/bin/env bash

# Get the absolute path of the repository
export UNITREE_RL_LAB_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Detect Python via uv
if command -v uv &> /dev/null; then
    # Use 'uv run python' to ensure it uses the project's virtualenv
    python_exe="uv run --active python"
else
    echo "[Error] 'uv' is not installed or not in PATH. Please install uv first."
    exit 1
fi

# task env name autocomplete (Updated for uv)
_ut_rl_lab_python_argcomplete_wrapper() {
    local IFS=$'\013'
    local SUPPRESS_SPACE=0
    if compopt +o nospace 2> /dev/null; then
        SUPPRESS_SPACE=1
    fi

    COMPREPLY=( $(IFS="$IFS" \
                    COMP_LINE="$COMP_LINE" \
                    COMP_POINT="$COMP_POINT" \
                    COMP_TYPE="$COMP_TYPE" \
                    _ARGCOMPLETE=1 \
                    _ARGCOMPLETE_SUPPRESS_SPACE=$SUPPRESS_SPACE \
                    ${python_exe} ${UNITREE_RL_LAB_PATH}/scripts/rsl_rl/train.py 8>&1 9>&2 1>/dev/null 2>/dev/null) )
}
complete -o nospace -F _ut_rl_lab_python_argcomplete_wrapper "./unitree_rl_lab.sh"

_ut_setup_uv_env() {
    echo "[Info] Setting up environment variables..."
    
    # Since uv doesn't use 'activate.d', we create a local env file 
    # that you can source, or just export them now.
    export ISAACLAB_PATH="${ISAACLAB_PATH:-$HOME/IsaacLab}" # Adjust if your IsaacLab path is different
    
    echo "To use this environment in the future, ensure ISAACLAB_PATH is set."
    echo "Current ISAACLAB_PATH: $ISAACLAB_PATH"
}

# pass the arguments
case "$1" in
    -i|--install)
        echo "[Info] Installing unitree_rl_lab using uv..."
        git lfs install
        # Install in editable mode using uv
        uv pip install -e "${UNITREE_RL_LAB_PATH}/source/unitree_rl_lab/"
        _ut_setup_uv_env
        ;;
    -l|--list)
        shift
        ${python_exe} ${UNITREE_RL_LAB_PATH}/scripts/list_envs.py "$@"
        ;;
    -p|--play)
        shift
        ${python_exe} ${UNITREE_RL_LAB_PATH}/scripts/rsl_rl/play.py "$@"
        ;;
    -t|--train)
        shift
        ${python_exe} ${UNITREE_RL_LAB_PATH}/scripts/rsl_rl/train.py --headless "$@"
        ;;
    *)
        echo "Usage: $0 {-i|--install|-l|--list|-p|--play|-t|--train}"
        ;;
esac
