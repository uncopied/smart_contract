#!/bin/bash

../../../node/goal asset send --amount 1 --assetid 15816987   --from ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY --to RXITXIPOANRFFN7XDYHDVLACYF6Z3RBYIZAHPEWPCK6ESDN6CUO2AYPG6I --clawback  2WUXSYEG4PCO44MQWD3UMRBX5QORHSETD7TGXXFLBZZV5GXLDST5HRV37I  --out unsignedAssetSend.tx

../../../node/goal clerk send --from RXITXIPOANRFFN7XDYHDVLACYF6Z3RBYIZAHPEWPCK6ESDN6CUO2AYPG6I --to ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY --amount=200 --out unsignedSend.tx

../../../node/goal app call --from ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY --app-id 15816988 --out unsignedPriceCall.tx

cat  unsignedAssetSend.tx unsignedSend.tx unsignedPriceCall.tx > combinedNftTransactions.tx


../../../node/goal clerk group -i combinedNftTransactions.tx -o groupedNftTransactions.tx 

../../../node/goal clerk split -i groupedNftTransactions.tx -o splitNft.tx

../../../node/goal clerk sign -i splitNft-0.tx --program ../contracts/uncopied.teal -o signoutNft-0.tx

../../../node/goal clerk sign -i splitNft-1.tx -o signoutNft-1.tx

../../../node/goal clerk sign -i splitNft-2.tx -o signoutNft-2.tx

cat signoutNft-0.tx signoutNft-1.tx signoutNft-2.tx  > signoutNft.tx

../../../node/goal clerk rawsend -f signoutNft.tx


# ../../../node/goal clerk dryrun --dryrun-dump --txfile signoutNft.tx --outfile nftTransDryDump.json
# ../../../node/tealdbg debug ../contracts/Price.teal --dryrun-req  ./nftTransDryDump.json