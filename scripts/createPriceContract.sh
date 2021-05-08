#!/bin/bash

../../../node/goal app create --creator ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY --app-arg "int:200" --approval-prog ../contracts/Price.teal --global-byteslices 1 --global-ints 1 --local-byteslices 1 --local-ints 1 --clear-prog ../contracts/clearprice.teal 