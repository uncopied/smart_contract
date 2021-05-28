# Uncopied Smart Contract (Royalties)
This is an explanation of the smart contract PROTOTYPE for the Uncopied project. Uncopied intends to issue secure 'proof of provenance' for physical and digital art (NFTs). UNCOPIED's  vision is to make original art truely unique, with physical and digitally immutable certificates of authenticity, expertise and inventory that will outlive us. The NFTs can be traded on any Algorand NFT marketplace (DEX) based on agreed standards for asset identification and metadata. This prototype is to explore how we can manage royalties ("Droit de Suite") on initial NFT transaction, but also on all future transactions. THIS IS NOT PRODUCTION-READY.

# What does this contract Achieve
The purpose of this contract is to enable royalty transactions for Uncopied and to also guide the creation of NFTs, for this purpose, the Algorand blockchain and the TEAL(Transaction Execution Approval Language) has been chosen as the desired Blockchain and smart contract language.

# Things to understand before proceeding
- A royalty transaction is a transaction that allows a creator of a content to be rewarded for his content by a buyer of such content, in our case, the content is the NFT.

- NFTs are created as ASA (Algorand Standard Assets) under the Algorand public blockchain.

- Atomic transactions are transactions that are grouped together such that if one fails, all fail.

# How do we achieve this?
We are going to solve this particular problem using an Atomic transaction that contains three transactions and another that contains four transactions, but first, it is good that you understand that there are two types of royalty transactions in  our case :
1. A creator selling his NFT to a buyer.
2. A buyer giving or selling his NFT to a new Buyer

# A creator selling his NFT to a buyer.
## What are the 3 transactions for this case?
1. The first transaction is an Asset Transfer Transaction that transfers the NFT(Asset) from the creator to the buyer of the NFT

2. The second transaction is a Payment Transaction from the Buyer of the NFT to the creator of the NFT ; this transaction alllows the buyer of the NFT to pay or reward (send royalties to) the creator of the NFT

3. A call to a stateful smart contract, which confirms that the amount the buyer of the NFT pays in transaction 2 is the correct amount set by the creator and that the buyer of the NFT is also sending this amount to the right creator.

# A buyer transferring  his NFT
1. The first transaction sends the royalties to the creator
2. The second transaction sends the NFT to the new buyer.
3. The third transaction is a call to the stateful smart contract
4. The fourth transaction is the transaction where the new buyer pays the previous buyer for the NFT.

# Order Of Transactions For A Royalty Transaction To Take Place
- An atomic transaction that creates an asset with default frozen true and also a stateful smart contract which stores the price of a single unit of the NFT, the percentage gain on any transfer of this NFT along with the address of the creator

- A compilation of a stateless smartcontract  which includes the application id of the stateful smart contract, this will give us an address.

- Funding the stateless smart contract address.

- Performing an asset configuration transaction of the created asset to make the clawback address be the stateless smart contract adddress

- Performing an opt in transaction to opt the buyer of the NFT(asset) into the asset
- An atomic transaction grouping the 3  transactions described earlier together in order to have a successful transaction

# Code And Explanation
## Stateful Smart Contract
A stateful smart contract allows us to store certain values on the algorand blockchain, for our use case, we will be storing the price of the NFT along with the address of the creator of the NFT. Lets write the TEAL code for this in a file and call it Price.teal

```TEAL
#pragma version 3
int 0
txn ApplicationID
==
bnz creation
```
the first line  defines the version of the Teal programming language we are using. In our case, its version 3, the next three lines load 0 and the current application ID to the stack and compare them, this returns 1 if they are equal and 0 if they are not. Make sure to note that for a stateful smart contract that is just being created, the Application ID is always 0, so with this, we can always specify the actions we intend to take when our Stateful smart conmtract is just being created. so the fourth line in the code above uses the `bnz`(Branch Not Zero) command to jump to a branch in our code called creation if the comparism is not zero(false). And when we call this Teal program for the first time, the comparism of 0 and the application id will definitely be zero since it is just being created. So lets proceed to create this branch of our code called creation.

```TEAL
creation:
byte "Creator"
txn Sender
app_global_put
byte "Price"
gtxna 1 ApplicationArgs 0
btoi
app_global_put
byte "Percent"
gtxna 1 ApplicationArgs 1
btoi
app_global_put
global GroupSize
int 2
>=
gtxn 0 TypeEnum
int acfg
==
&&
gtxn 0 ConfigAssetDefaultFrozen
int 1
==
&&
return
```

The first line above is what allows the Teal runtime to know that the codes after that line are a part of the `creation` branch, the second to fourth line save the Address of the Creator of the NFT, the fifth to eighth line save the Price of the NFT; we assume that the price is in microalgos. The nineth to 12th line saves the percent the creator wants to receive on each transfer of this asset, the thirteenth to  seventeenth line make sure that the stateful smart contract is created along with an asset, the eighteenth to Twentieth line make sure that the asset is frozen by default. Thats presently all for our Stateful smart contract creation logic, let's look at the rest of our code after the `bnz creation` line earlier:

```TEAL
int UpdateApplication
txn OnCompletion
==
bnz updateApp
```
In the code above, we check if the application is being updated and we send program execution to the `updateApp` branch, lets take a look at this branch

```TEAL
updateApp:
byte "Creator"
app_global_get
txn Sender
==
return
```
The `updateApp` branch simply checks if the creator of the contract is the one calling the contract and allows the app(contract) to be updated, if not, it doesnt allow the app to be updated.

Lets proceed with our code after the `bnz updateApp` Line:
```TEAL
int DeleteApplication
txn OnCompletion
==
bnz DeleteApp
```
In the code above, we check if the application(contract) is being deleted and we send program execution to the `DeleteApp` branch, lets take a look at this branch

```TEAL
DeleteApp:
byte "Creator"
app_global_get
txn Sender
==
return
```
The `DeleteApp` branch simply checks if the creator of the contract is the one calling the contract and allows the app(contract) to be deleted, if not, it doesnt allow the app to be deleted.

Lets proceed with our code after the `bnz DeleteApp` Line:
```TEAL
byte "Creator"
app_global_get
gtxn 0 AssetSender
==
bnz txSentFromCreator
```
For you to understand the code above, you need to remember that we have two kinds of royalty transactions in our [case](#How-do-we-achieve-this?), that line above decides which of them it is. We check if the asset sender is equal to the creator which is the case when the creator is the one selling the asset to a buyer and then we move to a branch called `txSentFromCreator`. Lets look at the code in this branch:

```TEAL
txSentFromCreator:
global GroupSize
int 3
==
byte "Price"
app_global_get
gtxn 1 Amount
==
&&
gtxn 0 AssetAmount
int 1 
==
&&
byte "Creator"
app_global_get
gtxn 0 AssetSender
==
&&
gtxn 1 Receiver
gtxn 0 AssetSender
==
&&
return

```
The first three lines make sure that this transaction is being called along with at least two other transactions, the next four lines gets the price of this stateful smart contract that was stored during creation and compares it with the amount the buyer wants to pay the creator in the second transaction, the next three lines make sure its  a single unit of this asset that is being transferred, and the next four lines make sure that the sender of the asset in the first transaction is the same as the the creator of the contract that was stored when the contract was created. The next lines make sure that the receiver of in the second transaction is equal to the sender in the first transaction. Notice the return statement at the end, this is so that our code does not drop into the creation branch again when it is being called

Lets look at the code after our `bnz txSentFromCreator` line, this will be the case if the creator is not the one sending the asset meaning the asset is being set from someone who has bought the nft to another person, which is our second [case](#A-buyer-transferring-his-NFT)

```TEAL
global GroupSize
int 4
==
byte "Creator"
app_global_get
gtxn 0 Receiver
==
&&
gtxn 0 Amount
int 100
*
store 10
gtxn 3 Amount
store 11
load 10
load 11
/
byte "Percent"
app_global_get
==
&&
return

```


We first make sure that there are at least 4 transactions, then we check that the creator of the NFT is the receiver in the first transaction, we further take the amount in the first transaction, multipky it by 100 and divide it by the amount the new buyer is paying for it, then check if its equal to the percent set by the creator and allow the contract call to take place if this is the case or reject the transaction.

A simple clarification: suppose a creator sets `P` as the royalties percent he will receive on a transfer of a single unit of an NFT at a variable price `A` then the function f(A) that a buyer should pay to the Creator when transferring an assset is `(P/100)*A`, lets call f(A) `Y` in our case, this means `Y = (P/100)*A`. This means that `P` should always be equal to` (Y*100)/A`; thats why in the code above, we multiply the amount(Y) paid to the creator by 100 and divide it by the amount(A) that the new buyer is willing to pay for the NFT.



And that's all for our stateful smart contract.

## Stateless Smart Contract
Lets create a file and call it uncopiedl.teal, this file will house our stateless smart contract which when compiled will be used as our clawback address, lets look at the code for this file

```TEAL
#pragma version 3
txn Fee
int 10000
<=
global GroupSize
int 3
==
&&
gtxn 2 TypeEnum
int appl
==
&&
gtxn 2 ApplicationID
int 15831798
==
&&
```

So we first make sure the transaction fee is not more than 10000 micro algos so a malicious party does not try to exhaust our funds by setting a high transaction fee, we make sure this transaction is grouoed with three other transactions, then we make sure the third transaction is an application call transaction and lastly we check if the application id of the third transaction is equal to the application id of our stateful smart contract address, the nos `15831798` should be changed to the application id of the stateful smart contract before this is compiled, a simple find and replace trasaction with any programming language should do this fine.

# Transactions Demo

So now, let's try to run through the [order of transactions](#Order-Of-Transactions-For-A-Royalty-Transaction-To-Take-Place) above using the goal command line tool.

1. An atomic transaction that creates an asset with default frozen true and also a stateful smart contract which stores the price of a single unit of the NFT, the percent gain on each transfer of the NFT along with the address of the creator

```bash
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
```

When i run the commands above on my PC presently,  the atomic transaction is successful with the following transaction IDs `Q7NRICFGOME4R3SY465Y7Y62LECSYLGR4PF5MJ2XK54QFA56RWEA`,`MAZ7FBB2LVZFPZKNSOYFHX6SZ6HW7WUMLPKUOC2AKLQLQVG2LXCQ`

When i inspeact both opf them on testnet.algoexplorer.io, i find out the following information

Asset Id:  15976209

Application Id : 15976210


2. A compilation of a stateless smartcontract which includes the application id of the stateful smart contract, this will give us an address.

So now, replace the application id in the uncopied.teal file with the one above(15836076) and compile it

```bash
goal clerk compile ./uncopied.teal
```

when i run the command above, i get `ICQFYYDKNB6LHNLBMNWDLJBRR67ZJOBA6WEPAXZZHPIDCHMFOSL2XOSYXQ` as the address.

3. Funding the stateless smart contract address
you can fund the address on https://bank.testnet.algorand.network/


4. Performing an asset configuration transaction of the created asset to make the clawback address be the stateless smart contract adddress. 
Make sure to paass in the right clawback address and the asset id

```bash
goal asset config --manager GJ2KFYI723EMIS76SNSG3TKHDSW7322AZZJXJNV3J35B4TIQVXFXJLB3PI  --new-clawback  ICQFYYDKNB6LHNLBMNWDLJBRR67ZJOBA6WEPAXZZHPIDCHMFOSL2XOSYXQ --assetid 15976209     

```

When i do this, i get a successful transaction with a transaction id of `O7ULQ3WZBCWPFJGNVFK6O6H5BTXMWRMNXRYABFTQ6EG6HWRBWJ2A`, feel free to inspect this id on https://testnet.algoexplorer.io/


5. Performing an opt in transaction to opt the buyer of the NFT(asset) into the asset.
Next, we need to opt in the acccount of the  buyer so he can receive the NFTs.

```bash


goal asset send -a 0 -f ZIJ5DOBG3GBMRJ7CGRQENUK5Z746YXEPAATYPFRKIU3WSMEWTJJ43DOMVA -t ZIJ5DOBG3GBMRJ7CGRQENUK5Z746YXEPAATYPFRKIU3WSMEWTJJ43DOMVA   --assetid 15976209  
```

After running this, i get a transaction with the following id `GA5CXWNPFOESYOPFQB6JRHGAC2I57H7QKMRTDWUN3B3F73G4CXFQ`,feel free to inspect this id on https://testnet.algoexplorer.io/

6. An atomic transaction grouping the 3  transactions described earlier together in order to have a successful transaction. This is the final transaction where the buyer receives his NFT and the Creator receives his royalty in algo. Make sure to use the right asset id,application id and clawback address where necessary.

```bash
goal asset send --amount 1 --assetid 15976209      --from GJ2KFYI723EMIS76SNSG3TKHDSW7322AZZJXJNV3J35B4TIQVXFXJLB3PI --to ZIJ5DOBG3GBMRJ7CGRQENUK5Z746YXEPAATYPFRKIU3WSMEWTJJ43DOMVA --clawback  ICQFYYDKNB6LHNLBMNWDLJBRR67ZJOBA6WEPAXZZHPIDCHMFOSL2XOSYXQ  --out unsignedAssetSend.tx

goal clerk send --from ZIJ5DOBG3GBMRJ7CGRQENUK5Z746YXEPAATYPFRKIU3WSMEWTJJ43DOMVA --to GJ2KFYI723EMIS76SNSG3TKHDSW7322AZZJXJNV3J35B4TIQVXFXJLB3PI --amount 200 --out unsignedSend.tx

goal app call --from GJ2KFYI723EMIS76SNSG3TKHDSW7322AZZJXJNV3J35B4TIQVXFXJLB3PI --app-id 15976210 --out unsignedPriceCall.tx

cat  unsignedAssetSend.tx unsignedSend.tx unsignedPriceCall.tx > combinedNftTransactions.tx


goal clerk group -i combinedNftTransactions.tx -o groupedNftTransactions.tx 

goal clerk split -i groupedNftTransactions.tx -o splitNft.tx

goal clerk sign -i splitNft-0.tx --program ../contracts/uncopied.teal -o signoutNft-0.tx

goal clerk sign -i splitNft-1.tx -o signoutNft-1.tx

goal clerk sign -i splitNft-2.tx -o signoutNft-2.tx

cat signoutNft-0.tx signoutNft-1.tx signoutNft-2.tx  > signoutNft.tx

goal clerk rawsend -f signoutNft.tx
```

After doing this, i get three successful transactions with ids,

`NVFEU6JNH75FZQP225XZ2BWBLZ5XSWL7QSDQLHGA6WTRYGR5Q7PA`,`55BLHPRPPIC6ATSEK3BYGXDBX76AXRX37WJCC3N67O44SGU6DUZA`,`ZZUFQZRLFQY4ZNEQS2MMYJUIUUDRM2IO5ORZ5BNMVAJQHM5O4DSQ`. 

Meaning our transactions were successful.


Up next is the second type of royalty transaction, where someone who has already bought the NFT sends it to a new buyer:

The first step here is to opt the new user into the nft:

```bash
goal asset send -a 0 -f XHFRWIODL7MFJNCWURZY6USPIWUZTQ2X6EWCJ7SWSRKJPUN4LYHO5XK2BY -t XHFRWIODL7MFJNCWURZY6USPIWUZTQ2X6EWCJ7SWSRKJPUN4LYHO5XK2BY   --assetid 15974170  
```
I get a successful transaction with the transaction id : `BRN36EU7YQCXSJAK6QT6OHRERN6N5KXGN7CXE52467R7G4GPEAYQ`

Then we can send the new buyer the NFT while also sending the percent of the amount transferred to the Creator :
```bash

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


```
In the example above we send 3 units of our nft, and this application(15974171) requires  5% of the units transferred to the Creator, which is 0.15 algo and equivalent to 150000 micro algos, thats why we send 150000 micro algo to the creator.
After doing this, i get three successful transactions with ids,

`3IYXCSI52UIYHUE6N3FY7IV23E4UQKQN3MXB4SRXBXMBLCSLFGUA`,`C45KBKU3D4XYHPSRGLI2NR3EBHN5GQC2NNQV3UJD3MULXXG3QU4A`,`WUXNXQV3ONGYIE4IXAMI2HTI3IZZEOWRORP64BRDVCSIRQXT6UPQ`,`4NECDEJIW7HRQT7HNXJYIHTM3F5LWKJNSDDWN2PQZYQSJXSTMKNA`. 

Meaning our transactions were successful and our contracts work as expected.


Please note that this is not the final state of this program as more coditions will be added but this should be the basis of it and if this changes, this docs will be updated accordinngly.

Thanks
