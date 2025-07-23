#!/bin/bash
##
# Run on the build service
#

set -e
set -o pipefail

quiet=false
if [[ "$1" == '--quiet' ]] ; then
    quiet=true
    shift
fi

command=$1
args=$2

# We're running only AArch32 at the moment
arch=aarch32

# How long each job runs for
timeout=30

# Files we will archive
files=(MessageTrans,ffa
       bin/messagetrans,ffc
       testdata
      )


if [[ -x './riscos-build-online' ]] ; then
    build_tool="./riscos-build-online"
elif type -p riscos-build-online > /dev/null 2>/dev/null ; then
    build_tool=$(type -p riscos-build-online)
else
    echo "The 'riscos-build-online' tool is required to run these tests" >&2
    exit 1
fi

    # Header
cat > .robuild.yaml <<EOM
%YAML 1.0
---

# Defines a list of jobs which will be performed.
# Only 1 job will currently be executed.
jobs:
  build:
    # Env defines system variables which will be used within the environment.
    # Multiple variables may be assigned.
    env:
      "Sys\$Environment": ROBuild

    # Directory to change to before running script
    dir: "${dir}"

    # Commands which should be executed to perform the build.
    # The build will terminate if any command returns a non-0 return code or an error.
    script:
      - PyromaniacDebug traceblock
EOM

# Load the module
line="RMLoad MessageTrans"
if ! $quiet ; then
    echo "      - echo *** Load module" >> .robuild.yaml
    echo "      - echo ***   $line" >> .robuild.yaml
fi
echo "      - $line" >> .robuild.yaml

# Run the necessary command
line="$command $args"
if ! $quiet ; then
    echo "      - echo *** Run test" >> .robuild.yaml
    echo "      - echo ***   $line" >> .robuild.yaml
fi
echo "      - $line" >> .robuild.yaml

build_args=()
if $quiet ; then
    build_args+=(-q)
fi

# Archive the files we want
zip -q9r /tmp/testrun.zip "${files[@]}" .robuild.yaml

# And send it off to the build system
if "$build_tool" "${build_args[@]}" -a off -A "$arch" -t "$timeout" -i /tmp/testrun.zip | sed -E -e "s/\r//g" ; then
    rc=0
else
    rc=$?
fi

# We don't need the build file any more
rm .robuild.yaml

exit "$rc"
