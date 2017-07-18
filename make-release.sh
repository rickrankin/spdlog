#!/usr/local/bin/bash

#
# Script to create a SAIFE release and upload it to Nexus.
#

# SAIFE revision number. May want to increment when new SAIFE-specific changes are made. This will
# be appended to the base library version number, preceded by a hyphen, i.e.,
# <libraryVersion>-<saifeRevision>. For example, if the library version is 1.2.3 and saifeRevision
# is 3, then the version uploaded to Nexus would be 1.2.3-3
saifeRevision="1"

# Shouldn't need to change anything below this line

function run
{
  echo "Running $@"
  "$@" || exit 1
}

function get-spdlog-version
{
  grep -P "^\s*#\s*define\s+SPDLOG_VERSION" include/spdlog/spdlog.h | \
    awk '{match($0, /"([[:digit:]]+(\.[[:digit:]]+)+)"/, arr); print arr[1]}'
}

if [[ ! -d build ]]; then
  mkdir build || exit 1
fi

(
  cd build || exit 1
  run cmake ..
  run make
  run make test
)

repoUrl="http://azsd-build01.medusa.com:8081/nexus/content/repositories/thirdparty"
repoId="thirdparty"
artifactId="spdlog"
groupId="net.sf.$artifactId"
classifier="$artifactId-include"
version="$(get-spdlog-version)-$saifeRevision"
archive="$artifactId.zip"

rm -f "$archive"
run zip -r9 -x"include/spdlog/fmt/bundled/*" "$archive" include

run /usr/local/bin/mvn \
  deploy:deploy-file \
  -Dfile="$archive" \
  -DgroupId="$groupId" \
  -DartifactId="$artifactId" \
  -Dversion="$version" \
  -Dclassifier="$classifier" \
  -Dpackaging=zip \
  -Durl="$repoUrl" \
  -DrepositoryId="$repoId"

rm -f "$archive"
