// SPDX-License-Identifier: MTI

pragma solidity >=0.7.0 ^0.8.0;


/*
DECENTRALIZED AND DISTRIBUTED DEVELOPMENT

Lista de Exercícios 01

3 – Modifique o contrato anterior para que ele armazene os endereços de origem
de invocação da função de adição. Ele deve ser capaz de mostrar quem foi (o endereço) 
e quantas vezes a pessoa invocou a funcionalidade de incremento.
Deve possuir também uma funcionalidade de consulta por um endereço (por
exemplo, quero descobrir quantas vezes o endereço A já invocou a execução).

*/

contract Lista1_Ex3
{
    uint interacoes;

    mapping (address => uint) private mapAddressToCount; 

    constructor() 
    {
        interacoes = 50;
    }

    function setInteracao() public
    {
        interacoes++;
        mapAddressToCount[msg.sender]++;
    }
    
    function getInteracao() public view returns (uint)
    {
        return interacoes;
    }

    function getAddressCount(address _address) public view returns (uint)
    {
        return mapAddressToCount[_address];
    }
}