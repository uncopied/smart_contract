#!/bin/bash

goal clerk send --from ZIJ5DOBG3GBMRJ7CGRQENUK5Z746YXEPAATYPFRKIU3WSMEWTJJ43DOMVA --to GJ2KFYI723EMIS76SNSG3TKHDSW7322AZZJXJNV3J35B4TIQVXFXJLB3PI --amount=400000 --out unsignedSend.tx

goal asset send --amount 1 --assetid 15976209      --from ZIJ5DOBG3GBMRJ7CGRQENUK5Z746YXEPAATYPFRKIU3WSMEWTJJ43DOMVA --to XHFRWIODL7MFJNCWURZY6USPIWUZTQ2X6EWCJ7SWSRKJPUN4LYHO5XK2BY --clawback  ICQFYYDKNB6LHNLBMNWDLJBRR67ZJOBA6WEPAXZZHPIDCHMFOSL2XOSYXQ  --out unsignedAssetSend.tx

goal app call --from ZIJ5DOBG3GBMRJ7CGRQENUK5Z746YXEPAATYPFRKIU3WSMEWTJJ43DOMVA --app-id 15976210 --out unsignedPriceCall.tx

goal clerk send --from XHFRWIODL7MFJNCWURZY6USPIWUZTQ2X6EWCJ7SWSRKJPUN4LYHO5XK2BY --to ZIJ5DOBG3GBMRJ7CGRQENUK5Z746YXEPAATYPFRKIU3WSMEWTJJ43DOMVA --amount=8000000 --out unsignedSend1.tx

cat  unsignedSend.tx unsignedAssetSend.tx  unsignedPriceCall.tx unsignedSend1.tx> combinedNftTransactions.tx


goal clerk group -i combinedNftTransactions.tx -o groupedNftTransactions.tx 

goal clerk split -i groupedNftTransactions.tx -o splitNft.tx

goal clerk sign -i splitNft-1.tx --program ../contracts/uncopied.teal -o signoutNft-1.tx

goal clerk sign -i splitNft-0.tx -o signoutNft-0.tx

goal clerk sign -i splitNft-2.tx -o signoutNft-2.tx

goal clerk sign -i splitNft-3.tx -o signoutNft-3.tx

cat signoutNft-0.tx signoutNft-1.tx signoutNft-2.tx signoutNft-3.tx > signoutNft.tx

goal clerk rawsend -f signoutNft.tx


# goal clerk dryrun --dryrun-dump --txfile signoutNft.tx --outfile nftTransDryDump.json
# tealdbg debug ../contracts/Price.teal --dryrun-req  ./nftTransDryDump.json