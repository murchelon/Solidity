
from brownie import accounts, config, SimpleStorage, network

# brownie networks add Ethereum ganache-local host=http://127.0.0.1:7545 chainid=5777
# brownie run scripts/deploy.py --network ganache-local
# brownie run scripts/deploy.py --network rinkeby
# brownie networks delete ganache-local
# brownie networks list
# brownie console


def getAccount():
    if network.show_active() == "development":
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])

def deploy_simple_storage():

    print("Obtendo a conta...")
    account = getAccount()
    # account = accounts.add(config["wallets"]["from_key"])

    # print("Account:")
    # print(account)
    
    print("Realizando deploy...")
    sc_SimpleStorage = SimpleStorage.deploy({"from": account})
    # print(sc_SimpleStorage)

    print("Valor Inicial:")
    stored_value = sc_SimpleStorage.retrieve()
    print(stored_value)

    print("Efetuando alteracao...")
    transaction = sc_SimpleStorage.store(15, {"from": account})
    transaction.wait(1)

    print("Valor atualizado:")
    updated_stored_value = sc_SimpleStorage.retrieve()
    print(updated_stored_value)



def main():
    deploy_simple_storage()
    print("Fim do deploy")
