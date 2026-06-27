#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Path to your virtual environment
VENV_PATH="${SCRIPT_DIR}/venv"

# Paths to your Python scripts
# You will need to create the on_ac_lost script later
ON_AC_LOST_SCRIPT="${SCRIPT_DIR}/on_ac_lost.py"
ON_AC_RESTORE_SCRIPT="${SCRIPT_DIR}/on_ac_restore.py"
ON_LOWBATT_SCRIPT="${SCRIPT_DIR}/on_lowbatt.py"

# Activate the virtual environment
source "$VENV_PATH/bin/activate"

# Use a case statement to handle different arguments
case "$1" in
    "online")
        # Execute the script for power restoration
        echo "Executing on_ac_restore script..."
        python3 "$ON_AC_RESTORE_SCRIPT"
        ;;
    "onbatt")
        # Execute the script for power loss
        echo "Executing on_ac_lost script..."
        python3 "$ON_AC_LOST_SCRIPT"
        ;;
    *)
        # Handle invalid arguments
        echo "Invalid argument. Usage: $0 online|onbatt|lowbatt"
        ;;
esac

# Deactivate the virtual environment
deactivate