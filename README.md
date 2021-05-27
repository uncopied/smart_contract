# Uncopied Smart Contract (Royalties)
This is an explanation of the smart contract PROTOTYPE for the Uncopied project. Uncopied intends to issue secure 'proof of provenance' for physical and digital art (NFTs). UNCOPIED's  vision is to make original art truely unique, with physical and digitally immutable certificates of authenticity, expertise and inventory that will outlive us. The NFTs can be traded on any Algorand NFT marketplace (DEX) based on agreed standards for asset identification and metadata. This prototype is to explore how we can manage royalties ("Droit de Suite") on initial NFT transaction, but also on all future transactions. THIS IS NOT PRODUCTION-READY.

# What does this contract Achieve
The purpose of this contract is to enable royalty transactions for Uncopied and to also guide the creation of NFTs, for this purpose, the Algorand blockchain and the TEAL(Transaction Execution Approval Language) has been chosen as the desired Blockchain and smart contract language.

# Things to understand before proceeding
- A royalty transaction is a transaction that allows a creator of a content to be rewarded for his content by a buyer of such content, in our case, the content is the NFT.

- NFTs are created as ASA (Algorand Standard Assets) under the Algorand public blockchain.

- Atomic transactions are transactions that are grouped together such that if one fails, all fail.

# How do we achieve this?
We are going to solve this particular problem using an Atomic transaction that contains three transactions but first, it is good that you understand that there are two types of royalty transactions in  our case :
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
>=
byte "Price"
app_global_get
gtxn 0 AssetAmount
*
gtxn 1 Amount
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
The first three lines make sure that this transaction is being called along with at least two other transactions, the next four lines gets the price of this stateful smart contract that was stored during creation and compares it with the amount the buyer wants to pay the creator in the second transaction, the next four lines make sure that the sender of the asset in the first transaction is the same as the the creator of the contract that was stored when the contract was created. The next lines make sure that the receiver of in the second transaction is equal to the sender in the first transaction. Notice the return statement at the end, this is so that our code does not drop into the creation branch again when it is being called

Lets look at the code after our `bnz txSentFromCreator` line, this will be the case if the creator is not the one sending the asset meaning the asset is being set from someone who has bought the nft to another person, which is our second [case](#A-buyer-transferring-his-NFT)

```TEAL
global GroupSize
int 3
>=
byte "Creator"
app_global_get
gtxn 0 Receiver
==
&&
gtxn 0 Amount
int 100
*
store 10
gtxn 1 AssetAmount
int 1000000
*
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


We first make sure that the transactions are at least 3, then we check that the creator of the NFT is the receiver in the first transaction, we further take the amount in the first transaction, multipky it by 100 and divide it by the asset amount multiplied by 1000000 then check if its equal to the percent set by the creator and allow the contract call if this is the case or reject the transaction.

A simple clarification: suppose a creator sets P as the royalties percent he will receive on a transfer of a single unit of an NFT N then the function f(N) that a buyer should pay to the Creator when transferring an assset is (P/100)*N, lets call f(N) Y in our case, this means Y = (P/100)*N. This means that P should always be equal to (Y*100)/N; thats why in the code above, we multiply the amount(Y) paid to the creator by 100 and divide it by the amount(N) of NFT units transferred, but notice that we convert the units of NFT to microalgos by multiplying it by 1000000 since the amount(Y) is already in microalgos



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

1. An atomic transaction that creates an asset with default frozen true and also a stateful smart contract which stores the price of a single unit of the NFT along with the address of the creator

```bash
#AssetCreate Transaction
goal asset create  --assetmetadatab64 "16efaa3924a6fd9d3a4824799a4ac65d"  --asseturl "www.coolade.com" --creator "ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY" --decimals 0 --defaultfrozen=true --total 1000 --unitname nljh --name myas --out=unsginedtransaction1.tx

#Stateful smart contract(Application) create transaction
goal app create --creator ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY --app-arg "int:200" --approval-prog ./Price.teal --global-byteslices 2 --global-ints 2 --local-byteslices 1 --local-ints 1 --clear-prog ./clearprice.teal --out=unsginedtransaction2.tx

# group both transactions
cat unsginedtransaction1.tx unsginedtransaction2.tx  > combinedtransactions.tx

goal clerk group -i combinedtransactions.tx -o groupedtransactions.tx 

goal clerk split -i groupedtransactions.tx -o split.tx 

goal clerk sign -i split-0.tx -o signout-0.tx

goal clerk sign -i split-1.tx -o signout-1.tx

cat signout-0.tx signout-1.tx  > signout.tx

#Send grouped transaction to the network
goal clerk rawsend -f signout.tx
```

When i run the commands above on my PC presently,  the atomic transaction is successful with the following transaction IDs `LJIEJV4JAHASS2ET5ZPIOVFEJEAPRENR742ZQONKOES6AWXBFHCA`,`4XW67GEEEBVOTTDQ6XPV5QYJTLEZWRNDXFSNVBLJOCZ6GSXKIMAA`

When i inspeact both opf them on testnet.algoexplorer.io, i find out the following information

Asset Id:  15836075

Application Id : 15836076


2. A compilation of a stateless smartcontract which includes the application id of the stateful smart contract, this will give us an address.

So now, replace the application id in the uncopied.teal file with the one above(15836076) and compile it

```TEAL
goal clerk compile ./uncopied.teal
```

when i run the command above, i get `THIZCI4CIL3QM2L7FWB54SA234AZQ6CNVX7LPUIZMPLHPSBNYXGJV34PNM` as the address.

3. Funding the stateless smart contract address
you can fund the address on https://bank.testnet.algorand.network/


4. Performing an asset configuration transaction of the created asset to make the clawback address be the stateless smart contract adddress. 
Make sure to paass in the right clawback address and the asset id

```TEAL
goal asset config --manager ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY  --new-clawback  THIZCI4CIL3QM2L7FWB54SA234AZQ6CNVX7LPUIZMPLHPSBNYXGJV34PNM --assetid 15836075  
```

When i do this, i get a successful transaction with a transaction id of `YJ5YGGKVSSHSN3FLPOEMKLRZFDAFUUGGUKYALYK3UPOHZ6MTRDUQ`, feel free to inspect this id on https://testnet.algoexplorer.io/


5. Performing an opt in transaction to opt the buyer of the NFT(asset) into the asset.
Next, we need to opt in the acccount of the  buyer so he can receive the NFTs.

```TEAL

goal asset send -a 0 -f RXITXIPOANRFFN7XDYHDVLACYF6Z3RBYIZAHPEWPCK6ESDN6CUO2AYPG6I -t RXITXIPOANRFFN7XDYHDVLACYF6Z3RBYIZAHPEWPCK6ESDN6CUO2AYPG6I   --assetid 15836075 
```

After running this, i get a transaction with the following id `UVCIFPO5FZNGE3IP3RLEUYVHQDE5LI554LKPZRLVE2BMZDBCWQPQ`,feel free to inspect this id on https://testnet.algoexplorer.io/

6. An atomic transaction grouping the 3  transactions described earlier together in order to have a successful transaction. This is the final transaction where the buyer receives his NFT and the Creator receives his royalty in algo. Make sure to use the right asset id,application id and clawback address where necessary.

```TEAL
goal asset send --amount 1 --assetid 15836075   --from ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY --to RXITXIPOANRFFN7XDYHDVLACYF6Z3RBYIZAHPEWPCK6ESDN6CUO2AYPG6I --clawback  THIZCI4CIL3QM2L7FWB54SA234AZQ6CNVX7LPUIZMPLHPSBNYXGJV34PNM  --out unsignedAssetSend.tx

goal clerk send --from RXITXIPOANRFFN7XDYHDVLACYF6Z3RBYIZAHPEWPCK6ESDN6CUO2AYPG6I --to ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY --amount=200 --out unsignedSend.tx

goal app call --from ZEBCFIBJIL2GVVUU23MXID3ITD5FBYRUEJTDKEI6FDIOZCYAVYUTCXH7PY --app-id 15836076 --out unsignedPriceCall.tx

cat  unsignedAssetSend.tx unsignedSend.tx unsignedPriceCall.tx > combinedNftTransactions.tx


goal clerk group -i combinedNftTransactions.tx -o groupedNftTransactions.tx 

goal clerk split -i groupedNftTransactions.tx -o splitNft.tx

goal clerk sign -i splitNft-0.tx --program ./uncopied.teal -o signoutNft-0.tx

goal clerk sign -i splitNft-1.tx -o signoutNft-1.tx

goal clerk sign -i splitNft-2.tx -o signoutNft-2.tx

cat signoutNft-0.tx signoutNft-1.tx signoutNft-2.tx  > signoutNft.tx

goal clerk rawsend -f signoutNft.tx
```

After doing this, i get three successful transactions with ids,`U4DWJUJ55ZARGDFSH3W3N2UGJHCMOGU2QAZHXJUAGM4NYYLD5LTQ`,`CZCSVZHUF66OSJKVRN2QWIANRX7673Q7SLKHC4TA4QOKEFYZKPVA`,`ZEPB2L7R7Y2QVI3P2BXZZWUYIDUFJW3YLENOH67KV5TODTOQ6WTQ`. Meaning our transactios were successful.


Please note that this is not the final state of this program as more coditions will be added but this should be the basis of it and if this changes, this docs will be updated accordinngly.

Thanks
