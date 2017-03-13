set -ex

if [[ ! -z $TOXENV ]]; then
  . jdk_switcher.sh && jdk_switcher use oraclejdk8
fi

if [[ $TOXENV == *"remote"* ]]; then
  ./go selenium-server-standalone
fi

if [[ ! -z $TOXENV ]]; then
  py.test -v -s -n=auto --driver=Chrome
fi

if [[ ! -z $TASK ]]; then
  ./go $TASK
fi
