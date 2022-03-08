from brownie import accounts, config, Lista2_Ex1, network
import brownie

# brownie test -k test_UpdateStorage para testar so 1
# brownie test -s para mais detalhes
# brownie test -pdb para debug. Para no ponto onde o assert der errado

# Arrange
# Act
# Assert

def getAccount(index: int = 0):
    if network.show_active() == "development":
        return accounts[index]
    else:
        return accounts.add(config["wallets"]["from_key"])

# ATENCAO: O caller, sempre eh a private keyh configurada/infure project id. Os enderecos passados, sao apenas parametros das funcoes



# - ADMIN: Deploy Contrato
def test_Admin_Deploy():
    # Arrange
    account_admin = getAccount(0) # admin
    # Act
    sc_Object = Lista2_Ex1.deploy({"from": account_admin})
    isAlive = sc_Object.isContractAlive()
    expected = True
    # Assert
    assert isAlive == expected


# - ADMIN: Cadastro do MeuUsuario (admin)
def test_Admin_cadastrarMeuUsuario():
    # Arrange
    account_admin = getAccount(0)
    sc_Object = Lista2_Ex1[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])
    transaction = None
    # Act    
    transaction = sc_Object.cadastrarMeuUsuario("Marcelo", 44)
    # Assert
    assert transaction != None


# - ADMIN: Cadastro de 1 usuario qualquer
def test_Admin_cadastrarQualquerUsuario():
    # Arrange
    account_comum1 = getAccount(1)
    sc_Object = Lista2_Ex1[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])
    transaction = None
    # Act    
    transaction = sc_Object.cadastrarQualquerUsuario("Joao", 18, account_comum1)
    # Assert
    assert transaction != None


# # - ADMIN: Define um usuario como editor
# def test_Admin_setPerfilForUsuario():
#     # Arrange
#     account_comum1 = getAccount(1)
#     sc_Object = Lista2_Ex1[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])
#     transaction = None
#     # Act    
#     transaction = sc_Object.setPerfilForUsuario(1, account_comum1)
#     # Assert
#     assert transaction != None
