Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;
Use WORK.ScanParam.All;

Entity ParserCore_tb is
End ParserCore_tb ; 

Architecture Behavioral Of ParserCore_tb Is
	
	Component ParserCore Is
		Port(
			Clk:In STD_LOGIC;
			Reset:In STD_LOGIC;
			PixelRd:Out STD_LOGIC;
			PixelAddr:Out STD_LOGIC_VECTOR(MemAddrBits-1 DownTo 0);
			PixelData:In STD_LOGIC_VECTOR(PixelBits-1 DownTo 0);
			
			PixelWriteWr:Out STD_LOGIC;
			PixelTime:Out STD_LOGIC_VECTOR(ScanPixelBits-1 DownTo 0);
			PixelX:Out STD_LOGIC_VECTOR(15 DownTo 0);
			PixelY:Out STD_LOGIC_VECTOR(15 DownTo 0);
			
			BufferFull:In STD_LOGIC
		);
	End Component ParserCore;

	Signal Clk:STD_LOGIC:='0';
	Signal Reset:STD_LOGIC:='0';	
	Signal PixelRd:STD_LOGIC:='0';
	Signal PixelAddr:STD_LOGIC_VECTOR(MemAddrBits-1 DownTo 0):=(Others=>'0');
	Signal PixelData:STD_LOGIC_VECTOR(PixelBits-1 DownTo 0):=(Others=>'0');
	Signal PixelWriteWr:STD_LOGIC:='0';
	Signal PixelTime:STD_LOGIC_VECTOR(ScanPixelBits-1 DownTo 0):=(Others=>'0');
	Signal PixelX:STD_LOGIC_VECTOR(15 DownTo 0):=(Others=>'0');
	Signal PixelY:STD_LOGIC_VECTOR(15 DownTo 0):=(Others=>'0');
	Signal BufferFull:STD_LOGIC:='0';
	
	Constant Clk_period:TIME:=1ns; 
Begin 
	
	UUT:ParserCore
		Port Map(
			Clk=>Clk,
			Reset=>Reset,
			PixelRd=>PixelRd,
			PixelAddr=>PixelAddr,
			PixelData=>PixelData,
			
			PixelWriteWr=>PixelWriteWr,
			PixelTime=>PixelTime,
			PixelX=>PixelX,
			PixelY=>PixelY,
			
			BufferFull=>BufferFull
		);

	BufferFull<='0';
	
	Process(Clk)
	Begin
		If rising_edge(Clk) Then
			PixelData<=PixelAddr(PixelBits-1 DownTo 0);
		End If;
	End Process;

	Process
	Begin 
		Clk <='0';
		Wait For Clk_period/2;
		Clk <='1';
		Wait For Clk_period/2;
	End Process;

	Process
	Begin
		Reset<='1';
		Wait For 2ns;
		Reset<='0';
		Wait For Clk_period*10;
		Wait For 2ns;
		Wait;
	End Process; 
End Behavioral;
