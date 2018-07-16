#!/bin/bash

set -euxo pipefail

GRADLE_VERSION=4.8.1
BASEDIR=$(cd $(dirname $( dirname "$0" )/..) && pwd -P)


#
#  Create patches with
#    git format-patch --stdout -1 HEAD > current_commit.patch
#
#  Apply with 
#    git am -3 --ignore-whitespace <$BASEDIR/current_commit.patch
#

cd community
echo "Community:"
git am -3 --ignore-whitespace < $BASEDIR/58cffacaa69c793ed0cd08dca62874c264184293.patch # activate tests + as-tests profiles
git am -3 --ignore-whitespace < $BASEDIR/409abc2c26269f5f66c8d0f38629b195e599b6b1.patch # .gitignore
gradle init && git add --all && git commit -m "Gradle init - convert from Maven"
echo "sed to replace providedCompile par compileOnly"
find . -name build.gradle | xargs sed -i 's/providedCompile/compileOnly/g' && git commit -a -m "replace providedCompile par compileOnly"
# echo "replace gradle wrapper version to 4.8.1 (or newer)"
# sed -i 's@services.gradle.org/distributions/.*$@services.gradle.org/distributions/gradle-4.8.1-all.zip@g' gradle/wrapper/gradle-wrapper.properties && git commit -a -m "Use latest Gradle wrapper version"
echo "XSD generation"
git am -3 --ignore-whitespace < $BASEDIR/9e4bb1ab215a97a48632589f7128b19ce9e7d061.patch # xsd generation
git am -3 --ignore-whitespace < $BASEDIR/7f3f57de9e389f589bc383654422f84a3cf7cec4.patch # version.properties file generation
git am -3 --ignore-whitespace < $BASEDIR/5a4b586048fc254ce48bb7b7c88b912807fc20b1.patch # fix various tests
git am -3 --ignore-whitespace < $BASEDIR/7fa5f7eb3e0152b480a8ea445497f18894ec1cb7.patch # run integration test in a specific task
git am -3 --ignore-whitespace < $BASEDIR/bab1e9917c4f355c268fe2fe73bec66ca2cf9b4e.patch # fix business data module dependnecies
git am -3 --ignore-whitespace < $BASEDIR/11162e273a87ed8d30f1b98a1e9a4de2bc0c604d.patch # fix hibernate tests
git am -3 --ignore-whitespace < $BASEDIR/34d4b6fadfc5d93978eb1957119959e08c6db8c3.patch # fix bdm tests
git am -3 --ignore-whitespace < $BASEDIR/08c5c97bfe7dcfe83c21b575676fdaca18cbc336.patch # compile security scripts
git am -3 --ignore-whitespace < $BASEDIR/0b4c4616470f18fcea15e132d8960d41e8a763f7.patch # ignore test shade
git am -3 --ignore-whitespace < $BASEDIR/b170919763d65529d37d509ed3fcf08da82ce46b.patch # fix ejb tests
git am -3 --ignore-whitespace < $BASEDIR/1b30f9d4042acfc1bab8d2242ab690c7c3c5d9e1.patch # fix http api test
git am -3 --ignore-whitespace < $BASEDIR/f3c3e992cb7dfab30f8ca9519c4259744ac74373.patch # restore platform-setup zip file (previously from Assembly)
git am -3 --ignore-whitespace < $BASEDIR/906b72837ba9910dbc4db32f5df7d1138e5a4cf2.patch # javadoc(BOS): generate javadoc for all Community

find . -name "*.gradle" -type f | xargs sed -i "s/':bonita-platform/':platform/g"
git commit -a -m "rename bonita-platform by platform"
mv settings.gradle engine-settings.gradle
sed -i '/project(/d' engine-settings.gradle
sed -i '/rootProject/d' engine-settings.gradle
find . -name "*.gradle" -type f | xargs sed -ri "s/':([^ ])/':engine:\1/g"
git add --all &&  git commit -a -m "extract community settings gradle"

git am -3 --ignore-whitespace < $BASEDIR/09c0d50f8856f3f5e2004810cbd937e2bd89f3a0.patch # new settings.gradle
git am -3 --ignore-whitespace < $BASEDIR/7a3d7bdf12e8dda455679751e26e45c9e3ec0bfc.patch # do not apply Java plugin to root project Community

cd ..
echo "Subscription:"
git am -3 --ignore-whitespace < $BASEDIR/253d1fbb8b1ee89bc07f096dc6ea33c645bc4ebc.patch # activate as-tests and tests by default
gradle init
find . -name "build.gradle.bak" -exec rm {} \;
git checkout -- community/
# git commit gradle init
find . -name "*.gradle" -type f | xargs sed -i 's/:bonita-engine:bonita-engine-sp/:subscription/g'
find . -name "*.gradle" -type f | xargs sed -i 's/:bonita-engine:bonita-platform:bonita-platform-sp/:subscription:platform/g'
sed -i "/include ':bonita-engine:/d" settings.gradle
sed -i "/project(/d" settings.gradle
find subscription/ -name "*.gradle" -type f | xargs sed -i 's/:bonita-engine/:engine/g'
find subscription/ -name "*.gradle" -type f | xargs sed -i 's/:engine:bonita-platform/:engine:platform/g'
find . -name "*.gradle" -type f | xargs sed -ri 's/:subscription:bonita-integration-tests-sp:bonita-integration-tests-(.*)-sp/:subscription:bonita-integration-tests-sp:bonita-integration-tests-\1/g' # fix modules with name different that folder name
git add --all && git commit -m "Gradle init SP"

git am -3 --ignore-whitespace < $BASEDIR/3c63d54bdac3eacff0662aec8ab25cc62ea2b7b5.patch # Fix SP settings.gradle

echo "sed to replace providedCompile par compileOnly"
find subscription/ -name build.gradle | xargs sed -i 's/providedCompile/compileOnly/g' && git commit -a -m "replace providedCompile par compileOnly SP"
sed -i "s/Compatibility = 1\.5/Compatibility = 1.8/g" build.gradle && git commit -a -m "Set Java source and target to 1.8"
# comment that temporary: bad conf on baptiste side
#git am -3 --ignore-whitespace < $BASEDIR/cef8cc18bffa7a337cdfd20323135b7f553bf72e.patch # Fix root build.gradle about maven repo
git am -3 --ignore-whitespace < $BASEDIR/025d3d16167df1b54da7dab8625a893ae23c555c.patch # Restore SP licences / integration + slow tests (still 2 AccessControl tests failing)
git am -3 --ignore-whitespace < $BASEDIR/695523dd513f9a68e2ef9a81e325d7e643273d66.patch # Restore Junit 5 test run
git am -3 --ignore-whitespace < $BASEDIR/setup-distrib.patch # platform setup bos + sp
git am -3 --ignore-whitespace < $BASEDIR/it_tests.patch # run as tests as IT
git am -3 --ignore-whitespace < $BASEDIR/compile_only.patch # fix dependencies in test
git am -3 --ignore-whitespace < $BASEDIR/jaxb_access_control.patch # generate xsd for access control
git am -3 --ignore-whitespace < $BASEDIR/80cef1ca94bd074c3eb3f156d1beb0ac60262b3d.patch # Restore test BonitaClientXMLTest
git am -3 --ignore-whitespace < $BASEDIR/jenkinsfile.patch # update jenkins file
git am -3 --ignore-whitespace < $BASEDIR/it_test_cluster.patch # it tests cluster
git am -3 --ignore-whitespace < $BASEDIR/it_test_plugin.patch # extract license plugin
git am -3 --ignore-whitespace < $BASEDIR/fix_it_compile.patch # some fix on integration tests
git am -3 --ignore-whitespace < $BASEDIR/fix_distrib_it_sp.patch # distrib sp test fix
git am -3 --ignore-whitespace < $BASEDIR/fix_getplaformversion.patch # get getPlatformVersion
git am -3 --ignore-whitespace < $BASEDIR/test_memory.patch # test memory
git am -3 --ignore-whitespace < $BASEDIR/utf-8.patch # test memory
