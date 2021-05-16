#!/bin/bash

goal asset send --amount 1 --assetid 15836075   --from ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY --to RXITXIPOANRFFN7XDYHDVLACYF6Z3RBYIZAHPEWPCK6ESDN6CUO2AYPG6I --clawback  THIZCI4CIL3QM2L7FWB54SA234AZQ6CNVX7LPUIZMPLHPSBNYXGJV34PNM  --out unsignedAssetSend.tx

goal clerk send --from RXITXIPOANRFFN7XDYHDVLACYF6Z3RBYIZAHPEWPCK6ESDN6CUO2AYPG6I --to ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY --amount=200 --out unsignedSend.tx

goal app call --from ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY --app-id 15836076 --out unsignedPriceCall.tx

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