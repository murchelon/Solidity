// SPDX-License-Identifier: MTI
pragma solidity >=0.7.0 ^0.8.12;
// pragma experimental SMTChecker;




/*
DECENTRALIZED AND DISTRIBUTED DEVELOPMENT

Lista de Exercicios 02

- Aplicacao de CrowdFunding
- Nao existe limite de campanhas por usuario. Apenas usuarios ativos podem criar campanhas.
- Campanha: (IDCampanha, Nome, Status, Inicio_BlockTime, Termino_BlockTime, Inicio_timeStamp, Termino_timeStamp, ValorAlvo, ValorAtual)
- Campanha: Log: Todas as acoes (criacao, edicao, etc): IDLog, IDCampanha, EndOwner, TipoOperacao, DadosOperacao, Operacao_BlockTime, Operacao_timeStamp
- Campanha: Precisa deposito inicial caucao 0.5 eth.
- Campanha: Status: NaoIniciada, EmAndamento, Finalizada_Distribuicao, Finalizada_Cancelada, Finalizada_Sucesso
- Campanha: NaoIniciada: Pode alterar DataInicio, DataTermino, ValorAlvo (apenas owner)
- Campanha: EmAndamento: Pode alterar DataTermino e ValorAlvo, desde que respeitando limites de datas e valor atual
- Campanha: Cancelada: Valor Caucao nao eh devolvido. Retorna na integra os valores dos funders. Nao pode ser mais manipulada
- Campanha: Sucesso: ValorAlvo ou DataFinal atingida: Fica disponivel para aprovacao do Aprovador
- Campanha: Distribuicao_Negada: Aprovador nao aprovou. Ocorre agora o mesmo procedimento do cancelamento
- Campanha: Distribuicao_Aprovada: pode ser finalizada agora. Fundos disponiveis para saque pelo owner
- Campanha: Finalizada: Valor é sacado para o owner. Caucao + ValorAtual - Taxa 2%. Nao pode ser mais manipulada
- Auditores: Max: 5: Podem consultar ValorAtual e ValorAlvo, de uma campanha no qual eles tem autorizacao. Se nao indicadas, apenas o owner pode consultar
- Aprovador: Max: 1: Vai aprovar ou reprovar as financas da campanha, no final, transferindo os fundos de volta para os funders ou para o owner. Caso nao exista, apenas o owner pode aprovar
- Aprovador: Log: Logar as acoes do aprovador
- Doacoes em ETH, sem limites maximo. Minimo: 0.25 eth. So pode doar em campanhas EmAndamento
- Doacoes: Log: Todas as acoes: IDLogDoacao, IDCampanha, EndFunder, ValorDoado, Doacao_BlockTime, Doacao_timeStamp
- Doacoes: Funder pode desistir. Recebe valor de volta menos 0.1 eth de multa. So pode desistir em campanhas EmAndamento
- Doacoes: Log: Desistencias: Logar todos os dados da remessa e etc
- Verificar sobre ataques de reentrancia

DUVIDAS:
- Como usar um codigo que achei na net de forma correta? 
Melhor colocando: como usar um contract que achei, sem ter de 
dar deploy nele, obter um end e etc. O cod do contrato
mora no mesmo arquivo .sol do programa principal.
Eu consegui apenas literalmente inserindo o codigo dentro do contrato


2 – Voce esta desenvolvendo uma aplicacao de crowdfunding que usa a
blockchain Ethereum como base de funcionamento. Aqui, todas as doacoes em
dinheiro sao feitas diretamente em Ether (ou suas subunidades), e sao
transferidas diretamente das contas dos usuarios, sem intermediarios.
A plataforma que voce esta desenvolvendo permite a criacao de
campanhas de doacao. Uma campanha e identificada por um id unico, criado
dinamicamente. Ela tambem possui um nome, uma data de inicio (maior ou igual
à data de hoje), uma data de termino (maior que a data de inicio) e um valor alvo,
expresso em Weis, que e o valor que a campanha deseja arrecadar ao final.
Novas campanhas podem ser criadas a qualquer momento, e nao ha
limite para quantas campanhas um usuario pode criar. Ao ser criada, a operacao
de criacao da campanha deve ser armazenada em um log, filtrado pelo seu ID.
O log deve incluir o endereco da pessoa responsavel pela criacao, o tipo da
operacao (neste caso, criacao), e uma indicacao da data e hora.
Quando uma campanha e iniciada, seu dono precisa obrigatoriamente
fazer um deposito inicial de 0.5 Ether como caucao. Ao termino da campanha,
no caso de sucesso, este valor e devolvido para ele, juntamente com o valor
arrecadado.

Se uma campanha ainda nao comecou, suas datas de inicio e termino e
o valor a ser arrecadado podem ser alterados livremente, a qualquer momento.
Esta alteracao pode ser feita exclusivamente pelo dono da campanha, e deve
ser armazenada em log, filtrado pelo ID da campanha, e deve indicar o endereco
da pessoa responsavel pela alteracao, o tipo da alteracao, e deve contar com
uma indicacao da data e da hora.

Se uma campanha ja comecou, sua data de termino pode ser estendida,
e o valor a ser arrecadado pode ser aumentado ou diminuido (porem, nao pode
ser menor que o valor total arrecadado ate o momento). Neste caso, nao e
possivel diminuir a data de inicio. Estas alteracoes podem ser feitas
exclusivamente pelo dono da campanha e devem ser armazenadas em log,
filtrado pelo ID da campanha, com a indicacao do endereco da pessoa
responsavel pela alteracao, o tipo da alteracao, e a indicacao da data e da hora.

Como requisito de seguranca, um usuario pode indicar enderecos de
pessoas que capazes de auditar as operacoes feitas sobre sua campanha (no
maximo podem ser incluidas 5 pessoas). Assim, apenas pessoas autorizadas e
designadas no momento da criacao da campanha e que terao acesso a
acompanhar o seu andamento (ou seja, consultar o valor que ja foi arrecadado,
em determinado momento); esta funcao deve retornar dinamicamente o valor
esperado e o valor arrecadado. Caso a campanha nao tenha pessoas
designadas, apenas o seu dono e que podera realizar as consultas.

O usuario pode ainda indicar uma outra pessoa (no maximo 1 pessoa)
que tera que aprovar as contas antes que o valor seja depositado na conta do
dono da campanha ao final. Caso ele nao indique ninguem, esta pessoa devera
obrigatoriamente ser ele mesmo.

Qualquer pessoa pode fazer doacoes para as campanhas existentes. Nao
ha limite maximo para as doacoes, porem, ha um valor minimo estipulado de
0.25 Ether por doacao.

Toda doacao deve ser registrada em log indicando o ID da campanha
(usado como filtro), o endereco da pessoa que realizou a doacao, a quantidade
doada, e deve ter um indicativo de data e hora.

A pessoa que realizou uma doacao pode desistir, e pedir seu dinheiro de
volta; neste caso, ha uma taxa de 0.1 Ether como multa, cobrada pela plataforma
(fica com o contrato). O valor restante e transferido de volta diretamente para a
conta da pessoa.

A pessoa so pode desistir da doacao se a campanha ainda estiver ativa
(isto e, se nao chegou ate a data limite). A devolucao do dinheiro e feita
diretamente para o endereco da pessoa, e deve ser armazenada em log
identificado filtrado pelo ID da campanha e pelo endereco da pessoa, que
tambem deve conter um indicativo do valor devolvido e a data e a hora.

O dono da campanha pode desistir dela. Neste caso, o valor de caucao
nao e devolvido, e o dinheiro arrecadado deve ser devolvido a cada uma das
pessoas que fizeram a contribuicao, na integra. Cada uma das devolucoes deve
ser registrada em log, indicando o ID da campanha, o endereco do usuario que
vai receber o dinheiro, e o valor sendo devolvido.

Uma campanha e terminada por decurso de prazo (isto e, quando a data
final e alcancada) ou quando o valor desejado e atingido (mesmo no caso em
que o dono da campanha diminua o valor manualmente, para deixa-lo igual ao
valor disponivel). Em qualquer um dos casos, o usuario deve invocar uma funcao
capaz de encerra-lo.
A plataforma cobra uma taxa de 2% em cima do valor total arrecadado.
Assim, 98% do valor estara disponivel para ser transferido para o dono da
campanha.

Nao se esqueca que existe uma pessoa indicada para ser o aprovador da
conta! Uma campanha finalizada pelo usuario, so tera as verbas liberadas uma
vez que a pessoa aprovadora acesse o contrato e aprove a transferencia. A
aprovacao devera ser registrada em log, filtrado pelo ID da campanha, indicando
o endereco da pessoa aprovadora, a data e a hora.

Ao ser aprovada a campanha, 98% do valor arrecadado e transferido para
o dono da campanha, e ela e removida do contrato.

Faca as implementacoes necessarias. Nao se esqueca de proteger as
operacoes de transferencia contra os ataques de reentrancia!

Duvidas:
- Como resolver: CompilerError: Stack too deep, try removing local variables.


OBSERVACOES:

call in combination with re-entrancy guard is the recommended method to use after December 2019.

Guard against re-entrancy by:
making all state changes before calling other contracts
using re-entrancy guard modifier


*/

import "./DateTime.sol";

contract CrowdFunding is DateTime
{
 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Inicializacao
// =============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Eventos
    event event_Usuario_Cadastrado(int IDUser);
    event event_Usuario_Apagado(int result);

    event event_Campanha_Cadastrada(int IDCampanha);
 
    bool private reentrancy_locked;

    // Dono do contrato
    address private owner;

    // Constantes
    uint FATOR_DIVISOR_VALORES_DEBUG        = 1000; // em debug: 1000. Voltar para 1 quando em producao
    uint VALOR_DEPOSITO_CAUCAO              = 0.50 ether / FATOR_DIVISOR_VALORES_DEBUG;
    uint VALOR_FUNDING_MINIMO               = 0.25 ether / FATOR_DIVISOR_VALORES_DEBUG;
    uint VALOR_MULTA_DESISTENCIA_FUNDING    = 0.10 ether / FATOR_DIVISOR_VALORES_DEBUG;
    uint VALOR_PERC_TAXA_CROWDFUNDING       = 2; // 2%
    uint MAX_AUDITORES                      = 5;
    uint MAX_APROVADORES                    = 1;

    // Campanhas
    Campanha[] arrCampanhas;
    
    enum enumStatusCampanha {NaoIniciada, EmAndamento, Cancelada, Sucesso, Distribuicao_Negada, Distribuicao_Aprovada, Finalizada}

    struct Campanha 
    {
        int IDCampanha;
        string Nome;
        int IDUser_Cadastro;
        address Owner;
        enumStatusCampanha StatusCampanha;
        uint Cadastro_BlockTime;
        uint Inicio_BlockTime;
        uint Termino_BlockTime;
        string Cadastro_timeStamp;
        string Inicio_timeStamp;
        string Termino_timeStamp;
        uint ValorAlvo;
        uint ValorAtual;  
        bool Ativo;      
    }

    // struct temporario, que tive de criar pois atingi o limite de variaveis que eu estava
    // usando dentro de uma funcao de um contrato. Usado apenas 1 vez temporariamente
    struct Campanha_datas
    {
        string Inicio;
        string Termino;
        string Hoje;
        uint inicio_blocoMinimo;
        uint termino_blocoMaximo;
        uint hoje_blocoMinimo;    
    }

    
    // Usuarios
    Usuario[] arrUsers;

    struct Usuario
    {
        int IDUser;
        string Nome;
        address Endereco;  
        uint Cadastro_BlockTime;
        string Cadastro_timeStamp;  
        bool Ativo;            
    }

    // hashmap de endereco para usuario
    mapping (address => int) private mapAddressToUser;   // id = 0: nao existe o cadastro no array de usuarios
    


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Contrutor
// =========
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    constructor() payable 
    {
        owner = msg.sender;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// MODIFIERS
// =========
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Apenas o criador do contrato
    modifier onlyOwner
    {
        require(msg.sender == owner, "Apenas o admin pode chamar este metodo/funcao");
        _;
    }

    // Verifica se o endereco nao esta em branco
    modifier isAddressOk(address _address)
    {
        require(_address != address(0), "Endereco invalido");
        _;
    }  

    // verifica se o usuario existe no sistema
    modifier userExists(address _address)
    {
        int id = mapAddressToUser[_address];
        require(id > 0, "Usuario nao cadastrado");        
        _;
    }        
    
    // impete ataques de reentrancia
    modifier noReentrancy() 
    {
        require(!reentrancy_locked, "No reentrancy");
        reentrancy_locked = true;
        _;
        reentrancy_locked = false;
    }
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes DEBUG
// =============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
    function getValor()
        public 
        view 
        onlyOwner 
        returns (uint)    
    {

        string memory _hoje = string(abi.encodePacked(getNow(block.timestamp, 0), " 00:01:00"));

        // uint inicio_blocoMinimo = getBlockTimeStampFromDate(_Inicio);
        // uint termino_blocoMaximo = getBlockTimeStampFromDate(_Termino);
        // aqui abaixo da pau
        uint hoje_blocoMinimo = 0;
        
        // hoje_blocoMinimo = getBlockTimeStampFromDate(string(_hoje));


        return hoje_blocoMinimo;
    }

    function dt_getNow()
        public 
        view 
        onlyOwner 
        returns (string memory)    
    {
        return getNow();
    }

    function dt_getNowComValor(uint valor) 
        public 
        view 
        onlyOwner 
        returns (string memory)
    {
        // 1646538261 agora
        // 1854758745 - 10/10/2028 02:45:45
        // 1854758746 - 10/10/2028 02:45:46
        return getNow(valor);
    }

    function dt_getblockTime() 
        public 
        view 
        onlyOwner 
        returns (uint)
    {
        return block.timestamp;
    }
 
    // function dt_getBlockTimeStampFromDate() public view onlyOwner returns (uint)
    function dt_getBlockTimeStampFromDate(string memory theDate) 
        public 
        view 
        onlyOwner 
        returns (uint)
    {
        return getBlockTimeStampFromDate(theDate);
    }

    function getArray_Users() 
        public 
        view
        onlyOwner 
        returns (Usuario[] memory)
    {
        return arrUsers;
    }

    function getArray_Campanhas() 
        public 
        view
        onlyOwner 
        returns (Campanha[] memory)
    {
        return arrCampanhas;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes HELPER
// ==============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    // Recupera o IDUser do usuario "logado" (logado = carteira usada)
    function internal_getIDUserFromSender() 
        private 
        view 
        returns (int)
    {
        Usuario memory local_user = internal_usuario_pesquisarPorEndereco(msg.sender);

        return local_user.IDUser;
    }

    // Interna para cadastrar um novo usuario
    function internal_usuario_cadastrar(string memory _nome, address _endereco) 
        private 
        isAddressOk(_endereco) 
        noReentrancy
    {
        require(bytes(_nome).length > 0, "Nome nao pode ser em branco");

        int check_id = mapAddressToUser[_endereco];
        require(check_id <= 0, "O endereco ja tem um cadastro no sistema");

        // monta o usuario a ser adicionado
        Usuario memory local_user = Usuario({
            IDUser: -1,
            Nome: _nome,
            Endereco: _endereco,
            Cadastro_BlockTime: block.timestamp,
            Cadastro_timeStamp: getNow(),
            Ativo: true
        });

        // adiciona no array de usuarios
        arrUsers.push(local_user);

        // obtem o ID dele, que e o index+1 do array de usuarios
        int IDUser = int(arrUsers.length);

        // atualiza o campo ID no array e hashmap
        arrUsers[uint(IDUser) - 1].IDUser = IDUser;
        mapAddressToUser[_endereco] = IDUser;

        emit event_Usuario_Cadastrado(IDUser);
    }

    // Interna para pesquisa de usuarios por endereco
    function internal_usuario_pesquisarPorEndereco(address _endereco) 
        private 
        view 
        isAddressOk(_endereco) 
        userExists(_endereco) 
        returns (Usuario memory)
    {
        int IDUser = mapAddressToUser[_endereco];

        return arrUsers[uint(IDUser) - 1];        
    }

    // Interna para apagar um usuario, se ele NAO tiver associado a campanhas, auditor, aprovador ou funder
    function internal_usuario_apagarUsuario(address _endereco) 
        private 
        isAddressOk(_endereco) 
        userExists(_endereco) 
        noReentrancy
    {
        // Obtem o id do user sendo deletado        
        int IDUser_to_delete = mapAddressToUser[_endereco];
        
        // TODO: Valida se usuario tem campanha
        // TODO: Valida se usuario eh auditor
        // TODO: Valida se usuario eh aprovador
        // TODO: Valida se usuario eh funder
        // se ok todos os acima, continua

        // obtem o nome do usuario sendo apagado
        // string memory nomeToDel = arrUsers[uint(IDUser_to_delete) - 1].Nome;

        // atribui o id sendo deletado, para o id do ultimo usuario
        // do array de users, que sera movido para a posicao do 
        // usuario sendo deletado
        arrUsers[arrUsers.length - 1].IDUser = IDUser_to_delete;

        // sobrescreve o user sendo apagado, com o da ultima posicao do array
        arrUsers[uint(IDUser_to_delete) - 1] = arrUsers[arrUsers.length - 1];
        
        // remove o ultimo usuario do array de users
        arrUsers.pop();

        mapAddressToUser[_endereco] = int(0);

        emit event_Usuario_Apagado(1);
    }



    // Interna para cadastrar uma campanha
    // Formato de data: YYYY-MM-DD
    // Campanhas iniciam as 00:01:00 da data especificada 
    // Campanhas finalizam as 23:59:00 da data especificada 
    // Horarios em GMT. 
    // TODO: Implementar UTC Time
    // function internal_campanha_cadastrar(string memory _nome, address _endereco, uint _valorAlvo, string memory _Inicio, string memory _Termino) 
    function internal_campanha_cadastrar(string memory _nome, address _endereco, uint _valorAlvo, string memory _Inicio, string memory _Termino) 
        private 
        isAddressOk(_endereco) 
        userExists(_endereco) 
        noReentrancy
    {
  
        // Validacoes iniciais
        require(bytes(_nome).length > 0, "Nome nao pode ser em branco");
        require(_valorAlvo > 0, "Valor Alvo tem de ser maior do que zero");
        
        // Valida datas
        require(bytes(_Inicio).length == 10, "[1] O formato da data deve ser YYYY-MM-DD");
        require(bytes(_Termino).length == 10, "[1] O formato da data deve ser YYYY-MM-DD");

        

        Campanha_datas memory local_campanha_datas = Campanha_datas({
            Inicio: string(abi.encodePacked(_Inicio, " 00:01:00")),
            Termino: string(abi.encodePacked(_Termino, " 23:59:00")),
            Hoje: string(abi.encodePacked(getNow(block.timestamp, 0), " 00:01:00")),
            inicio_blocoMinimo: getBlockTimeStampFromDate(string(abi.encodePacked(_Inicio, " 00:01:00"))),
            termino_blocoMaximo: getBlockTimeStampFromDate(string(abi.encodePacked(_Termino, " 23:59:00"))),
            hoje_blocoMinimo: block.timestamp
            // hoje_blocoMinimo: getBlockTimeStampFromDate(string(abi.encodePacked(getNow(block.timestamp, 0, 1), " 00:01:00")))
        });
        
                    
        // _Inicio = string(abi.encodePacked(_Inicio, " 00:01:00"));
        // _Termino = string(abi.encodePacked(_Termino, " 23:59:00"));
        string memory _hoje = string(abi.encodePacked(getNow(block.timestamp, 0), " 00:01:00"));

        // uint inicio_blocoMinimo = getBlockTimeStampFromDate(_Inicio);
        // uint termino_blocoMaximo = getBlockTimeStampFromDate(_Termino);
        // aqui abaixo da pau
        // uint hoje_blocoMinimo = 0;
        
        // hoje_blocoMinimo = getBlockTimeStampFromDate(string(_hoje));

        

        if (local_campanha_datas.inicio_blocoMinimo >= local_campanha_datas.termino_blocoMaximo)
        {
            require(1==2, "A data de inicio deve ser menor do que a de termino");
        }

        

        if (local_campanha_datas.inicio_blocoMinimo < local_campanha_datas.hoje_blocoMinimo)
        {
            require(1==2, "A data de inicio deve ser maior do que hoje");
        }  


        // Cria a campanha        
        Campanha memory local_campanha = Campanha({
            IDCampanha: -1,
            Nome: _nome,
            IDUser_Cadastro: internal_getIDUserFromSender(),
            Owner: _endereco,
            StatusCampanha: enumStatusCampanha.NaoIniciada,
            Cadastro_BlockTime: block.timestamp,
            Inicio_BlockTime: local_campanha_datas.inicio_blocoMinimo,
            Termino_BlockTime: local_campanha_datas.termino_blocoMaximo,
            Cadastro_timeStamp: getNow(),
            Inicio_timeStamp: getNow(local_campanha_datas.inicio_blocoMinimo),
            Termino_timeStamp: getNow(local_campanha_datas.termino_blocoMaximo),
            ValorAlvo: _valorAlvo,
            ValorAtual: uint(0),
            Ativo: true
        });

        // adiciona no array de campanhas
        arrCampanhas.push(local_campanha);

        // obtem o ID dele, que e o index+1 do array de campanhas
        int IDCampanha = int(arrCampanhas.length);

        // atualiza o campo ID no array e hashmap
        arrCampanhas[uint(IDCampanha) - 1].IDCampanha = IDCampanha;
        // mapAddressToUser[_endereco] = IDUser;

        emit event_Campanha_Cadastrada(IDCampanha);        
    }
    
    

    // Verifica se o contrato esta ativo e deployed (test ok)
    function isContractAlive() 
        external 
        pure 
        returns (bool)
    {
         return true;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes ADMIN
// =============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // ------------------------------------------------------------------------------------------
    // Funcoes de Usuario
    // ------------------------------------------------------------------------------------------

    // Cadastro de um novo usuario qualquer (test ok)
    function ADMIN_Usuario_CadastrarNovoUsuario(string memory _nome, address _endereco) 
        public 
        onlyOwner
    {
        internal_usuario_cadastrar(_nome, _endereco);
    }

    // Pesquisar um usuario qualquer por endereco (test ok)
    function ADMIN_Usuario_PesquisarPorEndereco(address _endereco) 
        public 
        view 
        onlyOwner 
        returns (Usuario memory)
    {
        return internal_usuario_pesquisarPorEndereco(_endereco);
    }

    // Apagar um usuario por endereco (test ok)
    function ADMIN_Usuario_ApagarUsuarioPorEndereco(address _endereco) 
        public 
        onlyOwner
    {
        internal_usuario_apagarUsuario(_endereco);
    }

    // ------------------------------------------------------------------------------------------
    // Funcoes de Campanha
    // ------------------------------------------------------------------------------------------

    // Cadastro de uma nova campanha
    // Formato de Inicio e Termino: YYYY-MM-DD
    function ADMIN_Campanha_CadastrarNovaCampanha(string memory _nome, address _endereco, uint _valorAlvo, string memory _Inicio, string memory _Termino) 
        public         
        onlyOwner
    {
        internal_campanha_cadastrar(_nome, _endereco, _valorAlvo, _Inicio, _Termino);
    }


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes USUARIO COMUM
// =====================
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    // ------------------------------------------------------------------------------------------
    // Funcoes de Usuario
    // ------------------------------------------------------------------------------------------

    // Cadastrar o meu novo usuario (test ok)
    function MeuUsuario_CadastrarNovoUsuario(string memory _nome) 
        public
    {
        internal_usuario_cadastrar(_nome, msg.sender);
    }

    // Pesquisar o meu usuario (test ok)
    function MeuUsuario_Pesquisar() 
        public 
        view 
        returns (Usuario memory)
    {
        return internal_usuario_pesquisarPorEndereco(msg.sender);
    }

    // Apagar o meu usuario (test ok)
    function MeuUsuario_ApagarUsuario() 
        public
    {
        internal_usuario_apagarUsuario(msg.sender);
    }

    // ------------------------------------------------------------------------------------------
    // Funcoes de Campanha
    // ------------------------------------------------------------------------------------------

    // Cadastro de uma nova campanha
    // Formato de Inicio e Termino: YYYY-MM-DD
    function MeuUsuario_CadastrarNovaCampanha(string memory _nome, uint _valorAlvo, string memory _Inicio, string memory _Termino) 
        public
    {
        internal_campanha_cadastrar(_nome, msg.sender, _valorAlvo, _Inicio, _Termino);
    }


}



