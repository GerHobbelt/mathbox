#!/bin/bash

BASE_DIR="$(dirname $0)/.."

echo ""
echo "Starting phantomJS (http://phantomjs.org/)"
echo "-------------------------------------------------------------------"

phantomjs $BASE_DIR/test/TestRunner.js $*
