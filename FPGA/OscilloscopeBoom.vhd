Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;
Use WORK.ScanParam.All;

Entity OscilloscopeBoom Is
	Port(
		SClk:In STD_LOGIC;
		CryPwr:Out STD_LOGIC_VECTOR(4 DownTo 3);
		ClkOut:Out STD_LOGIC;
		
		LLC:In STD_LOGIC;
		HSync:In STD_LOGIC;
		VSync:In STD_LOGIC;
		DE:In STD_LOGIC;
		PixelData:In STD_LOGIC_VECTOR(15 DownTo 0);

		DAClk:In STD_LOGIC;
		DAMode:Out STD_LOGIC;
		DAData:Out STD_LOGIC_VECTOR(13 DownTo 0);
		DispSync:Out STD_LOGIC
	);
End Entity OscilloscopeBoom;

Architecture Behavioral Of OscilloscopeBoom Is

	--Component SFL Is
	--	Port(
	--		noe_in:In STD_LOGIC:='X'  -- noe
	--	);
	--End Component SFL;

	Component DACPLL Is
		Port(
			inclk0:In STD_LOGIC:='0';
			c0:Out STD_LOGIC;
			locked:Out STD_LOGIC
		);
	End Component DACPLL;

	Component ParsePLL Is
		Port(
			inclk0:In STD_LOGIC:='0';
			c0:Out STD_LOGIC;
			locked:Out STD_LOGIC
		);
	End Component ParsePLL;
	
	Component VGAReceiver Is
		Port(
			LLC:In STD_LOGIC;
			HSync:In STD_LOGIC;
			VSync:In STD_LOGIC;
			DE:In STD_LOGIC;
			PixelData:In STD_LOGIC_VECTOR(15 DownTo 0);
			
			PixelWriteClk:Out STD_LOGIC;
			PixelWriteWr:Out STD_LOGIC;
			PixelWriteAddr:Out STD_LOGIC_VECTOR(MemAddrBits-1 DownTo 0);
			PixelWriteData:Out STD_LOGIC_VECTOR(PixelBits-1 DownTo 0)
		);
	End Component VGAReceiver;
	
	Component DualPortRam Is
		Generic(
			AddrWidth:INTEGER:=10;
			DataWidth:INTEGER:=16
		);
		Port(
			-- Port A
			ClkA:In STD_LOGIC;
			WRA:In STD_LOGIC;
			RDA:In STD_LOGIC;
			AddrA:In STD_LOGIC_VECTOR(AddrWidth-1 DownTo 0);
			DinA:In STD_LOGIC_VECTOR(DataWidth-1 DownTo 0);
			DoutA:Out STD_LOGIC_VECTOR(DataWidth-1 DownTo 0);
			-- Port B
			ClkB:In STD_LOGIC;
			WRB:In STD_LOGIC;
			RDB:In STD_LOGIC;
			AddrB:In STD_LOGIC_VECTOR(AddrWidth-1 DownTo 0);
			DinB:In STD_LOGIC_VECTOR(DataWidth-1 DownTo 0);
			DoutB:Out STD_LOGIC_VECTOR(DataWidth-1 DownTo 0)
		);
	End Component DualPortRam;
	
	Component ParserCore Is
		Port(
			Clk:In STD_LOGIC;
			Reset:In STD_LOGIC;
			PixelRd:Out STD_LOGIC;
			PixelAddr:Out STD_LOGIC_VECTOR(MemAddrBits-1 DownTo 0);
			PixelData:In STD_LOGIC_VECTOR(PixelBits-1 DownTo 0);
			
			PixelWriteWr:Out STD_LOGIC;
			PixelTrig:Out STD_LOGIC;
			PixelTime:Out STD_LOGIC_VECTOR(ScanPixelBits-1 DownTo 0);
			PixelX:Out STD_LOGIC_VECTOR(15 DownTo 0);
			PixelY:Out STD_LOGIC_VECTOR(15 DownTo 0);
			
			BufferFull:In STD_LOGIC
		);
	End Component ParserCore;

	Component ScanCore Is
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
	End Component ScanCore;

	Signal ParseClk:STD_LOGIC;
	Signal PixelWriteClk:STD_LOGIC;
	Signal PixelWriteWr:STD_LOGIC;
	Signal PixelWriteAddr:STD_LOGIC_VECTOR(MemAddrBits-1 DownTo 0);
	Signal PixelWriteData:STD_LOGIC_VECTOR(PixelBits-1 DownTo 0);
	Signal PixelReadRd:STD_LOGIC;
	Signal PixelReadAddr:STD_LOGIC_VECTOR(MemAddrBits-1 DownTo 0);
	Signal PixelReadData:STD_LOGIC_VECTOR(PixelBits-1 DownTo 0);
	
	Signal PixelPacketWr:STD_LOGIC;
	Signal PixelPacketTrig:STD_LOGIC;
	Signal PixelPacketTime:STD_LOGIC_VECTOR(ScanPixelBits-1 DownTo 0);
	Signal PixelPacketX:STD_LOGIC_VECTOR(15 DownTo 0);
	Signal PixelPacketY:STD_LOGIC_VECTOR(15 DownTo 0);
	Signal PixelPacketBufferFull:STD_LOGIC;

Begin

	--SFL_inst:SFL
	--	Port Map(
	--		noe_in=>'1'
	--	);
	
	CryPwr<=(Others=>'1');
	DACPLL_inst:DACPLL
		Port Map(
			inclk0=>SClk,
			c0=>ClkOut,
			locked=>Open
		);
	ParsePLL_inst:ParsePLL
		Port Map(
			inclk0=>SClk,
			c0=>ParseClk,
			locked=>Open
		);

	VGARecv_inst:VGAReceiver
		Port Map(
			LLC=>LLC,
			HSync=>HSync,
			VSync=>VSync,
			DE=>DE,
			PixelData=>PixelData,
				
			PixelWriteClk=>PixelWriteClk,
			PixelWriteWr=>PixelWriteWr,
			PixelWriteAddr=>PixelWriteAddr,
			PixelWriteData=>PixelWriteData
		);
	
	FrameBuffer_inst:DualPortRam
		Generic Map(
			AddrWidth=>MemAddrBits,
			DataWidth=>PixelBits
		)
		Port Map(
			-- Port A
			ClkA=>PixelWriteClk,
			WRA=>PixelWriteWr,
			RDA=>'0',
			AddrA=>PixelWriteAddr,
			DinA=>PixelWriteData,
			DoutA=>Open,
			-- Port B
			ClkB=>ParseClk,
			WRB=>'0',
			RDB=>PixelReadRd,
			AddrB=>PixelReadAddr,
			DinB=>(Others=>'0'),
			DoutB=>PixelReadData
		);
		
	Parser_inst:ParserCore
		Port Map(
			Clk=>ParseClk,
			Reset=>'0',
			PixelRd=>PixelReadRd,
			PixelAddr=>PixelReadAddr,
			PixelData=>PixelReadData,
			
			PixelWriteWr=>PixelPacketWr,
			PixelTrig=>PixelPacketTrig,
			PixelTime=>PixelPacketTime,
			PixelX=>PixelPacketX,
			PixelY=>PixelPacketY,
			
			BufferFull=>PixelPacketBufferFull
		);

	ScanCore_inst:ScanCore
		Port Map(
			WrClk=>ParseClk,
			Clk=>DAClk,
			Reset=>'0',
			NewPixelWr=>PixelPacketWr,
			NewPixelTrig=>PixelPacketTrig,
			NewPixelTime=>PixelPacketTime,
			NewPixelX=>PixelPacketX,
			NewPixelY=>PixelPacketY,
			Full=>PixelPacketBufferFull,
			ScanX=>Open,
			ScanY=>DAData,
			Trigger=>DispSync
		);

	DAMode<='1';
	--DAData<=STD_LOGIC_VECTOR(Unsigned(ADLatched)+8192);
	
End Behavioral;
