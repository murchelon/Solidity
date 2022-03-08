// SPDX-License-Identifier: MTI

pragma solidity >=0.7.0 ^0.8.12;

import "hardhat/console.sol";

/*
DECENTRALIZED AND DISTRIBUTED DEVELOPMENT

Lista de Exercícios 01

5 – Você está trabalhando em um contrato que cadastra pessoas (identificadas
pelos seus endereços) aos serviços oferecidos pela sua solução. Em um dado
momento, os status do contrato podem ser: Em análise, Liberado, Cancelado e
Rejeitado.
Crie as funções necessárias para implementar funcionalidades que
relacionem endereços com os status possíveis, e para fazer suas consultas
(posso querer saber qual o status do endereço A, por exemplo).
Contratos Rejeitados não podem ter seu status alterado em qualquer
hipótese.
Contratos Liberados podem ser Cancelados, porém, não podem voltar
para o status Em Análise.
Contratos Cancelados, por sua vez, só podem passar para o status Em
Análise.
Um contrato pode ser Rejeitado em qualquer ponto.
Por segurança, só posso modificar o status de um endereço após pelo
menos 30 segundos da última alteração.

funcoes:

- cadastrar (entra como em analise)
- consulta status atual
- Liberar Contrato      (EmAnalise -> Liberado)
- Cancelar Contrato     (Liberado  -> Cancelado)
- Reanalizar Contrato   (Cancelado -> EmAnalse)
- Rejeitar Contrato     (Qualquer  -> Rejeitado)

regras:
- Liberados: podem ser cancelados, mas nao pode voltar a ser EmAnlise
- Cancelados: podem voltar a ser EmAnalise
- Rejeitado: pode assumir este status mesmo estando em qualquer estado. 
- Rejeitado: Uma vez rejeitado, nunca mais altera o status
- 10 segundos de delay para alterar para outro status, desde a ultima alteracao
- Um endereco só pode ter 1 contrato por vez, em qualquer status

*/

contract Lista1_Ex5
{
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Inicializacao
// =============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    enum enumStatus {EmAnalise, Liberado, Cancelado, Rejeitado}
    
    struct Usuario
    {
        int id;
        string nome;
        address endereco;
        enumStatus status;
        uint lastStatusUpdateTime;
    }

    // mapeamento de endereco para ID do array (id = index + 1). Logo, ID = 0 significa que NAO existe o cadastro no hashmap
    // hashmap de int retorna ZERO , quando NAO ENCONTRA o endereco procurado
    mapping (address => int) private mapUserToId;   // id = 0: nao existe o cadastro no array de usuarios

    Usuario[] private arrUsers;

    address private owner;

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

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes DEBUG
// =============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
     function getArray() public view onlyOwner returns (Usuario[] memory)
    {
        return arrUsers;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes HELPER
// ==============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function toEnumStatusFromUint8(uint8 _valor) private pure returns (enumStatus)
    {
        // enumStatus {EmAnalise, Liberado, Cancelado, Rejeitado}
        if (_valor == 0)
        {
            return enumStatus.EmAnalise;
        }
        else if (_valor == 1)
        {
            return enumStatus.Liberado;
        }
        else if (_valor == 2)
        {
            return enumStatus.Cancelado;
        }
        else if (_valor == 3)
        {
            return enumStatus.Rejeitado;
        }
        else
        {
            return enumStatus.EmAnalise;
        }        
    }

    function toUint8FromEnumStatus(enumStatus _status) private pure returns (uint8)
    {
        // enumStatus {EmAnalise, Liberado, Cancelado, Rejeitado}
        if (_status == enumStatus.EmAnalise)
        {
            return uint8(0);
        }
        else if (_status == enumStatus.Liberado)
        {
            return uint8(1);
        }
        else if (_status == enumStatus.Cancelado)
        {
            return uint8(2);
        }
        else if (_status == enumStatus.Rejeitado)
        {
            return uint8(3);
        }
        else
        {
            return uint8(0);
        }         
    }

    function internal_consultaContratoPorEndereco(address _endereco) private view isAddressOk(_endereco) returns (Usuario memory)
    {
        int id = mapUserToId[_endereco];
        require(id > 0, "Usuario nao cadastrado");

        return arrUsers[uint(id) - 1];
    }

    function setContratoStatusParaUsuario(address _endereco, uint8 _novoStatus) private isAddressOk(_endereco)
    {
        // https://ethereum.stackexchange.com/questions/80350/how-to-handle-enums-as-arguments-for-public-functions
        // um atacante poderia chamar o contrato com um enum errado e isto faz com que o require abaixo nao seja executado e um erro ocorra, 
        // usando um optcode diferente do que deveria, para ocorrer o require abaixo.
        // aparentemente, isto consome todo o gas... preciso entender melhor, mas parece que esta é a forma mais segura que impede isto
        // (converter para uint8 antes e testar como uint8)
        require(_novoStatus <= uint8(enumStatus.Rejeitado), "Status invalido");

        enumStatus _safeNovoStatus;

        _safeNovoStatus = toEnumStatusFromUint8(_novoStatus);

        Usuario memory _user = internal_consultaContratoPorEndereco(_endereco);

        // regras de negocio:

        // - EmAnalise: Pode ser liberado 
        // - Liberados: podem ser cancelados, mas nao pode voltar a ser EmAnlise
        // - Cancelados: podem voltar a ser EmAnalise
        // - Rejeitado: pode assumir este status mesmo estando em qualquer estado. 
        // - Rejeitado: Uma vez rejeitado, nunca mais altera o status

        // enumStatus {EmAnalise, Liberado, Cancelado, Rejeitado}

        // - Liberar Contrato      (EmAnalise -> Liberado)
        // - Cancelar Contrato     (Liberado  -> Cancelado)
        // - Reanalizar Contrato   (Cancelado -> EmAnalse)
        // - Rejeitar Contrato     (Qualquer  -> Rejeitado)

        // se a ultima alteracao de status ocorreu a menos de 30 segundos, entao, não permite a alteracao

        // console.log("block.timestamp: ", block.timestamp);
        // console.log("_user.lastStatusUpdateTime: ", _user.lastStatusUpdateTime);
        
        if (block.timestamp < (_user.lastStatusUpdateTime + 10 seconds))        
        {
            require(1==2, "Alteracoes de status so podem ser feitas apos 10 segudos da ultima atualizacao");
        }

        if (_user.status == enumStatus.EmAnalise)
        {
            if ((_safeNovoStatus == enumStatus.Liberado) || (_safeNovoStatus == enumStatus.Rejeitado))
            {
                arrUsers[uint(_user.id) - 1].status = _safeNovoStatus;
                arrUsers[uint(_user.id) - 1].lastStatusUpdateTime = block.timestamp;                
            }
            else
            {
                require(1==2, "Contratos 'Em Analise' so podem ser liberados ou rejeitados");
            }
        }
        else if (_user.status == enumStatus.Liberado)
        {
            if ((_safeNovoStatus == enumStatus.Cancelado) || (_safeNovoStatus == enumStatus.Rejeitado))
            {
                arrUsers[uint(_user.id) - 1].status = _safeNovoStatus;
                arrUsers[uint(_user.id) - 1].lastStatusUpdateTime = block.timestamp;
            }        
            else
            {
                require(1==2, "Contratos 'Liberados' so podem ser cancelados ou rejeitados");
            }                
        }
        else if (_user.status == enumStatus.Cancelado)
        {
            if ((_safeNovoStatus == enumStatus.EmAnalise) || (_safeNovoStatus == enumStatus.Rejeitado))
            {
                arrUsers[uint(_user.id) - 1].status = _safeNovoStatus;
                arrUsers[uint(_user.id) - 1].lastStatusUpdateTime = block.timestamp;
            }      
            else
            {
                require(1==2, "Contratos 'Cancelados' so podem ser reanalizados ou rejeitados");
            }                    
        }
        else if (_user.status == enumStatus.Rejeitado)
        {
            // Nao faz nada. Contratos rejeitados nao podem ter seu status alterado
            require(1==2, "Contratos 'Rejeitados' nao podem ser alterados");
        }
        else
        {
            // situacao impossivel. Mas... nao faz nada se cair aqui.
            require(1==2, "Pelamor. Como voce conseguiu definir o status do contrato para algo diferente do enum ???");
        }
    }
    
    function cadastrarUsuario(string memory _nome, address _endereco) private isAddressOk(_endereco)
    {
        require(bytes(_nome).length > 0, "Nome nao pode ser em branco");

        int check_id = mapUserToId[_endereco];
        require(check_id <= 0, "O endereco ja tem um contrato no sistema");

        // monta o usuario a ser adicionado
        Usuario memory local_user = Usuario({
            id: -1,
            nome: _nome,
            endereco: _endereco,
            status: enumStatus.EmAnalise ,
            lastStatusUpdateTime: block.timestamp
        });

        // adiciona no array de usuarios
        arrUsers.push(local_user);

        // obtem o ID dele, que é o index+1 do array de usuarios
        int id = int(arrUsers.length);

        // atualiza o campo ID no array e hashmap
        arrUsers[uint(id) - 1].id = id;
        mapUserToId[_endereco] = id;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes ADMIN
// =============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
    function liberarContrato(address _endereco) public onlyOwner isAddressOk(_endereco)
    {
        setContratoStatusParaUsuario(_endereco, toUint8FromEnumStatus(enumStatus.Liberado));
    }

    function cancelarContrato(address _endereco) public onlyOwner isAddressOk(_endereco)
    {
        setContratoStatusParaUsuario(_endereco, toUint8FromEnumStatus(enumStatus.Cancelado));
    }

    function reanalizarContrato(address _endereco) public onlyOwner isAddressOk(_endereco)
    {
        setContratoStatusParaUsuario(_endereco, toUint8FromEnumStatus(enumStatus.EmAnalise));
    }

    function rejeitarContrato(address _endereco) public onlyOwner isAddressOk(_endereco)
    {
        setContratoStatusParaUsuario(_endereco, toUint8FromEnumStatus(enumStatus.Rejeitado));
    }

    function cadastrarQualquerUsuario(string memory _nome, address _endereco) public onlyOwner isAddressOk(_endereco)
    {
        cadastrarUsuario(_nome, _endereco);
    }

    function consultaContratoPorEndereco(address _endereco) public view onlyOwner isAddressOk(_endereco) returns (Usuario memory)
    {
        return internal_consultaContratoPorEndereco(_endereco);
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes PUBLICAS
// ================
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
    function consultaqMeuContrato() public view returns (Usuario memory)
    {
        return internal_consultaContratoPorEndereco(msg.sender);
    }

    function cadastrarMeuUsuario(string memory _nome) public
    {
        cadastrarUsuario(_nome, msg.sender);
    }

}