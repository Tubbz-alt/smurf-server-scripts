#!/usr/bin/env bash

###############
# Definitions #
###############
# Default release output directory
release_top_default_dir="/home/cryo/docker/smurf"

# Template directory for this application
template_dir=${template_top_dir}/system-dev-sw

# smurf2mce git repository
smurf2me_git_repo=http://github.com/slaclab/smurf2mce.git

########################
# Function definitions #
########################

# Usage message
usage()
{
    echo "Release a new system for SW development. Includes a smurf server and pysmurf."
    echo "The SMuRF server uses a user provided SW version, located in the 'smurf2mce' folder. This script will clone the master branch from github."
    echo "The SMuRF server uses an user provided FW version, located in the 'fw' folder."
    echo ""
    echo "usage: ${script_name} -t system-dev-sw -N|--slot <slot_number> -s|--smurf2mce-version <smurf2mce_version>"
    echo "                      -p|--pysmurf_version <pysmurf_version> [-o|--output-dir <output_dir>]"
    echo "                      [-h|--help]"
    echo "    -N|--slot                   <slot_number>            : ATCA crate slot number."
    echo "    -s|--smurf2mce-base-version <smurf2mce-base_version> : Version of the smurf2mce-base docker image (used only as a base image; smurf2mce will be overwritten by the local copy)."
    echo "    -p|--pysmurf_version        <pysmurf_version>        : Version of the pysmurf docker image"
    echo "    -o|--output-dir             <output_dir>             : Top directory where to release the scripts. Defaults to ${release_top_default_dir}/<slot_number>/dev_sw/<smurf2mce_base_version>"
    echo "    -h|--help                                            : Show this message"
    echo ""
    exit $1
}


#############
# Main body #
#############

# Verify inputs arguments
while [[ $# -gt 0 ]]
do
key="$1"

case ${key} in
    -N|--slot)
    slot_number="$2"
    shift
    ;;
    -s|--smurf2mce-base-version)
    smurf2mce_base_version="$2"
    shift
    ;;
    -p|--pysmurf_version)
    pysmurf_version="$2"
    shift
    ;;
    -o|--output-dir)
    target_dir="$2"
    shift
    ;;
    -h|--help)
    usage 0
    ;;
    *)
    echo "Unknown argument"
    usage 1
    ;;
esac
shift
done

# Verify parameters
if [ -z ${slot_number+x} ]; then
        echo "ERROR: Slot number not defined!"
        echo ""
        usage 1
fi

if [ -z ${smurf2mce_base_version+x} ]; then
        echo "ERROR: smurf2mce-base version not defined!"
        echo ""
        usage 1
fi

if [ -z ${pysmurf_version+x} ]; then
        echo "ERROR: pysmurf version not defined!"
        echo ""
        usage 1
fi

if [ -z ${target_dir+x} ]; then
    target_dir=${release_top_default_dir}/slot${slot_number}/dev_sw/${smurf2mce_base_version}
fi

# Verify is target directory already exist
if [ -d ${target_dir} ]; then
    echo "ERROR: release directory '${target_dir}' already exist."
    exit 1
fi

# Create target directory
echo "Creating target directory ${target_dir}..."

mkdir -p ${target_dir}

if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: could not create the target directory"
    exit 1
fi

echo "Done!"
echo ""

# Generate docker compose file
cat ${template_dir}/docker_compose.yml \
        | sed s/%%SLOT_NUMBER%%/${slot_number}/g \
        | sed s/%%PYSMURF_VERSION%%/${pysmurf_version}/g \
        | sed s/%%SMURF2MCE_BASE_VERSION%%/${smurf2mce_base_version}/g \
        > ${target_dir}/docker_compose.yml
if [ $? -ne 0 ]; then
    echo ""
    echo "ERROR: Could not create ${target_dir}/docker_compose.yml"
    exit 1
fi

# Create run script
copy_template "run.sh"

# create stop script
copy_template "stop.sh"

# Create env file
copy_template "env" ".env"

# Create fw directory
mkdir -p ${target_dir}/fw

# Clone pysmurf (master branch) in the target directory
git clone ${smurf2me_git_repo} ${target_dir}/smurf2mce

# Print final report
echo ""
echo "All Done!"
echo "Script released to ${target_dir}"
echo "The master branch of ${smurf2mce_git_repo} was clone in ${target_dir}/smurf2mce. That is the copy that runs inside the docker container."
echo "Remember to place your FW related files in the 'fw' directory."
echo ""