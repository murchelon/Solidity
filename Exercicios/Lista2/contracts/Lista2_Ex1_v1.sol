// SPDX-License-Identifier: MTI
pragma solidity >=0.7.0 ^0.8.12;

// import "./console.sol";

/*
DECENTRALIZED AND DISTRIBUTED DEVELOPMENT

Lista de Exercicios 02

1 – Voce esta trabalhando em um contrato que realiza o cadastro de usuarios,
capazes de interagir com sua aplicacao.
Um usuario e identificado por seu endereco de origem, seu nome e sua
idade – todos, atributos obrigatorios. Um usuario possui, ainda, perfis de acesso:
Leitor ou Editor.
No momento do cadastro, o perfil de acesso obrigatoriamente e Leitor.
Durante este processo, sao mostrados tooltips na tela, conforme as validacoes
dos dados sejam concluidas (nao se preocupe em implementar o front-end!).
Um endereco pode ser cadastrado uma unica vez.
Usuarios que nao tenham sido cadastrados nao devem poder interagir
com o restante da aplicacao (podem apenas realizar o seu cadastro).
Deve existir uma funcionalidade para que o dono do contrato altere o perfil
de acesso dos usuarios cadastrados: um usuario Leitor vira, obrigatoriamente,
um Editor, e um Editor vira um Leitor. Apenas o dono do contrato pode executar
esta acao. Esta alteracao deve ser armazenada em log, filtrado pelo endereco
do usuario que foi alterado e deve indicar o horario em que aconteceu.
Usuarios com perfil Editor que interajam com a aplicacao podem alterar
os dados de nome e idade de qualquer outro usuario, e estas alteracoes devem
ser armazenadas em log junto com o horario e o usuario responsavel pela
alteracao. Deve ser possivel filtrar as alteracoes pelo endereco do usuario que
foi atualizado.
Usuarios de perfil Leitor podem visualizar os dados de qualquer usuario,
porem nao podem realizar alteracoes.
Tanto os usuarios de perfil Leitor como Editor podem solicitar que o
seu proprio registro seja desativado (apenas o seu proprio registro). Esta
solicitacao fica armazenada em uma estrutura propria do contrato.
A partir do momento em que a solicitacao e feita, o usuario tem 30
segundos para poder desistir da sua solicitacao.
O dono do contrato pode aprovar a desativacao, porem, apenas depois
dos 30 segundos de seguranca – apenas solicitacoes criadas com tempo maior
ou igual a 30 segundos e que podem ser atendidas.
Faca as implementacoes necessarias.



Duvidas:
- modifiers como userExists: rodo a cada funcao? Nao, pois gasta 
mais gas. O melhor seria chamaar apenas na ultima funcao principal
e verificar apenas 1 vez? Sera que a cadeia de erros, vai
subindo no stack das funcoes chamadas?
- como redimensioar arrays memory criados dentro de funcao? 
tive de dar um gambito. Ex: array de retorno dos logs de 1 usuario
- pelamor de deus: como debugo melhor este mundo?
Como debugar solidity? Como usar eventos para debug, sem um frontend?
- Como criar um front end automatico, como no remix, a partir
dos metodos de um contrato, no brownie/vscode?
- Como debugo gas? Como vejo bem isto.. e sei la tem um profiler?
- As vezes.. vejo que deu erro no solidity mas o brownie nao mostra 
claramente um erro. Mas ele tbem nao faz o esperado e o erro eh claro
Nao lembro um exemplo

*/


contract Lista2_Ex1
{
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Inicializacao
// =============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    enum enumPerfil {Leitor, Editor}
    
    struct Usuario
    {
        int id;
        string nome;
        uint idade;
        address endereco;
        enumPerfil perfil;
        uint lastPerfilChangeTime;
        uint lastDeleteRequestTime;
    }

    struct Log_PerfilChangeEvent
    {
        int id_user_alvo;
        int id_user_executor;
        string alteracao;
        uint timestamp;
    }

    // mapeamento de endereco para ID do array (id = index + 1). Logo, ID = 0 significa que NAO existe o cadastro no hashmap
    // hashmap de int retorna ZERO , quando NAO ENCONTRA o endereco procurado
    mapping (address => int) private mapUserToId;   // id = 0: nao existe o cadastro no array de usuarios

    Usuario[] private arrUsers;

    Log_PerfilChangeEvent[] private arrLog_PerfilChangeEvent;

    address private owner;

    uint private TIME_TO_CANCEL_DELETE = 30 seconds;

    constructor()
    {
        owner = msg.sender;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// MODIFIERS
// =========
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    modifier onlyOwner
    {
        require(msg.sender == owner, "Apenas o admin pode chamar este metodo/funcao");
        _;
    }

    modifier isAddressOk(address _address)
    {
        require(_address != address(0), "Endereco invalido");
        _;
    }  

    modifier userExists(address _address)
    {
        int id = mapUserToId[_address];
        require(id > 0, "Usuario nao cadastrado");        
        _;
    }        
    
    modifier onlyEditor(address _address)
    {
        bool acessoLiberado = false;
        
        if (msg.sender == owner)
        {
            acessoLiberado = true;
        }
        else
        {
            int id = mapUserToId[_address];
            
            if (id > 0)
            {
                if (arrUsers[uint(id) - 1].perfil == enumPerfil.Editor)
                {
                    acessoLiberado = true;
                }
            }
        }
        
        require(acessoLiberado == true, "Este metodo so pode ser acessado por Editores ou o Admin");        
        _;
    }        

    modifier onlyLeitor(address _address)
    {
        bool acessoLiberado = false;
        
        if (msg.sender == owner)
        {
            acessoLiberado = true;
        }
        else
        {
            int id = mapUserToId[_address];
            
            if (id > 0)
            {
                if ((arrUsers[uint(id) - 1].perfil == enumPerfil.Leitor) || (arrUsers[uint(id) - 1].perfil == enumPerfil.Editor))
                {
                    acessoLiberado = true;
                }
            }
        }
        
        require(acessoLiberado == true, "Este metodo so pode ser acessado por Leitores, Editores ou o Admin");        
        _;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes DEBUG
// =============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
    // function getArray_Users() public view onlyOwner returns (Usuario[] memory)
    // {
    //     return arrUsers;
    // }

    // function getArray_Log_PerfilChangeEvent() public view onlyOwner returns (Log_PerfilChangeEvent[] memory)
    // {
    //     return arrLog_PerfilChangeEvent;
    // }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes HELPER
// ==============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function toEnumPerfilFromUint8(uint8 _valor) private pure returns (enumPerfil)
    {
        // enum enumPerfil {Leitor, Editor}
        if (_valor == 0)
        {
            return enumPerfil.Leitor;
        }
        else if (_valor == 1)
        {
            return enumPerfil.Editor;
        }
        else
        {
            return enumPerfil.Leitor;
        }        
    }

    function toUint8FromEnumPerfil(enumPerfil _perfil) private pure returns (uint8)
    {
        // enum enumPerfil {Leitor, Editor}
        if (_perfil == enumPerfil.Leitor)
        {
            return uint8(0);
        }
        else if (_perfil == enumPerfil.Editor)
        {
            return uint8(1);
        }
        else
        {
            return uint8(0);
        }         
    }

    function internal_consultaUsuarioPorEndereco(address _endereco) private view isAddressOk(_endereco) returns (Usuario memory)
    {
        int id = mapUserToId[_endereco];
        require(id > 0, "Usuario nao cadastrado");

        return arrUsers[uint(id) - 1];
    }

    function setNovoPerfil(uint8 _novoStatus, address _endereco) private isAddressOk(_endereco) userExists(msg.sender)
    {
        // https://ethereum.stackexchange.com/questions/80350/how-to-handle-enums-as-arguments-for-public-functions
        // um atacante poderia chamar o contrato com um enum errado e isto faz com que o require abaixo nao seja executado e um erro ocorra, 
        // usando um optcode diferente do que deveria, para ocorrer o require abaixo.
        // aparentemente, isto consome todo o gas... preciso entender melhor, mas parece que esta e a forma mais segura que impede isto
        // (converter para uint8 antes e testar como uint8)
        require(_novoStatus <= uint8(enumPerfil.Editor), "Status de perfil invalido");

        enumPerfil _safeNovoStatus;

        _safeNovoStatus = toEnumPerfilFromUint8(_novoStatus);

        Usuario memory _user = internal_consultaUsuarioPorEndereco(_endereco);
        
        if (_user.perfil == enumPerfil.Leitor)
        {
            if (_safeNovoStatus == enumPerfil.Editor)
            {
                arrUsers[uint(_user.id) - 1].perfil = _safeNovoStatus;
                arrUsers[uint(_user.id) - 1].lastPerfilChangeTime = block.timestamp;  

                // LOG DO EVENTO
                int id_user_executor = mapUserToId[msg.sender];
                if (id_user_executor <= 0)
                {
                    require(1==2, "O usuario que iria realizar a alteracao nao foi localizado");
                }

                Log_PerfilChangeEvent memory local_event = Log_PerfilChangeEvent({
                    id_user_alvo: _user.id,
                    id_user_executor: id_user_executor,
                    alteracao: "LEITOR -> EDITOR",
                    timestamp: block.timestamp
                });

                arrLog_PerfilChangeEvent.push(local_event);     
            }
        }
        else if (_user.perfil == enumPerfil.Editor)
        {
            if (_safeNovoStatus == enumPerfil.Leitor)
            {
                arrUsers[uint(_user.id) - 1].perfil = _safeNovoStatus;
                arrUsers[uint(_user.id) - 1].lastPerfilChangeTime = block.timestamp;

                // LOG DO EVENTO
                int id_user_executor = mapUserToId[msg.sender];
                if (id_user_executor <= 0)
                {
                    require(1==2, "O usuario que iria realizar a alteracao nao foi localizado");
                }

                Log_PerfilChangeEvent memory local_event = Log_PerfilChangeEvent({
                    id_user_alvo: _user.id,
                    id_user_executor: id_user_executor,
                    alteracao: "EDITOR -> LEITOR",
                    timestamp: block.timestamp
                });

                arrLog_PerfilChangeEvent.push(local_event);
            }               
        }
        else
        {
            // situacao impossivel. Mas... nao faz nada se cair aqui.
            require(1==2, "Pelamor. Como voce conseguiu definir o status do usuario para algo diferente do enum ???");
        }
    }
    
    function internal_cadastrarUsuario(string memory _nome, uint _Idade, address _endereco) private isAddressOk(_endereco)
    {
        require(bytes(_nome).length > 0, "Nome nao pode ser em branco");
        require(_Idade > 0, "A idade tem de ser maior do que zero");

        int check_id = mapUserToId[_endereco];
        require(check_id <= 0, "O endereco ja tem um contrato no sistema");

        // monta o usuario a ser adicionado
        Usuario memory local_user = Usuario({
            id: -1,
            nome: _nome,
            idade: _Idade,
            endereco: _endereco,
            perfil: enumPerfil.Leitor ,
            lastPerfilChangeTime: block.timestamp,
            lastDeleteRequestTime: 0
        });

        // adiciona no array de usuarios
        arrUsers.push(local_user);

        // obtem o ID dele, que e o index+1 do array de usuarios
        int id = int(arrUsers.length);

        // atualiza o campo ID no array e hashmap
        arrUsers[uint(id) - 1].id = id;
        mapUserToId[_endereco] = id;
    }

    function internal_SolicitaExclusaoUsuario(address _endereco) private isAddressOk(_endereco)
    {
        Usuario memory _user = internal_consultaUsuarioPorEndereco(_endereco);

        if (_user.lastDeleteRequestTime == uint(0))
        {
            arrUsers[uint(_user.id) - 1].lastDeleteRequestTime = block.timestamp;
        }
    }

    function internal_CancelaExclusaoUsuario(address _endereco) private isAddressOk(_endereco)
    {
        Usuario memory _user = internal_consultaUsuarioPorEndereco(_endereco);

        if (_user.lastDeleteRequestTime != uint(0))
        {
            arrUsers[uint(_user.id) - 1].lastDeleteRequestTime = 0;
        }
    }

    function internal_removeUsuario(address _endereco) private isAddressOk(_endereco) 
    {
        // Obtem o id do user sendo deletado        
        int id_to_delete = mapUserToId[_endereco];
        require(id_to_delete > 0, "Usuario nao cadastrado");

        // atribui o id sendo deletado, para o id do ultimo usuario
        // do array de users, que sera movido para a posicao do 
        // usuario sendo deletado
        arrUsers[arrUsers.length - 1].id = id_to_delete;

        // sobrescreve o user sendo apagado, com o da ultima posicao do array
        arrUsers[uint(id_to_delete) - 1] = arrUsers[arrUsers.length - 1];
        
        // remove o ultimo usuario do array de users
        arrUsers.pop();

        mapUserToId[_endereco] = int(0);
    }

    function isContractAlive() external pure returns (bool)
    {
        return true;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes ADMIN
// =============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
    function cadastrarQualquerUsuario(string memory _nome, uint _idade, address _endereco) public onlyOwner isAddressOk(_endereco)
    {
        internal_cadastrarUsuario(_nome, _idade, _endereco);
    }

    function consultaUsuarioPorEndereco(address _endereco) public view onlyOwner isAddressOk(_endereco) returns (Usuario memory)
    {
        return internal_consultaUsuarioPorEndereco(_endereco);
    }

    function setPerfilForUsuario(uint8 _novoPerfil, address _endereco) public onlyOwner isAddressOk(_endereco) 
    {
        setNovoPerfil(_novoPerfil, _endereco);
    }

    function removeUsuario(address _endereco) public onlyOwner isAddressOk(_endereco) userExists(_endereco)
    {
        internal_removeUsuario(_endereco);
    }

    function consultaLogAlteracoesPerfilUsuario(address _endereco) public view onlyOwner isAddressOk(_endereco) userExists(_endereco) returns (Log_PerfilChangeEvent[] memory)
    {
        Log_PerfilChangeEvent[] memory ret_events_empty;
        
        if (arrLog_PerfilChangeEvent.length == 0)
        {
                // array de log totalmente vazio
                return ret_events_empty;
        }
        else
        {
            Log_PerfilChangeEvent[] memory arrTemp = new Log_PerfilChangeEvent[](arrLog_PerfilChangeEvent.length);

            int _id_user_alvo = mapUserToId[_endereco];

            uint contaResult = 0;

            for (uint x = 0 ; x <= arrLog_PerfilChangeEvent.length - 1 ; x++)
            {
                if (arrLog_PerfilChangeEvent[x].id_user_alvo == _id_user_alvo)
                {
                    contaResult++;
                    arrTemp[contaResult - 1] = arrLog_PerfilChangeEvent[x];
                }
            }

            if (contaResult > 0)
            {
                Log_PerfilChangeEvent[] memory ret_events = new Log_PerfilChangeEvent[](contaResult);

                for (uint x = 0 ; x <= contaResult - 1 ; x++)
                {
                    ret_events[x] = arrTemp[x];
                }

                return ret_events;
            }
            else
            {
                return ret_events_empty;
            }
        }
    }

    function consultaUsersAguardandoDelete() public view onlyOwner returns (Usuario[] memory)
    {
        Usuario[] memory ret_usuarios_empty;
        
        if (arrUsers.length == 0)
        {
                // array de usuarios totalmente vazio
                return ret_usuarios_empty;
        }
        else
        {
            Usuario[] memory arrTemp = new Usuario[](arrUsers.length);

            uint contaResult = 0;

            for (uint x = 0 ; x <= arrUsers.length - 1 ; x++)
            {
                if (block.timestamp >= arrUsers[x].lastDeleteRequestTime + TIME_TO_CANCEL_DELETE)
                {
                    contaResult++;
                    arrTemp[contaResult - 1] = arrUsers[x];
                }
            }

            if (contaResult > 0)
            {
                Usuario[] memory ret_users = new Usuario[](contaResult);

                for (uint x = 0 ; x <= contaResult - 1 ; x++)
                {
                    ret_users[x] = arrTemp[x];
                }

                return ret_users;
            }
            else
            {
                return ret_usuarios_empty;
            }
        }
    }

    function aprovaDeleteUsuario(address _endereco) public onlyOwner isAddressOk(_endereco) userExists(_endereco)
    {
         Usuario memory _user = internal_consultaUsuarioPorEndereco(_endereco);

        if (block.timestamp >= _user.lastDeleteRequestTime + TIME_TO_CANCEL_DELETE)
        {
            internal_removeUsuario(_endereco);
        }         
    }
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes EDITORES e ADMIN
// ========================
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
    function setDadosForUsuario(address _endereco, string memory _nome, uint _idade) public onlyEditor(_endereco) userExists(_endereco) isAddressOk(_endereco) 
    {
        require(bytes(_nome).length > 0, "Nome nao pode ser em branco");
        require(_idade > 0, "A idade tem de ser maior do que zero");

        int id = mapUserToId[_endereco];
        arrUsers[uint(id) - 1].nome = _nome;
        arrUsers[uint(id) - 1].idade = _idade;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes LEITORES, EDITORES e ADMIN
// ===================================
// (Qualquer usuario eh um Leitor ou Editor, sempre, mas mesmo assim
// foi implementado o modifier onlyLeitor, para ja estar preparado
// para futuras criacoes de perfis de usuarios)
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    function consultaUsuario(address _endereco) public view onlyLeitor(msg.sender) userExists(msg.sender) returns (Usuario memory)
    {
        return internal_consultaUsuarioPorEndereco(_endereco);
    }

    function solicitaExclusaoMeuUsuario() public onlyLeitor(msg.sender) userExists(msg.sender)
    {        
        internal_SolicitaExclusaoUsuario(msg.sender);
    }

    function cancelaExclusaoMeuUsuario() public onlyLeitor(msg.sender) userExists(msg.sender)
    {
        internal_CancelaExclusaoUsuario(msg.sender);
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes LEITORES, EDITORES, COMUM e ADMIN
// =========================================
// (ou seja, funcoes liberadas para qualquer pessoa)
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
    function cadastrarMeuUsuario(string memory _nome, uint _idade) public
    {
        internal_cadastrarUsuario(_nome, _idade, msg.sender);
    }

    function consultaMeuUsuario() public view userExists(msg.sender) returns (Usuario memory)
    {
        return internal_consultaUsuarioPorEndereco(msg.sender);
    }
}