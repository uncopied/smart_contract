#!/bin/bash

#Two Transactions

#AssetCreate Transaction
goal asset create  --assetmetadatab64 "16efaa3924a6fd9d3a4824799a4ac65d"  --asseturl "www.coolade.com" --creator "GJ2KFYI723EMIS76SNSG3TKHDSW7322AZZJXJNV3J35B4TIQVXFXJLB3PI" --decimals 0 --defaultfrozen=true --total 1000 --unitname nljh --name myas --out=unsginedtransaction1.tx

#Stateful smart contract create transaction
goal app create --creator GJ2KFYI723EMIS76SNSG3TKHDSW7322AZZJXJNV3J35B4TIQVXFXJLB3PI --app-arg "int:200" --app-arg "int:5" --approval-prog ../contracts/Price.teal --global-byteslices 2 --global-ints 2 --local-byteslices 1 --local-ints 1 --clear-prog ../contracts/clearprice.teal --out=unsginedtransaction2.tx

# group both transactions
cat unsginedtransaction1.tx unsginedtransaction2.tx  > combinedtransactions.tx

goal clerk group -i combinedtransactions.tx -o groupedtransactions.tx 

goal clerk split -i groupedtransactions.tx -o split.tx 

goal clerk sign -i split-0.tx -o signout-0.tx

goal clerk sign -i split-1.tx -o signout-1.tx

cat signout-0.tx signout-1.tx  > signout.tx

goal clerk rawsend -f signout.tx

##goal clerk dryrun --dryrun-dump --txfile signout.tx --outfile createAssetDryDump.json
##tealdbg debug ../contracts/Price.teal --dryrun-req  ./createAssetDryDump.json