Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;
Use WORK.ScanParam.All;

Entity ScanCore Is
	Port(
		WrClk:In STD_LOGIC;
		Clk:In STD_LOGIC;
		Reset:In STD_LOGIC;
		NewPixelWr:In STD_LOGIC;
		NewPixelTrig:In STD_LOGIC;
		NewPixelTime:In STD_LOGIC_VECTOR(ScanPixelBits-1 DownTo 0);
		NewPixelX:In STD_LOGIC_VECTOR(15 DownTo 0);
		NewPixelY:In STD_LOGIC_VECTOR(15 DownTo 0);
		Full:Out STD_LOGIC;
		ScanX:Out STD_LOGIC_VECTOR(13 DownTo 0);
		ScanY:Out STD_LOGIC_VECTOR(13 DownTo 0);
		Trigger:Out STD_LOGIC
	);
End Entity ScanCore;

Architecture Behavioral Of ScanCore Is

	Component PixelFIFO Is
		Port(
			aclr		: IN STD_LOGIC  := '0';
			data		: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
			rdclk		: IN STD_LOGIC ;
			rdreq		: IN STD_LOGIC ;
			wrclk		: IN STD_LOGIC ;
			wrreq		: IN STD_LOGIC ;
			q		: OUT STD_LOGIC_VECTOR (47 DOWNTO 0);
			rdempty		: OUT STD_LOGIC ;
			wrfull		: OUT STD_LOGIC 
		);
	End Component PixelFIFO;
	
	Signal Empty:STD_LOGIC;
	Signal CurPixelTrig:STD_LOGIC;
	Signal CurPixelTime:STD_LOGIC_VECTOR(ScanPixelBits-1 DownTo 0);
	Signal CurPixelX:STD_LOGIC_VECTOR(15 DownTo 0);
	Signal CurPixelY:STD_LOGIC_VECTOR(15 DownTo 0);
	Signal PixelRequest:STD_LOGIC;
	Signal PixelTimeCounter:UNSIGNED(ScanPixelBits-1 DownTo 0);
Begin

FIFO:PixelFIFO
	Port Map(
		aclr=>Reset,
		data(0)=>NewPixelTrig,
		data(ScanPixelBits-1+1 DownTo 1)=>NewPixelTime,
		data(31 DownTo 16)=>NewPixelX,
		data(47 DownTo 32)=>NewPixelY,
		rdclk=>Clk,
		rdreq=>PixelRequest,
		wrclk=>WrClk,
		wrreq=>NewPixelWr,
		q(0)=>CurPixelTrig,
		q(ScanPixelBits-1+1 DownTo 1)=>CurPixelTime,
		q(31 DownTo 16)=>CurPixelX,
		q(47 DownTo 32)=>CurPixelY,
		rdempty=>Empty,
		wrfull=>Full
	);

Process(Empty,PixelTimeCounter,CurPixelTime,Clk)
	Variable NextCounter:UNSIGNED(ScanPixelBits-1 DownTo 0);
Begin
	If Empty='1' Then
		PixelRequest<='0';
		NextCounter:=PixelTimeCounter;
	Else
		If PixelTimeCounter+1>=UNSIGNED(CurPixelTime) Then
			PixelRequest<='1';
			NextCounter:=(Others=>'0');
		Else
			PixelRequest<='0';
			NextCounter:=PixelTimeCounter+1;
		End If;
	End If;
	If rising_edge(Clk) Then
		If Reset='1'Then
			PixelTimeCounter<=(Others=>'0');
		Else
			PixelTimeCounter<=NextCounter;
		End If;
	End If;
End Process;

Process(Clk)
Begin
	If rising_edge(Clk) Then
		Trigger<=CurPixelTrig;
		ScanX<=CurPixelX(13 DownTo 0);
		ScanY<=CurPixelY(13 DownTo 0);
		If CurPixelTrig='1' Then
			ScanY<=(Others=>'0');
			ScanY(12 DownTo 11)<=(Others=>'1');
		End If;
	End If;
End Process;
	
End Behavioral;
