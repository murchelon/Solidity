// SPDX-License-Identifier: MTI
pragma solidity >=0.7.0 ^0.8.12;

import "./Utils.sol";

contract DateTime is Utils
{
 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// BIBLIOTECA DATETIME
// =====================
// https://github.com/pipermerriam/ethereum-datetime
// 
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


    modifier isIsoDate(string memory _date)
    {
		require(bytes(_date).length > 0, "[2] A data nao pode estar em branco");
		require(bytes(_date).length == 19, "[2] O formato da data deve ser YYYY-MM-DD HH:MM:SS");
        _;
    }



	// Retorna um Block TimeStamp, a partir de uma data no formato: YYYY-MM-DD HH:MM:SS
	function getBlockTimeStampFromDate(string memory _date) internal pure isIsoDate(_date) returns (uint)	
	{
		bytes memory stringAsBytesArray = bytes(_date);

		if ((stringAsBytesArray[4] != "-") || (stringAsBytesArray[7] != "-") || (stringAsBytesArray[10] != " ") || (stringAsBytesArray[13] != ":") || (stringAsBytesArray[16] != ":"))
		{
			require(1==2, _date);
		}

		string memory str_ano = "";
		string memory str_mes = "";
		string memory str_dia = "";       
		string memory str_hora = "";
		string memory str_minuto = "";
		string memory str_segundo = "";

		// 0  --> 2
		// 1  --> 0
		// 2  --> 2
		// 3  --> 0
		// 4  --> -
		// 5  --> 1
		// 6  --> 2
		// 7  --> -
		// 8  --> 3
		// 9  --> 1
		// 10 -->  
		// 11 --> 2
		// 12 --> 3
		// 13 --> :
		// 14 --> 5
		// 15 --> 9
		// 16 --> :
		// 17 --> 5
		// 18 --> 4		

		for(uint i = 0; i <= 3; i++)
		{
			str_ano = string(abi.encodePacked(str_ano, stringAsBytesArray[i]));
		}

		for(uint i = 5; i <= 6; i++)
		{
			str_mes = string(abi.encodePacked(str_mes, stringAsBytesArray[i]));
		}

		for(uint i = 8; i <= 9; i++)
		{
			str_dia = string(abi.encodePacked(str_dia, stringAsBytesArray[i]));
		}

		for(uint i = 11; i <= 12; i++)
		{
			str_hora = string(abi.encodePacked(str_hora, stringAsBytesArray[i]));
		}

		for(uint i = 14; i <= 15; i++)
		{
			str_minuto = string(abi.encodePacked(str_minuto, stringAsBytesArray[i]));
		}

		for(uint i = 17; i <= 18; i++)
		{
			str_segundo = string(abi.encodePacked(str_segundo, stringAsBytesArray[i]));
		}				

		uint16 ano = uint16(str2uint(str_ano));
		uint8 mes = uint8(str2uint(str_mes));
		uint8 dia = uint8(str2uint(str_dia));

		uint8 hora = uint8(str2uint(str_hora));
		uint8 minuto = uint8(str2uint(str_minuto));
		uint8 segundo = uint8(str2uint(str_segundo));

		uint ret_bts = toTimestamp(ano, mes, dia, hora, minuto, segundo);

		return ret_bts;
	}

	function getNow() internal view returns (string memory)
	{
		return getNow(block.timestamp, 1, 0);
	}

	function getNow(uint timeStamp) internal pure returns (string memory)
	{
		return getNow(timeStamp, 1, 0);
	}

	function getNow(uint timeStamp, uint showTime) internal pure returns (string memory)
	{
		return getNow(timeStamp, showTime, 0);
	}

	function getNow(uint timeStamp, uint showTime, uint showIsoDate) internal pure returns (string memory)
	{
		uint16 ano;
		uint8 mes;
		uint8 dia;       
		uint8 hora;
		uint8 minuto;
		uint8 segundo;

		string memory str_mes;
		string memory str_dia;       
		string memory str_hora;
		string memory str_minuto;
		string memory str_segundo;

		ano = getYear(timeStamp);
		mes = getMonth(timeStamp);
		dia = getDay(timeStamp);
		hora = getHour(timeStamp);
		minuto = getMinute(timeStamp);
		segundo = getSecond(timeStamp);

		string memory charToUse;

		if (showIsoDate == 1)
		{
			charToUse = "-";
		}
		else
		{
			charToUse = "/";
		}

		if (dia <= 9)
		{
			if (showIsoDate == 1)
			{
				str_dia = string(abi.encodePacked("0", uint2str(dia)));
			}
			else
			{
				str_dia = string(abi.encodePacked("0", uint2str(dia), charToUse));
			}
		}
		else
		{
			if (showIsoDate == 1)
			{
				str_dia = uint2str(dia);
			}
			else
			{
				str_dia = string(abi.encodePacked(uint2str(dia), charToUse));
			}	
		}

		if (mes <= 9)
		{
			str_mes = string(abi.encodePacked("0", uint2str(mes), charToUse));
		}
		else
		{
			str_mes = string(abi.encodePacked(uint2str(mes), charToUse));
		}

		if (hora <= 9)
		{
			str_hora = string(abi.encodePacked("0", uint2str(hora), ":"));
		}
		else
		{
			str_hora = string(abi.encodePacked(uint2str(hora), ":"));
		}

		if (minuto <= 9)
		{
			str_minuto = string(abi.encodePacked("0", uint2str(minuto), ":"));
		}
		else
		{
			str_minuto = string(abi.encodePacked(uint2str(minuto), ":"));
		}

		if (segundo <= 9)
		{
			str_segundo = string(abi.encodePacked("0", uint2str(segundo)));
		}
		else
		{
			str_segundo = uint2str(segundo);
		}

		string memory ret;

		if (showTime == 1)
		{
			if (showIsoDate == 1)
			{
				ret = string(abi.encodePacked(uint2str(ano), "-", str_mes, str_dia, " ", str_hora, str_minuto, str_segundo));
			}
			else
			{
				ret = string(abi.encodePacked(str_dia, str_mes, uint2str(ano), " ", str_hora, str_minuto, str_segundo));
			}			
		}
		else
		{
			if (showIsoDate == 1)
			{
				ret = string(abi.encodePacked(uint2str(ano), "-", str_mes, str_dia));
			}
			else
			{
				ret = string(abi.encodePacked(str_dia, str_mes, uint2str(ano)));
			}			
		}

		return ret;
	}


    /*
    bib inicia aqui
    *  Date and Time utilities for ethereum contracts
    *
    */
    struct _DateTime {
            uint16 year;
            uint8 month;
            uint8 day;
            uint8 hour;
            uint8 minute;
            uint8 second;
            uint8 weekday;
    }

    uint constant DAY_IN_SECONDS = 86400;
    uint constant YEAR_IN_SECONDS = 31536000;
    uint constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint constant HOUR_IN_SECONDS = 3600;
    uint constant MINUTE_IN_SECONDS = 60;

    uint16 constant ORIGIN_YEAR = 1970;

    // function getNow() public returns (_DateTime memory)
    // function getNow() public returns (uint)
    // {
    //     _DateTime memory dt;

    //     dt = parseTimestamp(block.timestamp);

    //     return block.timestamp;
    // }


    function isLeapYear(uint16 year) public pure returns (bool) {
            if (year % 4 != 0) {
                    return false;
            }
            if (year % 100 != 0) {
                    return true;
            }
            if (year % 400 != 0) {
                    return false;
            }
            return true;
    }

    function leapYearsBefore(uint year) public pure returns (uint) {
            year -= 1;
            return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
            if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                    return 31;
            }
            else if (month == 4 || month == 6 || month == 9 || month == 11) {
                    return 30;
            }
            else if (isLeapYear(year)) {
                    return 29;
            }
            else {
                    return 28;
            }
    }

    function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory dt) {
            uint secondsAccountedFor = 0;
            uint buf;
            uint8 i;

            // Year
            dt.year = getYear(timestamp);
            buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

            secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
            secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

            // Month
            uint secondsInMonth;
            for (i = 1; i <= 12; i++) {
                    secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                    if (secondsInMonth + secondsAccountedFor > timestamp) {
                            dt.month = i;
                            break;
                    }
                    secondsAccountedFor += secondsInMonth;
            }

            // Day
            for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                    if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                            dt.day = i;
                            break;
                    }
                    secondsAccountedFor += DAY_IN_SECONDS;
            }

            // Hour
            dt.hour = getHour(timestamp);

            // Minute
            dt.minute = getMinute(timestamp);

            // Second
            dt.second = getSecond(timestamp);

            // Day of week.
            dt.weekday = getWeekday(timestamp);
    }

    function getYear(uint timestamp) public pure returns (uint16) {
            uint secondsAccountedFor = 0;
            uint16 year;
            uint numLeapYears;

            // Year
            year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
            numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

            secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
            secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

            while (secondsAccountedFor > timestamp) {
                    if (isLeapYear(uint16(year - 1))) {
                            secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                    }
                    else {
                            secondsAccountedFor -= YEAR_IN_SECONDS;
                    }
                    year -= 1;
            }
            return year;
    }

    function getMonth(uint timestamp) public pure returns (uint8) {
            return parseTimestamp(timestamp).month;
    }

    function getDay(uint timestamp) public pure returns (uint8) {
            return parseTimestamp(timestamp).day;
    }

    function getHour(uint timestamp) public pure returns (uint8) {
            return uint8((timestamp / 60 / 60) % 24);
    }

    function getMinute(uint timestamp) public pure returns (uint8) {
            return uint8((timestamp / 60) % 60);
    }

    function getSecond(uint timestamp) public pure returns (uint8) {
            return uint8(timestamp % 60);
    }

    function getWeekday(uint timestamp) public pure returns (uint8) {
            return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {
            return toTimestamp(year, month, day, 0, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp) {
            return toTimestamp(year, month, day, hour, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp) {
            return toTimestamp(year, month, day, hour, minute, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {
            uint16 i;

            // Year
            for (i = ORIGIN_YEAR; i < year; i++) {
                    if (isLeapYear(i)) {
                            timestamp += LEAP_YEAR_IN_SECONDS;
                    }
                    else {
                            timestamp += YEAR_IN_SECONDS;
                    }
            }

            // Month
            uint8[12] memory monthDayCounts;
            monthDayCounts[0] = 31;
            if (isLeapYear(year)) {
                    monthDayCounts[1] = 29;
            }
            else {
                    monthDayCounts[1] = 28;
            }
            monthDayCounts[2] = 31;
            monthDayCounts[3] = 30;
            monthDayCounts[4] = 31;
            monthDayCounts[5] = 30;
            monthDayCounts[6] = 31;
            monthDayCounts[7] = 31;
            monthDayCounts[8] = 30;
            monthDayCounts[9] = 31;
            monthDayCounts[10] = 30;
            monthDayCounts[11] = 31;

            for (i = 1; i < month; i++) {
                    timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
            }

            // Day
            timestamp += DAY_IN_SECONDS * (day - 1);

            // Hour
            timestamp += HOUR_IN_SECONDS * (hour);

            // Minute
            timestamp += MINUTE_IN_SECONDS * (minute);

            // Second
            timestamp += second;

            return timestamp;
    }  
}



