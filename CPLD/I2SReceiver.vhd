Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;

Entity I2SReceiver Is
	Port(
		LRCLK:In STD_LOGIC;
		AP:In STD_LOGIC;
		SCLK:In STD_LOGIC;
		
		DataClk:Out STD_LOGIC;
		LData:Out STD_LOGIC_VECTOR(31 DownTo 0);
		RData:Out STD_LOGIC_VECTOR(31 DownTo 0)
	);
End Entity I2SReceiver;

Architecture Behavioral Of I2SReceiver Is
	Signal LastLRCLK:STD_LOGIC;
	Signal DataBuffer:STD_LOGIC_VECTOR(31 DownTo 0);
Begin

	Process(SCLK)
	Begin
		If rising_edge(SCLK) Then
			DataClk<='0';
			If LRCLK='1' Then
				If LastLRCLK='0' Then
					RData<=DataBuffer;
					DataClk<='1';
				End If;
			Else
				If LastLRCLK='1' Then
					LData<=DataBuffer;
					DataClk<='1';
				End If;
			End If;
			LastLRCLK<=LRCLK;
			DataBuffer<=DataBuffer(30 DownTo 0) & AP;
		End If;
	End Process;

End Behavioral;
