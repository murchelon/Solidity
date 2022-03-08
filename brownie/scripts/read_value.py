from brownie import accounts, config, SimpleStorage, network

def read_contract():
    sc_SimpleStorage = SimpleStorage[-1]

    print(sc_SimpleStorage.retrieve())



def main():
    read_contract()