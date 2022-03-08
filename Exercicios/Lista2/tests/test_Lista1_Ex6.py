from brownie import accounts, config, Lista1_Ex6, network
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

# Admin:
# OKOK - testar Deploy do Contrato (test_Admin_Deploy) (admin: addres[0])
# OKOK - Nao pode matricular menores de 18 anos (conta usuario2 comum) (test_Admin_CadastraQualquerAluno_IdadeErrada)
# OKOK - Nao pode ter nome em branco (conta usuario2 comum) (test_Admin_CadastraQualquerAluno_NomeEmBranco)
# OKOK - Cadastrar novo aluno (conta usuario2 comum) (test_Admin_CadastraQualquerAluno)
# OKOK - nao pode cadastrar usuarios com endereco duplicado (conta usuario3 comum) (test_Admin_CadastraQualquerAluno_Duplicado)
# OKOK - Consultar Aluno por Endereco (conta usuario2 comum) (test_Admin_ConsultaAlunoPorEnd)
# OKOK - Consulta total alunos matriculados (test_Admin_ConsultaAlunosMatriculados)
# OKOK - Remove Qualquer Aluno (conta usuario2 comum) (test_Admin_RemoveQualquerAluno)

# Usuario comum:
# OKOK - Usuario realiza um novo cadastro (conta usuario4 comum) (test_User_RealizaMeuCadastro)
# OKOK - Usuario consulta o seu cadastro (conta usuario4 comum) (test_User_ConsultaMeuCadastro)
# OKOK - Usuario remove o seu cadastro (conta usuario4 comum) (test_User_RemoveMeuCadastro)
# OKOK - Usuario nao pode chamar funcoes admin (conta usuario5 comum) (test_User_NaoPodeChamarFuncAdmin)


# - Deploy Contrato
def test_Admin_Deploy():
    # Arrange
    account = getAccount(0) # admin
    # Act
    sc_Lista1_Ex6 = Lista1_Ex6.deploy({"from": account})
    isAlive = sc_Lista1_Ex6.isContractAlive()
    expected = True
    # Assert
    assert isAlive == expected


# - Nao pode matricular menores de 18 anos (conta usuario2 comum) 
def test_Admin_CadastraQualquerAluno_IdadeErrada():
    # Arrange
    account_comum2 = getAccount(1)
    sc_Lista1_Ex6 = Lista1_Ex6[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])
    transaction = None
    # Act
    with brownie.reverts("A idade minima para se cadastrar eh 18 anos"):
        transaction = sc_Lista1_Ex6.cadastrarQualquerAluno("marcelo nao pode cadastrar", 5, account_comum2)
    # Assert
    assert transaction == None


# - Nao pode ter nome em branco (conta usuario2 comum)
def test_Admin_CadastraQualquerAluno_NomeEmBranco():
    # Arrange
    account_comum2 = getAccount(1)
    sc_Lista1_Ex6 = Lista1_Ex6[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])
    transaction = None
    # Act
    with brownie.reverts("Nome nao pode ser em branco"):
        transaction = sc_Lista1_Ex6.cadastrarQualquerAluno("", 18, account_comum2)
    # Assert
    assert transaction == None

# - Cadastra Qualquer Aluno (conta usuario2 comum)
def test_Admin_CadastraQualquerAluno():
    # Arrange
    account_comum2 = getAccount(1)
    sc_Lista1_Ex6 = Lista1_Ex6[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])
    transaction = None
    # Act    
    transaction = sc_Lista1_Ex6.cadastrarQualquerAluno("marcelo conta 2", 18, account_comum2)
    # Assert
    assert transaction != None

# - Nao pode cadastrar usuarios com endereco duplicado (conta usuario3 comum) 
def test_Admin_CadastraQualquerAluno_Duplicado():
    # Arrange
    account_comum3 = getAccount(2)
    sc_Lista1_Ex6 = Lista1_Ex6[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])
    transaction1 = None
    transaction1 = sc_Lista1_Ex6.cadastrarQualquerAluno("marcelo conta 3", 18, account_comum3)
    transaction2 = None
    # Act
    with brownie.reverts("O endereco ja tem um cadastro no sistema"):
        transaction2 = sc_Lista1_Ex6.cadastrarQualquerAluno("marcelo teste conta 3", 18, account_comum3)
    # Assert
    assert transaction2 == None

# - Consulta Aluno por Endereco (conta usuario2 comum)
def test_Admin_ConsultaAlunoPorEnd():
    # Arrange
    account_comum2 = getAccount(1)
    sc_Lista1_Ex6 = Lista1_Ex6[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])
    aluno = None
    # Act    
    aluno = sc_Lista1_Ex6.consultaAlunoPorEndereco(account_comum2)
    # Assert
    assert aluno != None

# - Consulta total alunos matriculados 
def test_Admin_ConsultaAlunosMatriculados():
    # Arrange
    sc_Lista1_Ex6 = Lista1_Ex6[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])
    totAlunos = None
    expected = 2    # 2 cadastros dos testes acima: conta2 e conta3
    # Act    
    totAlunos = sc_Lista1_Ex6.consultaTotalAlunosMatriculados()
    # Assert
    assert totAlunos == expected

# - Remove Qualquer Aluno (conta usuario2 comum)
def test_Admin_RemoveQualquerAluno():
    # Arrange
    account_comum2 = getAccount(1)
    sc_Lista1_Ex6 = Lista1_Ex6[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])
    transaction = None
    # Act    
    transaction = sc_Lista1_Ex6.removeMatriculaQualquerAluno(account_comum2)    # remove a conta 2  
    # Assert
    assert transaction != None


#  Funcoes de Usuario:


# - Usuario realiza um novo cadastro (conta usuario4 comum)
def test_User_RealizaMeuCadastro():
    # Arrange
    # obtem a conta que vai realizar a chamada
    account_comum4 = getAccount(3)
    sc_Lista1_Ex6 = Lista1_Ex6[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])       
    transaction = None
    # Act    
    # chama o metodo do contrato, usando o usuario acima
    transaction = sc_Lista1_Ex6.realizarMeuCadastro("joao da silva", 30, {"from": account_comum4}) 
    # Assert
    assert transaction != None

# - Usuario consulta o seu cadastro (conta usuario4 comum)
def test_User_ConsultaMeuCadastro():
    # Arrange
    # obtem a conta que vai realizar a chamada
    account_comum4 = getAccount(3)
    sc_Lista1_Ex6 = Lista1_Ex6[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])       
    aluno = None
    # Act    
    # chama o metodo do contrato, usando o usuario acima
    aluno = sc_Lista1_Ex6.consultaMeuCadastro({"from": account_comum4}) 
    # Assert
    assert aluno != None

# - Usuario remove o seu cadastro (conta usuario4 comum) 
def test_User_RemoveMeuCadastro():
    # Arrange
    # obtem a conta que vai realizar a chamada
    account_comum4 = getAccount(3)
    sc_Lista1_Ex6 = Lista1_Ex6[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])       
    transaction = None
    # Act    
    # chama o metodo do contrato, usando o usuario acima
    transaction = sc_Lista1_Ex6.removeMinhaMatricula({"from": account_comum4}) 
    # Assert
    assert transaction != None


# - Usuario nao pode chamar funcoes admin (conta usuario5 comum) 
def test_User_NaoPodeChamarFuncAdmin():
    # Arrange
    # obtem a conta que vai realizar a chamada
    account_comum5 = getAccount(4)
    sc_Lista1_Ex6 = Lista1_Ex6[-1]  # usa o contrato instanciado em test_Admin_Deploy pelo admin (addres[0])       
    totUsers = -1
    # Act    
    # chama o metodo do contrato, usando o usuario acima
    with brownie.reverts("Apenas o admin pode chamar este metodo/funcao"):
        totUsers = sc_Lista1_Ex6.consultaTotalAlunosMatriculados({"from": account_comum5})    
    # Assert
    assert totUsers < 0

