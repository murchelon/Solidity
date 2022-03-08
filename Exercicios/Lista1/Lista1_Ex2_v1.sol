// SPDX-License-Identifier: MTI

pragma solidity >=0.7.0 ^0.8.0;


/*
DECENTRALIZED AND DISTRIBUTED DEVELOPMENT

Lista de Exercícios 01

2 – Você está trabalhando em um contrato que se propõe a realizar operações
matemáticas simples. Este contrato possui um contador de interações que, por
decisão de negócio, deve ser inicializado com o valor de 50.
Este contrato deve possuir uma funcionalidade capaz de consultar o valor
da variável de estado, e outra função que é invocada para incrementar o valor
do contador em 1 – independentemente do endereço de origem da invocação, o
incremento deve refletir para todos os usuários.
Faça as implementações necessárias.

*/

contract Lista1_Ex2
{
    uint interacoes;

    constructor() 
    {
        interacoes = 50;
    }

    function setInteracao() public
    {
        interacoes++;
    }
    
    function getInteracao() public view returns (uint)
    {
        return interacoes;
    }
}