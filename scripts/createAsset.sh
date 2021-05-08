#!/bin/bash

#Two Transactions

#AssetCreate Transaction
../../../node/goal asset create  --assetmetadatab64 "16efaa3924a6fd9d3a4824799a4ac65d"  --asseturl "www.coolade.com" --creator "ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY" --decimals 0 --defaultfrozen=false --total 1000 --unitname nljh --name myas --out=unsginedtransaction1.tx

#Stateful smart contract create transaction
../../../node/goal app create --creator ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY --app-arg "int:200" --approval-prog ../contracts/Price.teal --global-byteslices 2 --global-ints 2 --local-byteslices 1 --local-ints 1 --clear-prog ../contracts/clearprice.teal --out=unsginedtransaction2.tx

# group both transactions
cat unsginedtransaction1.tx unsginedtransaction2.tx  > combinedtransactions.tx

../../../node/goal clerk group -i combinedtransactions.tx -o groupedtransactions.tx 

../../../node/goal clerk split -i groupedtransactions.tx -o split.tx 

../../../node/goal clerk sign -i split-0.tx -o signout-0.tx

../../../node/goal clerk sign -i split-1.tx -o signout-1.tx

cat signout-0.tx signout-1.tx  > signout.tx

../../../node/goal clerk rawsend -f signout.tx

##../../../node/goal clerk dryrun --dryrun-dump --txfile signout.tx --outfile createAssetDryDump.json
##../../../node/tealdbg debug ../contracts/Price.teal --dryrun-req  ./createAssetDryDump.json