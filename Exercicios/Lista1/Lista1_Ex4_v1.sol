// SPDX-License-Identifier: MTI

pragma solidity >=0.7.0 ^0.8.12;


/*
DECENTRALIZED AND DISTRIBUTED DEVELOPMENT

Lista de Exercícios 01

4 – Seu contrato é especializado em manipular arrays. Ele deve ser capaz de
receber como parâmetro um array de números inteiros (tamanho variável), sem
repetição, em tempo de compilação, e deve possuir funcionalidades para
remoção de determinado valor.
Por exemplo, em um array inicial [1,2,3], se eu invocar a funcionalidade
de remoção passando o número 2 como parâmetro, o array inicial deve virar
[1,3].
Da mesma maneira, quero ter uma funcionalidade que inclua um valor ao
final do array, para que ele cresça. Contudo, nenhum valor repetido é aceitável;
caso isto ocorra, não devo ser capaz de incluir o número.
Faça as implementações necessárias.
*/

contract Lista1_Ex4
{
    int[] private arrInicial;
    int[] private arrTemp;
    

    constructor(int[] memory _arrInicial) 
    {
        arrInicial = _arrInicial;
    }


    function removeNumber(int _valor) public
    {
        for (uint x = uint(0) ; x < arrInicial.length ; x++)
        {
            if (arrInicial[x] != _valor)
            {
                arrTemp.push(arrInicial[x]);
            }
        }

        arrInicial = arrTemp;

        delete arrTemp;
    }

    function addNumber(int _valor) public
    {
        bool numRepetido = false;

        for (uint x = uint(0) ; x < arrInicial.length ; x++)
        {
            if (arrInicial[x] == _valor)
            {
                numRepetido = true;
                break;
            }
        }

        if (numRepetido == false)
        {
            arrInicial.push(_valor);
        }
    }

    function getArray() public view returns (int[] memory)
    {
        return arrInicial;
    }

}


