#!/bin/sh

root=~/prod/file

cd ${root}
export PORT=3000
/usr/bin/npm start >>${root}/stdout.log 2>&1