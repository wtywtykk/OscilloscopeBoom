Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;

Entity ScanCore_tb is
End ScanCore_tb ; 

Architecture Behavioral Of ScanCore_tb Is
	Component ScanCore Is
		Port(
			Clk:In STD_LOGIC;
			Reset:In STD_LOGIC;
			NewPixelClk:In STD_LOGIC;
			NewPixelTime:In STD_LOGIC_VECTOR(15 DownTo 0);
			NewPixelX:In STD_LOGIC_VECTOR(15 DownTo 0);
			NewPixelY:In STD_LOGIC_VECTOR(15 DownTo 0);
			Full:Out STD_LOGIC;
			ScanX:Out STD_LOGIC_VECTOR(13 DownTo 0);
			ScanY:Out STD_LOGIC_VECTOR(13 DownTo 0);
			Trigger:Out STD_LOGIC
		);
	End Component ScanCore;

	Signal Clk:STD_LOGIC:='0';
	Signal Reset:STD_LOGIC:='0';
	Signal NewPixelClk:STD_LOGIC:='0';
	Signal NewPixelTime:STD_LOGIC_VECTOR(15 DownTo 0):=(Others=>'0');
	Signal NewPixelX:STD_LOGIC_VECTOR(15 DownTo 0):=(Others=>'0');
	Signal NewPixelY:STD_LOGIC_VECTOR(15 DownTo 0):=(Others=>'0');
	Signal Full:STD_LOGIC:='0';
	Signal ScanX:STD_LOGIC_VECTOR(13 DownTo 0):=(Others=>'0');
	Signal ScanY:STD_LOGIC_VECTOR(13 DownTo 0):=(Others=>'0');	
	Signal Trigger:STD_LOGIC:='0';
	
	Constant Clk_period:TIME:=1ns; 
Begin 
	UUT:ScanCore
		Port Map(
			Clk=>Clk,
			Reset=>Reset,
			NewPixelClk=>NewPixelClk,
			NewPixelTime=>NewPixelTime,
			NewPixelX=>NewPixelX,
			NewPixelY=>NewPixelY,
			Full=>Full,
			ScanX=>ScanX,
			ScanY=>ScanY,
			Trigger=>Trigger
		);

	Process
	Begin 
		Clk <='0';
		Wait For Clk_period/2;
		Clk <='1';
		Wait For Clk_period/2;
	End Process;

	Process
	Begin
		Reset<='0';
		Wait For 2ns;
		Reset<='1';
		Wait For 2ns;
		Reset<='0';
		Wait For Clk_period*10;
		Wait For 2ns;
		Wait;
	End Process; 
End Behavioral;
