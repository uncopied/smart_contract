#!/bin/bash

goal clerk send --from ZIJ5DOBG3GBMRJ7CGRQENUK5Z746YXEPAATYPFRKIU3WSMEWTJJ43DOMVA --to GJ2KFYI723EMIS76SNSG3TKHDSW7322AZZJXJNV3J35B4TIQVXFXJLB3PI --amount=200000 --out unsignedSend.tx

goal asset send --amount 1 --assetid 15925228    --from ZIJ5DOBG3GBMRJ7CGRQENUK5Z746YXEPAATYPFRKIU3WSMEWTJJ43DOMVA --to XHFRWIODL7MFJNCWURZY6USPIWUZTQ2X6EWCJ7SWSRKJPUN4LYHO5XK2BY --clawback  R4DM2LAYOLOKFKYNFWN3IRR6BUUTFMXSRPBJRMCUC6BNVYTWL5WN7PWFKA  --out unsignedAssetSend.tx

goal app call --from GJ2KFYI723EMIS76SNSG3TKHDSW7322AZZJXJNV3J35B4TIQVXFXJLB3PI --app-id 15925229 --out unsignedPriceCall.tx

cat  unsignedSend.tx unsignedAssetSend.tx  unsignedPriceCall.tx > combinedNftTransactions.tx


goal clerk group -i combinedNftTransactions.tx -o groupedNftTransactions.tx 

goal clerk split -i groupedNftTransactions.tx -o splitNft.tx

goal clerk sign -i splitNft-1.tx --program ../contracts/uncopied.teal -o signoutNft-1.tx

goal clerk sign -i splitNft-0.tx -o signoutNft-0.tx

goal clerk sign -i splitNft-2.tx -o signoutNft-2.tx

cat signoutNft-0.tx signoutNft-1.tx signoutNft-2.tx  > signoutNft.tx

goal clerk rawsend -f signoutNft.tx


# goal clerk dryrun --dryrun-dump --txfile signoutNft.tx --outfile nftTransDryDump.json
# tealdbg debug ../contracts/Price.teal --dryrun-req  ./nftTransDryDump.json