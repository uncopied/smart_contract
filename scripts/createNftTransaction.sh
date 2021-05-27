#!/bin/bash

goal asset send --amount 6 --assetid 15974170      --from GJ2KFYI723EMIS76SNSG3TKHDSW7322AZZJXJNV3J35B4TIQVXFXJLB3PI --to ZIJ5DOBG3GBMRJ7CGRQENUK5Z746YXEPAATYPFRKIU3WSMEWTJJ43DOMVA --clawback  DSGXLVOW7ZBNNJZACQVF4CYTVCI2NVW5LVRN2CXOQ6C2TPNZMYAXZS3NTI  --out unsignedAssetSend.tx

goal clerk send --from ZIJ5DOBG3GBMRJ7CGRQENUK5Z746YXEPAATYPFRKIU3WSMEWTJJ43DOMVA --to GJ2KFYI723EMIS76SNSG3TKHDSW7322AZZJXJNV3J35B4TIQVXFXJLB3PI --amount=1200 --out unsignedSend.tx

goal app call --from GJ2KFYI723EMIS76SNSG3TKHDSW7322AZZJXJNV3J35B4TIQVXFXJLB3PI --app-id 15974171 --out unsignedPriceCall.tx

cat  unsignedAssetSend.tx unsignedSend.tx unsignedPriceCall.tx > combinedNftTransactions.tx


goal clerk group -i combinedNftTransactions.tx -o groupedNftTransactions.tx 

goal clerk split -i groupedNftTransactions.tx -o splitNft.tx

goal clerk sign -i splitNft-0.tx --program ../contracts/uncopied.teal -o signoutNft-0.tx

goal clerk sign -i splitNft-1.tx -o signoutNft-1.tx

goal clerk sign -i splitNft-2.tx -o signoutNft-2.tx

cat signoutNft-0.tx signoutNft-1.tx signoutNft-2.tx  > signoutNft.tx

goal clerk rawsend -f signoutNft.tx


# goal clerk dryrun --dryrun-dump --txfile signoutNft.tx --outfile nftTransDryDump.json
# tealdbg debug ../contracts/Price.teal --dryrun-req  ./nftTransDryDump.json