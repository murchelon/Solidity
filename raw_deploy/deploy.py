
from solcx import compile_standard, install_solc
import json
from web3 import Web3
import os
from dotenv import load_dotenv


load_dotenv()

deploy_to = "RINKEBY" # RINKEBY | GANACHE

with open ("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()
    # print(simple_storage_file)

# Compile
install_solc("0.6.0")
compiled_sol = compile_standard({
    "language": "Solidity",
    "sources": {"SimpleStorage.sol": {"content" : simple_storage_file}},
    "settings": {
        "outputSelection": {
            "*": {
                "*": ["abi", "metadata", "evm.bytecode", "evm.sourcemap"]
            }
        }
    }    
}, solc_version="0.6.0")

# print(compiled_sol)

with open("compiled_code.json", "w") as file:
    json.dump(compiled_sol, file)


# para deploy em uma chain, precisamos
# get bytecode
bytecode = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"]["bytecode"]["object"]

#get abi
abi = compiled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]

# connect to ganache


if deploy_to == "RINKEBY":
    w3 = Web3(Web3.HTTPProvider("https://rinkeby.infura.io/v3/fbb7a1e0d44340008742d3361ff97cf5"))
    my_address = "0x13d0cf14eFfC6345c62C79251D4F81f486d02285" 
    private_key = "0xf83ddc7986497e6ae18a3bdaf10a315e2216e4b2b4835bf317a1391055cde07b"   
    chain_id = 4

elif deploy_to == "GANACHE":
    w3 = Web3(Web3.HTTPProvider("HTTP://127.0.0.1:7545"))
    my_address = os.getenv("MY_ADDRESS_GANACHE") 
    private_key = os.getenv("PRIVATE_KEY_GANACHE")
    chain_id = 1337



# print(private_key)

# Create contract in ganache
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)
# print(SimpleStorage)

# precisamos pegar o nonce para incrementar, quando criamos uma nova transacao
# get the nonce, pegando ele da ultima transacao
nonce = w3.eth.getTransactionCount(my_address)
# print(nonce)

# 1 - Build a transaction
# 2 - Sign the transaction
# 3 - Sebd the transaction

# 1 - cria a transacao
transaction = SimpleStorage.constructor().buildTransaction(
    {"chainId": chain_id, "from": my_address, "nonce": nonce, "gasPrice": w3.eth.gas_price}
)
# print(transaction)

# 2 - Assina a transacao
signed_tx = w3.eth.account.sign_transaction(transaction, private_key=private_key)
# print(signed_tx)

# 3 - Send transaction
tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
# print(tx_receipt)

# para atuar com o contrato, sempre preciso do ABI e Endereco do contrato
# abaixo, chamo uma instancia do contrato na rede
simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)

# tem 2 jeitos de interagir com o contrato?
# Call -> view
# Transact -> state change

# print(simple_storage.functions.retrieve().call())
# print(simple_storage.functions.store(15).call())

# cria novas transacoes para o store:

# 'to': '0x6Bc272FCFcf89C14cebFC57B8f1543F5137F97dE'
# 1 - cria a transacao
transaction2 = simple_storage.functions.store(15).buildTransaction(
    {"chainId": chain_id, "from": my_address, "nonce": nonce + 1, "gasPrice": w3.eth.gas_price}
)
# print(transaction)

# 2 - Assina a transacao
signed_tx2 = w3.eth.account.sign_transaction(transaction2, private_key=private_key)
# print(signed_tx)

# 3 - Send transaction
tx_hash2 = w3.eth.send_raw_transaction(signed_tx2.rawTransaction)
tx_receipt2 = w3.eth.wait_for_transaction_receipt(tx_hash2)







