#!/bin/bash

#Two Transactions

#AssetCreate Transaction
../../../node/goal asset create  --assetmetadatab64 "16efaa3924a6fd9d3a4824799a4ac65d"  --asseturl "www.coolade.com" --creator "BJLWZRWS7CYNNTBNYPGGHF7ZFJU2JOCFKXZSEUTVDC4INZEW63WZ2QLIHI" --decimals 0 --defaultfrozen=false --total 1000 --unitname nljh --name myas --out=unsginedtransaction1.tx

#Stateful smart contract create transaction
../../../node/goal app create --creator BJLWZRWS7CYNNTBNYPGGHF7ZFJU2JOCFKXZSEUTVDC4INZEW63WZ2QLIHI --app-arg "int:200" --approval-prog ./Price.teal --global-byteslices 2 --global-ints 2 --local-byteslices 1 --local-ints 1 --clear-prog ./clearprice.teal --out=unsginedtransaction2.tx

# group both transactions
cat unsginedtransaction1.tx unsginedtransaction2.tx  > combinedtransactions.tx

../../../node/goal clerk group -i combinedtransactions.tx -o groupedtransactions.tx 

../../../node/goal clerk split -i groupedtransactions.tx -o split.tx 

../../../node/goal clerk sign -i split-0.tx -o signout-0.tx

../../../node/goal clerk sign -i split-1.tx -o signout-1.tx

cat signout-0.tx signout-1.tx  > signout.tx

../../../node/goal clerk rawsend -f signout.tx
