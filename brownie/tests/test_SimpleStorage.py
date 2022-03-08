from brownie import accounts, config, SimpleStorage, network

# brownie test -k test_UpdateStorage para testar so 1
# brownie test -s para mais detalhes
# brownie test -pdb para debug. Para no ponto onde o assert der errado

# Arrange
# Act
# Assert

def getAccount():
    if network.show_active() == "development":
        return accounts[0]
    else:
        return accounts.add(config["wallets"]["from_key"])


def test_Deploy():
    # Arrange
    account = getAccount()
    # Act
    sc_SimpleStorage = SimpleStorage.deploy({"from": account})
    starting_value = sc_SimpleStorage.retrieve()
    expected = 5
    # Assert
    assert starting_value == expected

def test_UpdateStorage():
    # Arrange
    account = getAccount()
    sc_SimpleStorage = SimpleStorage.deploy({"from": account})
    # Act
    expected = 15
    sc_SimpleStorage.store(expected, {"from": account})
    # Assert
    assert expected == sc_SimpleStorage.retrieve()
