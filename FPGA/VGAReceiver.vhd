Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;
Use WORK.ScanParam.All;

Entity VGAReceiver Is
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
End Entity VGAReceiver;

Architecture Behavioral Of VGAReceiver Is
	Constant LLCPol:STD_LOGIC:='1';
	Constant HSyncPol:STD_LOGIC:='0';
	Constant VSyncPol:STD_LOGIC:='0';
	Constant DEPol:STD_LOGIC:='1';
	
	Signal RealLLC:STD_LOGIC;
	Signal RealHSync:STD_LOGIC;
	Signal RealVSync:STD_LOGIC;
	Signal RealDE:STD_LOGIC;
	
	--Pineline stage 0
	Signal HSyncLatched:STD_LOGIC;
	Signal HCounter:UNSIGNED(VGADimensionBits-1 DownTo 0);
	Signal VCounter:UNSIGNED(VGADimensionBits-1 DownTo 0);
	
	--Pineline stage 1
	Signal ReverseLine_Stage1:STD_LOGIC;
	Signal HCounter_Stage1:UNSIGNED(VGADimensionBits-1 DownTo 0);
	Signal VCounter_Stage1:UNSIGNED(VGADimensionBits-1 DownTo 0);
	Signal DE_Stage1:STD_LOGIC;
	
	--Pineline stage 2
	Signal DivideResult:STD_LOGIC_VECTOR(9 DownTo 0);
	Signal MemAddr_Stage2:UNSIGNED(VGADimensionBits*2-1 DownTo 0);
	Signal DE_Stage2:STD_LOGIC;
	
	Component DIV Is
		Port(
			clock		: IN STD_LOGIC ;
			denom		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			numer		: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
			quotient		: OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
			remain		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
		);
	End Component DIV;
	
Begin

	RealLLC<=LLC Xor Not LLCPol;
	RealHSync<=HSync Xor Not HSyncPol;
	RealVSync<=VSync Xor Not VSyncPol;
	RealDE<=DE Xor Not DEPol;

	Div_inst:DIV
		Port Map(
			clock=>RealLLC,
			denom=>"11",
			numer=>PixelData(9 DownTo 0),
			quotient=>DivideResult
		);

	Process(RealLLC)
	Begin
		If rising_edge(RealLLC) Then
			If RealDE='1' Then
				HCounter<=HCounter+1;
			End If;
			If RealHSync='1' Then
				HCounter<=(Others=>'0');
				If (HSyncLatched/=RealHSync) And (HCounter/=0) Then
					VCounter<=VCounter+1;
				End If;
			End If;
			If RealVSync='1' Then
				VCounter<=(Others=>'0');
			End If;
			HSyncLatched<=RealHSync;
		End If;
	End Process;

	Process(RealLLC)
	Begin
		If rising_edge(RealLLC) Then
			If (HCounter Mod 2)=1 Then
				ReverseLine_Stage1<='1';
			Else
				ReverseLine_Stage1<='0';
			End If;
			HCounter_Stage1<=HCounter-ScanLeft;
			VCounter_Stage1<=VCounter-ScanTop;
			If (HCounter>=ScanLeft) And (HCounter<ScanLeft+ScanWidth) And (VCounter>=ScanTop) And (VCounter<ScanTop+ScanHeight) Then
				DE_Stage1<=RealDE;
			Else
				DE_Stage1<='0';
			End If;
		End If;
	End Process;

	Process(RealLLC)
	Begin
		If rising_edge(RealLLC) Then
			If ReverseLine_Stage1='0' Then
				MemAddr_Stage2<=HCounter_Stage1*ScanHeight+VCounter_Stage1;
			Else
				MemAddr_Stage2<=HCounter_Stage1*ScanHeight+ScanHeight-1-VCounter_Stage1;
			End If;
			DE_Stage2<=DE_Stage1;
		End If;
	End Process;

	Process(RealLLC)
	Begin
		PixelWriteClk<=RealLLC;
		If rising_edge(RealLLC) Then
			PixelWriteAddr<=STD_LOGIC_VECTOR(MemAddr_Stage2(MemAddrBits-1 DownTo 0));
			PixelWriteData<=DivideResult(7 DownTo 8-PixelBits);
			PixelWriteWr<=DE_Stage2;
		End If;
	End Process;

End Behavioral;
