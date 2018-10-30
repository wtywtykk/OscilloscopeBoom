Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;

Entity DualPortRam Is
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
End Entity DualPortRam;

Architecture Behavioral Of DualPortRam Is
   --Shared memory
   Type Mem_Type Is Array((2**AddrWidth)-1 DownTo 0) Of STD_LOGIC_VECTOR(DataWidth-1 DownTo 0);
   Shared Variable Mem:Mem_Type;
Begin

	--Port A
	Process(ClkA)
	Begin
		If rising_edge(ClkA) Then
			If WRA='1' Then
				Mem(To_Integer(UNSIGNED(AddrA))):=DinA;
			End If;
			If RDA='1' Then
				DoutA<= Mem(To_Integer(UNSIGNED(AddrA)));
			End If;
		End If;
	End Process;
	
	--Port B
	Process(ClkB)
	Begin
		If rising_edge(ClkB) Then
			If WRB='1' Then
				Mem(To_Integer(UNSIGNED(AddrB))):=DinB;
			End If;
			If RDB='1' Then
				DoutB<= Mem(To_Integer(UNSIGNED(AddrB)));
			End If;
		End If;
	End Process;

End Behavioral;
