set -ex

if [[ ! -z $TOXENV ]]; then
  . jdk_switcher.sh && jdk_switcher use oraclejdk8
fi

if [[ $TOXENV == *"remote"* ]]; then
  ./go selenium-server-standalone
fi

if [[ ! -z $TOXENV ]]; then
  pip install pytest
  pip install pytest-instafail
  ./go py_prep_for_install_release
  python setup.py install
  py.test -v -s --driver=Chrome
fi

if [[ ! -z $TASK ]]; then
  ./go $TASK
fi
