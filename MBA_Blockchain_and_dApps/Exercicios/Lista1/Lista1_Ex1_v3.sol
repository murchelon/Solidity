// SPDX-License-Identifier: MTI

pragma solidity >=0.7.0 ^0.8.0;


/*
DECENTRALIZED AND DISTRIBUTED DEVELOPMENT

Lista de Exercícios 01

1 – Você está trabalhando em um contrato que realiza o acompanhamento da
vida dos usuários. Ele possui uma função que realiza a classificação do ser
humano, conforme sua idade (recebida por parâmetro), em três fases da sua
vida: criança (se tiver menos do que 18 anos), adulto (se tiver 18 anos ou mais)
e idoso (se tiver 60 anos ou mais).
Implemente as funções necessárias para criar uma base de dados
contendo os usuários (identificados pelo seu nome), sua idade e classificação, e
para realizar a consulta, quando um nome for enviado como um parâmetro. Por
simplificação, assumimos que nenhum nome de usuário se repetirá.
*/

/*
comentarios:

1 - Nao tem acentuacao nas respostas? 
2 - Nao usamos strings, certo? Como testar strings em branco de forma eficiente? Quando precisar usar string, como fazer da melhor maneira?
3 - Meeeu nao tem um console.log !?!? kkkk rodei. Debug no remix ok.. no resto (vscode)?
4 - Em um mapping.. ele é um array, certo? posso usar.. qquer coisa no index dele? Um address, uma string... certo ?
5 - COmo nao uso um array arrUsuarios e uso direto.. Usuarios do mapping.. como faço entaõ para pesquisar uma propriedade. Ex: Pesquisa por Address, neste exemplo. Eu teria obrigatoriamente de usar um array, certo ?


*/


contract Lista1_Ex1
{
    enum Classificacao {Crianca, Adulto, Idoso, HighLander}

    // objeto usuario
    struct Usuario
    {
        string nome;    // chave primaria
        Classificacao classificacao;  
        uint idade;
        bool ativo;
        address endereco_owner;
    }

    // array que contem os usuarios cadastrados
    Usuario[] arrUsuarios;

    // map com o NOME do usuario apontanto para um INDEX no ARRAY DE USUARIOS
    mapping (string => uint) private mapNomeToIndex;

    // funcao que adiciona um usuario no array de usuarios
    function addUser (string memory _nome, uint _idade) public 
    {
        require(_idade >= 0, "A idade tem de ser maior do que zero");
        require(keccak256(abi.encodePacked(_nome)) != keccak256(abi.encodePacked("")), "O nome nao pode estar em branco");
        require(mapNomeToIndex[_nome] == 0, "O usuario ja existe");

        Usuario memory local_user;

        local_user = Usuario({
            nome: _nome,
            classificacao: classificaUser(_idade),
            idade: _idade,
            ativo: true,
            endereco_owner: msg.sender            
        });

        arrUsuarios.push(local_user);
        uint id = arrUsuarios.length;

        mapNomeToIndex[_nome] = id;
    }

    //debug:
    function getVar() public view returns (string memory)
    {
        Usuario memory local_user;

        local_user = Usuario({
            nome: "marcelo",
            classificacao: classificaUser(12),
            idade: 12,
            ativo: true,
            endereco_owner: msg.sender            
        });

        return _prepareOutput(local_user);
    }

    // funcao que retorna o objeto usuario, a partir de um nome
    function getUserByNome(string memory _nome) public view returns (string memory)
    {
        require(keccak256(abi.encodePacked(_nome)) != keccak256(abi.encodePacked("")), "O nome nao pode estar em branco");
        require(mapNomeToIndex[_nome] != 0, "O usuario nao existe");
        
        Usuario memory local_usuario;

        uint id = mapNomeToIndex[_nome] - 1;
        local_usuario = arrUsuarios[id];

        return _prepareOutput(local_usuario);
    }


    // funcao que retorna o objeto usuario, a partir de um endereco. Retorna apenas a primeira ocorrencia do endereco, caso existam mais de uma
    function getUserByAddress(address _address) public view returns (string memory)
    {
        require(_address != 0x0000000000000000000000000000000000000000, "O endereco nao pode estar em branco");

        for (uint x = 0 ; x <= arrUsuarios.length - 1 ; x++)
        {
            if (arrUsuarios[x].endereco_owner == _address)
            {
                Usuario memory local_usuario;

                local_usuario = arrUsuarios[x];

                return _prepareOutput(local_usuario);                  
            }
        }

        return "Usuario nao localizado";
    }


    // funcao que classifica um usuario baseado na idade
    function classificaUser(uint _idade) pure internal returns (Classificacao)
    {
        Classificacao local_classificacao;

        if (_idade < 18)
        {
            local_classificacao = Classificacao.Crianca;
        }
        else if (_idade >= 18 && _idade < 60)
        {
            local_classificacao = Classificacao.Adulto;
        }
        else if (_idade >= 60 && _idade < 120)
        {
            local_classificacao = Classificacao.Idoso;
        }
        else
        {
            local_classificacao = Classificacao.HighLander;
        }

        return local_classificacao;
    }

    // funcao que recebe alguns valores string e contatena os mesmos, para formatacao da resposta
    function _prepareOutput(Usuario memory _user) internal pure returns (string memory) 
    {        
        // string memory strIdade = Strings.toString(_user.idade);

        string memory strAddress = toAsciiString(_user.endereco_owner);
        string memory strClassificacao;

        if (_user.classificacao == Classificacao.Crianca)
        {
            strClassificacao = "Crianca";
        }
        else if (_user.classificacao == Classificacao.Adulto)
        {
            strClassificacao = "Adulto";
        }
        else if (_user.classificacao == Classificacao.Idoso)
        {
            strClassificacao = "Idoso";
        }
        else if (_user.classificacao == Classificacao.HighLander)
        {
            strClassificacao = "HighLander!!!!";
        }

        return string(abi.encodePacked("Nome: ", _user.nome, " | Classificacao: ", strClassificacao, " | Idade: ", uint2str(_user.idade), " | address: ", strAddress));
    }

    // FUNCOES DE SUPORTE ==================================================================
    
    function uint2str(uint _i) internal pure returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint(uint160(x)) / (2**(8*(19 - i)))));
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);            
        }
        return string(s);
    }

    function char(bytes1 b) internal pure returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    // FIM - FUNCOES DE SUPORTE ==================================================================
}