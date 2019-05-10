#!/usr/bin/env bash

###############
# Definitions #
###############

########################
# Function definitions #
########################

# Usage message
usage_header()
{
    echo "Release a new stable system. Includes a SMuRF server and pysmurf."
    echo
}


#############
# Main body #
#############

# Call common release step to all type of application
. system_common.sh

# Print final report
echo ""
echo "All Done!"
echo "Script released to ${target_dir}"
echo ""