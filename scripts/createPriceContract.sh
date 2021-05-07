#!/bin/bash

../../../node/goal app create --creator BJLWZRWS7CYNNTBNYPGGHF7ZFJU2JOCFKXZSEUTVDC4INZEW63WZ2QLIHI --app-arg "int:200" --approval-prog ./Price.teal --global-byteslices 1 --global-ints 1 --local-byteslices 1 --local-ints 1 --clear-prog ./clearprice.teal 