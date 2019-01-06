#!/usr/bin/env bash

## Shell Opts ----------------------------------------------------------------
set -e -u -x

## Vars ----------------------------------------------------------------------
export ANSIBLE_PACKAGE=${ANSIBLE_PACKAGE:-"ansible==2.1.0"}
export ANSIBLE_ROLE_FILE=${ANSIBLE_ROLE_FILE:-"requirements.yml"}
export SSH_DIR=${SSH_DIR:-"/root/.ssh"}
export DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-"noninteractive"}

# Set the role fetch mode to any option [galaxy, git-clone]
export ANSIBLE_ROLE_FETCH_MODE=${ANSIBLE_ROLE_FETCH_MODE:-galaxy}

# virtualenv vars
VIRTUALENV_OPTIONS="--always-copy"

# This script should be executed from the root directory of the cloned repo
cd "$(dirname "${0}")/.."

# Store the clone repo root location
export OSA_CLONE_DIR="$(pwd)"

# Set the variable to the role file to be the absolute path
ANSIBLE_ROLE_FILE="$(readlink -f "${ANSIBLE_ROLE_FILE}")"
#OSA_INVENTORY_PATH="$(readlink -f playbooks/inventory)"
#OSA_PLAYBOOK_PATH="$(readlink -f playbooks)"

STARTTIME="${STARTTIME:-$(date +%s)}"
#PIP_INSTALL_OPTIONS=${PIP_INSTALL_OPTIONS:-'pip==9.0.1 setuptools==33.1.1 wheel==0.29.0 '}
PIP_INSTALL_OPTIONS=${PIP_INSTALL_OPTIONS:-'pip==8.1.2 setuptools==33.1.1 wheel==0.24.0 '}

function ssh_key_create {
  # Ensure that the ssh key exists and is an authorized_key
  key_path="${HOME}/.ssh"
  key_file="${key_path}/id_rsa"

  # Ensure that the .ssh directory exists and has the right mode
  if [ ! -d ${key_path} ]; then
    mkdir -p ${key_path}
    chmod 700 ${key_path}
  fi
  if [ ! -f "${key_file}" -a ! -f "${key_file}.pub" ]; then
    rm -f ${key_file}*
    ssh-keygen -t rsa -f ${key_file} -N ''
  fi

  # Ensure that the public key is included in the authorized_keys
  # for the default root directory and the current home directory
  key_content=$(cat "${key_file}.pub")
  if ! grep -q "${key_content}" ${key_path}/authorized_keys; then
    echo "${key_content}" | tee -a ${key_path}/authorized_keys
  fi
}

# Determine the distribution we are running on, so that we can configure it
# appropriately.
function determine_distro {
    source /etc/os-release 2>/dev/null
    export DISTRO_ID="${ID}"
    export DISTRO_NAME="${NAME}"
    export DISTRO_VERSION_ID="${VERSION_ID}"
}

function get_pip {

  # check if pip is already installed
  if [ "$(which pip)" ]; then

    # make sure that the right pip base packages are installed
    # If this fails retry with --isolated to bypass the repo server because the repo server will not have
    # been updated at this point to include any newer pip packages.
    pip install --upgrade ${PIP_INSTALL_OPTIONS} || pip install --upgrade --isolated ${PIP_INSTALL_OPTIONS}

    # Ensure that our shell knows about the new pip
    hash -r pip

  # when pip is not installed, install it
  else
    # Try getting pip from bootstrap.pypa.io as a primary source
    curl --silent https://bootstrap.pypa.io/get-pip.py > /opt/get-pip.py
    # Try the get-pip.py from the github repository as a primary source
    #curl --silent https://raw.githubusercontent.com/pypa/get-pip/master/get-pip.py > /opt/get-pip.py
    if head -n 1 /opt/get-pip.py | grep python; then
      python /opt/get-pip.py ${PIP_INSTALL_OPTIONS}
      return
    fi

    echo "A suitable download location for get-pip.py could not be found."
    exit 1
  fi
}

# Create the ssh dir if needed
ssh_key_create

# Determine the distribution which the host is running on
determine_distro

# Install the base packages
case ${DISTRO_ID} in
    centos|rhel)
        yum -y install git python2 curl autoconf gcc-c++ \
          python2-devel gcc libffi-devel nc openssl-devel \
          python-pyasn1 pyOpenSSL python-ndg_httpsclient \
          python-netaddr python-prettytable python-crypto PyYAML \
          python-virtualenv
          VIRTUALENV_OPTIONS=""
        ;;
    ubuntu)
        apt-get update
        DEBIAN_FRONTEND=noninteractive apt-get -y install \
          git python-all python-dev curl python2.7-dev build-essential \
          libssl-dev libffi-dev netcat python-requests python-openssl python-pyasn1 \
          python-netaddr python-prettytable python-crypto python-yaml \
          python-virtualenv
        ;;
esac

# NOTE(mhayden): Ubuntu 16.04 needs python-ndg-httpsclient for SSL SNI support.
#                This package is not needed in Ubuntu 14.04 and isn't available
#                there as a package.
if [[ "${DISTRO_ID}" == 'ubuntu' ]] && [[ "${DISTRO_VERSION_ID}" == '16.04' ]]; then
  DEBIAN_FRONTEND=noninteractive apt-get -y install python-ndg-httpsclient
fi

# Install pip
get_pip

# Ensure we use the HTTPS/HTTP proxy with pip if it is specified
PIP_OPTS=""
if [ -n "$HTTPS_PROXY" ]; then
  PIP_OPTS="--proxy $HTTPS_PROXY"
elif [ -n "$HTTP_PROXY" ]; then
  PIP_OPTS="--proxy $HTTP_PROXY"
fi

# Figure out the version of python is being used
PYTHON_EXEC_PATH="$(which python2 || which python)"

# Create a Virtualenv for the Ansible runtime
virtualenv --clear ${VIRTUALENV_OPTIONS} --python="${PYTHON_EXEC_PATH}" /opt/ansible-runtime

# The vars used to prepare the Ansible runtime venv
PIP_OPTS+=" --upgrade"
PIP_COMMAND="/opt/ansible-runtime/bin/pip"

# When upgrading there will already be a pip.conf file locking pip down to the
# repo server, in such cases it may be necessary to use --isolated because the
# repo server does not meet the specified requirements.

# Ensure we are running the required versions of pip, wheel and setuptools
${PIP_COMMAND} install ${PIP_OPTS} ${PIP_INSTALL_OPTIONS} || ${PIP_COMMAND} install ${PIP_OPTS} --isolated ${PIP_INSTALL_OPTIONS}

# Set the location of the constraints to use for all pip installations
# HEAD of "stable/ocata" as of 30.06.2017
export UPPER_CONSTRAINTS_FILE=${UPPER_CONSTRAINTS_FILE:-"https://git.openstack.org/cgit/openstack/requirements/plain/upper-constraints.txt?id=edfe95166953bef860831751dfd1fc0764acf29f"}

# Set the constraints now that we know we're using the right version of pip
PIP_OPTS+=" --constraint global-requirement-pins.txt --constraint ${UPPER_CONSTRAINTS_FILE}"

# Install the required packages for ansible
$PIP_COMMAND install $PIP_OPTS -r requirements.txt ${ANSIBLE_PACKAGE} || $PIP_COMMAND install --isolated $PIP_OPTS -r requirements.txt ${ANSIBLE_PACKAGE}

