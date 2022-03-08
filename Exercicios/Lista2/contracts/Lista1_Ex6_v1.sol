// SPDX-License-Identifier: MTI

pragma solidity >=0.7.0 ^0.8.12;

// import "hardhat/console.sol";

/*
DECENTRALIZED AND DISTRIBUTED DEVELOPMENT

Lista de Exercícios 01

6 – Crie um contrato capaz de controlar a matrícula de alunos (identificados por
seu nome e idade) à determinada disciplina (para facilitar, podemos considerar
o contrato como sendo a própria disciplina). O aluno só pode se matricular uma
única vez à disciplina.
Apenas alunos com idade igual a 18 anos podem se matricular na
disciplina. O nome do aluno é um parâmetro obrigatório, e podemos ter alunos
com o mesmo nome.
Na prática, cada aluno é um endereço de origem, então um endereço A
pode se matricular uma única vez, por exemplo.
O contrato deve possuir funções para a inclusão deste aluno, para
consulta (verificar se determinado aluno está matriculado), para verificar quantos
alunos estão matriculados no total e posso querer remover um aluno da lista de
matrícula – porém, apenas o endereço que fez a matrícula é o endereço que
pode fazer a remoção

*/

contract Lista1_Ex6
{
    
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Inicializacao
// =============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    struct Aluno
    {
        int id;
        string nome;
        uint idade;
        address endereco;
        uint lastStatusUpdateTime;
    }

    mapping (address => int) private mapAlunoToId;   // id = 0: nao existe o cadastro no array de alunos

    Aluno[] private arrAlunos;

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
 
     function getArray() public view onlyOwner returns (Aluno[] memory)
    {
        return arrAlunos;
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes HELPER
// ==============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    function internal_consultaAlunoPorEndereco(address _endereco) private view isAddressOk(_endereco) returns (Aluno memory)
    {
        int id = mapAlunoToId[_endereco];
        require(id > 0, "Aluno nao cadastrado");

        return arrAlunos[uint(id) - 1];
    }
    
    function cadastrarAluno(string memory _nome, uint _idade, address _endereco) private isAddressOk(_endereco)
    {
        require(bytes(_nome).length > 0, "Nome nao pode ser em branco");
        require(_idade >= 18, "A idade minima para se cadastrar eh 18 anos");

        int check_id = mapAlunoToId[_endereco];
        require(check_id <= 0, "O endereco ja tem um cadastro no sistema");

        // monta o aluno a ser adicionado
        Aluno memory local_aluno = Aluno({
            id: -1,
            nome: _nome,
            idade: _idade,
            endereco: _endereco,
            lastStatusUpdateTime: block.timestamp
        });

        // adiciona no array de alunos
        arrAlunos.push(local_aluno);

        // obtem o ID dele, que é o index+1 do array de alunos
        int id = int(arrAlunos.length);

        // atualiza o campo ID no array e hashmap
        arrAlunos[uint(id) - 1].id = id;
        mapAlunoToId[_endereco] = id;
    }

    function internal_removeMatriculaAluno(address _endereco) private isAddressOk(_endereco)
    {
        int id = mapAlunoToId[_endereco];
        require(id > 0, "Aluno nao cadastrado");

        arrAlunos[uint(id) - 1] = arrAlunos[arrAlunos.length - 1];

        arrAlunos.pop();

        mapAlunoToId[_endereco] = int(0);
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes ADMIN
// =============
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
    function cadastrarQualquerAluno(string memory _nome, uint _idade, address _endereco) public onlyOwner isAddressOk(_endereco)
    {
        cadastrarAluno(_nome, _idade, _endereco);
    }

    function consultaAlunoPorEndereco(address _endereco) public view onlyOwner isAddressOk(_endereco) returns (Aluno memory)
    {
        return internal_consultaAlunoPorEndereco(_endereco);
    }
    
    function consultaTotalAlunosMatriculados() public view onlyOwner returns (uint)
    {
        return arrAlunos.length;
    }

    function removeMatriculaQualquerAluno(address _endereco) public onlyOwner
    {
        internal_removeMatriculaAluno(_endereco);
    }

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Funcoes PUBLICAS
// ================
//
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
 
    function consultaMeuCadastro() public view returns (Aluno memory)
    {
        return internal_consultaAlunoPorEndereco(msg.sender);
    }

    function realizarMeuCadastro(string memory _nome, uint _idade) public
    {
        cadastrarAluno(_nome, _idade, msg.sender);
    }

    function removeMinhaMatricula() public
    {
        internal_removeMatriculaAluno(msg.sender);
    }

    function isContractAlive() public pure returns (bool)
    {
        return true;
    }
}