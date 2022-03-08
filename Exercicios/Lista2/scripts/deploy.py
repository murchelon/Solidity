
from brownie import accounts, config, Lista2_Ex1, Lista1_Ex6, network

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

def deploy_Lista1_Ex6():

    print("Obtendo a conta...")
    account = getAccount()
    # account = accounts.add(config["wallets"]["from_key"])

    # print("Account:")
    # print(account)
    
    print("Realizando deploy...")
    sc_Object = Lista1_Ex6.deploy({"from": account})
    # print(sc_Object)

def deploy_Lista2_Ex1():

    print("Obtendo a conta...")
    account = getAccount()
    # account = accounts.add(config["wallets"]["from_key"])

    # print("Account:")
    # print(account)
    
    print("Realizando deploy...")
    sc_Object = Lista2_Ex1.deploy({"from": account})
    # print(sc_Object)


def main():
    # deploy_Lista1_Ex6()
    deploy_Lista2_Ex1()
    print("Fim do deploy")
