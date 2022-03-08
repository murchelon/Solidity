from typing import final
from brownie import accounts, config, CrowdFunding, network
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

# TESTES:
# account_admin: se mantem cadastrado ate o final
# account_comum2 e account_comum3 sao cadastrados, mas account_comum2 eh apagado durante os testes
# account_comum1 eh cadastrado e apagado pelo usuario comum, durante os testes
# account_comum3 eh o usado para testes de campanha


# ======================================================================
# ADMIN
# ======================================================================


# - ADMIN: Deploy Contrato
def test_Admin_Deploy():
    # Arrange
    account_admin = getAccount(0) # admin
    expected = True
    # Act
    sc_Object = CrowdFunding.deploy({"from": account_admin})
    isAlive = sc_Object.isContractAlive()    
    # Assert
    assert isAlive == expected


# - ADMIN: Cadastro do proprio usuario (Admin) 
def test_MeuUsuario_CadastrarNovoUsuario_UsandoAdmin():
    # Arrange
    account_admin = getAccount(0)
    sc_Object = CrowdFunding[-1]  # usa o contrato instanciado no inicio do teste
    transaction = None
    # Act    
    transaction = sc_Object.MeuUsuario_CadastrarNovoUsuario("Marcelo Admin", {"from": account_admin})
    # Assert
    assert transaction != None


# - ADMIN: Cadastro de um novo usuario qualquer
def test_ADMIN_Usuario_CadastrarNovoUsuario():
    # Arrange
    account_admin = getAccount(0)
    account_comum2 = getAccount(2)
    sc_Object = CrowdFunding[-1]  # usa o contrato instanciado no inicio do teste
    transaction = None
    # Act    
    transaction = sc_Object.ADMIN_Usuario_CadastrarNovoUsuario("Joao Comum", account_comum2, {"from": account_admin})
    # Assert
    assert transaction != None


# - ADMIN: Nao permitir cadastro de usuario duplicado
def test_ADMIN_Usuario_CadastrarNovoUsuario_NaoPermitirDuplicado():
    # Arrange
    account_admin = getAccount(0)
    account_comum3 = getAccount(3)
    sc_Object = CrowdFunding[-1]  # usa o contrato instanciado no inicio do teste
    transaction1 = None
    transaction2 = None
    transaction1 = sc_Object.ADMIN_Usuario_CadastrarNovoUsuario("Antonio Comum", account_comum3, {"from": account_admin})
    # Act   
    with brownie.reverts("O endereco ja tem um cadastro no sistema"): 
        transaction2 = sc_Object.ADMIN_Usuario_CadastrarNovoUsuario("Antonio Comum", account_comum3, {"from": account_admin})
    # Assert
    assert transaction2 == None


# - ADMIN: Pesquisar um usuario qualquer por endereco
def test_ADMIN_Usuario_PesquisarPorEndereco():
    # Arrange
    account_admin = getAccount(0)
    account_comum2 = getAccount(2)
    sc_Object = CrowdFunding[-1]  # usa o contrato instanciado no inicio do teste
    usuario = None
    # Act    
    usuario = sc_Object.ADMIN_Usuario_PesquisarPorEndereco(account_comum2, {"from": account_admin})
    # Assert
    assert usuario != None


# - ADMIN: Apagar um usuario por endereco 
def test_ADMIN_Usuario_ApagarUsuarioPorEndereco():
    # Arrange
    account_admin = getAccount(0)
    account_comum2 = getAccount(2)
    sc_Object = CrowdFunding[-1]  # usa o contrato instanciado no inicio do teste
    transaction = None
    # Act    
    transaction = sc_Object.ADMIN_Usuario_ApagarUsuarioPorEndereco(account_comum2, {"from": account_admin})
    # Assert
    assert transaction != None


# - ADMIN: Cadastro de uma nova campanha
def test_ADMIN_Campanha_CadastrarNovaCampanhaQualquer():
    # Arrange
    account_admin = getAccount(0)
    account_comum3 = getAccount(3)
    sc_Object = CrowdFunding[-1]  # usa o contrato instanciado no inicio do teste
    transaction = None
    ValorAlvo = 10
    Inicio = "2022-03-10"
    Termino = "2022-03-15"
    # Act    
    transaction = sc_Object.ADMIN_Campanha_CadastrarNovaCampanha("CampanhaX", account_comum3, ValorAlvo, Inicio, Termino, {"from": account_admin})
    # Assert
    assert transaction != None


# ======================================================================
# USUARIO COMUM
# ======================================================================


# - USUARIO COMUM: Nao permitir acesso a funcoes Admin, para o usuario comum
def test_UsuarioComumNaoPodeAcessarAdmin():
    # Arrange
    account_comum2 = getAccount(2)
    account_comum3 = getAccount(3)
    sc_Object = CrowdFunding[-1]  # usa o contrato instanciado no inicio do teste
    usuario = None
    # Act   
    with brownie.reverts("Apenas o admin pode chamar este metodo/funcao"):     
        usuario = sc_Object.ADMIN_Usuario_PesquisarPorEndereco(account_comum3, {"from": account_comum2})
    # Assert
    assert usuario == None


# - USUARIO COMUM: Cadastrar o meu novo usuario (Usuario Comum) 
def test_MeuUsuario_CadastrarNovoUsuario():
    # Arrange
    account_comum1 = getAccount(1)
    sc_Object = CrowdFunding[-1]  # usa o contrato instanciado no inicio do teste
    transaction = None
    # Act    
    transaction = sc_Object.MeuUsuario_CadastrarNovoUsuario("Ricardo Comum", {"from": account_comum1})
    # Assert
    assert transaction != None


# - USUARIO COMUM: Pesquisar o meu usuario
def test_MeuUsuario_Pesquisar():
    # Arrange
    account_comum1 = getAccount(1)
    sc_Object = CrowdFunding[-1]  # usa o contrato instanciado no inicio do teste
    usuario = None
    # Act    
    usuario = sc_Object.MeuUsuario_Pesquisar({"from": account_comum1})
    # Assert
    assert usuario != None    


# - USUARIO COMUM: Apagar o meu usuario
def test_MeuUsuario_ApagarUsuario():
    # Arrange
    account_comum1 = getAccount(1)
    sc_Object = CrowdFunding[-1]  # usa o contrato instanciado no inicio do teste
    transaction = None
    # Act    
    transaction = sc_Object.MeuUsuario_ApagarUsuario({"from": account_comum1})
    # Assert
    assert transaction != None

# - ADMIN: Cadastro de uma nova campanha
def test_ADMIN_Campanha_CadastrarNovaCampanhaQualquer():
    # Arrange
    account_admin = getAccount(0)
    account_comum3 = getAccount(3)
    sc_Object = CrowdFunding[-1]  # usa o contrato instanciado no inicio do teste
    transaction = None
    ValorAlvo = 10
    Inicio = "2022-03-10"
    Termino = "2022-03-15"
    # Act    
    transaction = sc_Object.ADMIN_Campanha_CadastrarNovaCampanha("CampanhaX", account_comum3, ValorAlvo, Inicio, Termino, {"from": account_admin})
    # Assert
    assert transaction != None


# # - ADMIN: Cadastro de uma nova campanha , com diferentes parametros
# #   :: Data Termino menor do que Data Inicial
# #   :: Data Inicial menor do que hoje
# #   :: Datas invalidas, mas bem formatadas
# #   :: Datas Inicial e Termino em branco ou invalida
# #   :: ValorAlvo invalido, em branco ou menor_ou_igual a zero
# def test_ADMIN_Campanha_CadastrarNovaCampanhaQualquer_TesteComDiferentesDatas():

#     # Arrange - Main
#     account_admin = getAccount(0)
#     account_comum3 = getAccount(3)
#     sc_Object = CrowdFunding[-1]  # usa o contrato instanciado no inicio do teste

#     # Arrange
#     transaction = None
#     ValorAlvo = 10
#     Inicio = "2022-03-10"
#     Termino = "2022-03-09"
#     # Act    
#     with brownie.reverts("O termino nao pode ser antes do inicio"):     
#         transaction = sc_Object.ADMIN_Campanha_CadastrarNovaCampanha("Campanha Data Termino menor do que Data Inicial", account_comum3, ValorAlvo, Inicio, Termino, {"from": account_admin})

#     # Assert
#     assert transaction == None



