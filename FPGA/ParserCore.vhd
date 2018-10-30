Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;
Use WORK.ScanParam.All;

Entity ParserCore Is
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
End Entity ParserCore;

Architecture Behavioral Of ParserCore Is	
	Signal ScanReset:STD_LOGIC;
	Signal ResetShiftReg:STD_LOGIC_VECTOR(7 DownTo 0);
	
	Signal HoldPipeline:STD_LOGIC;
	Signal BlankHold:STD_LOGIC;
	Signal ScanEnd:STD_LOGIC;
	
	Signal XCounter_Stage1:INTEGER Range 0 To ScanWidth;
	Signal YCounter_Stage1:INTEGER Range 0 To ScanHeight+1;
	Signal ScanDirection_Stage1:STD_LOGIC;
	Signal LineEnd_Stage1:STD_LOGIC;
	
	Signal XCounter_Stage2:INTEGER Range 0 To ScanWidth;
	Signal YCounter_Stage2:INTEGER Range 0 To ScanHeight+1;
	Signal BlankPixel_Stage2:STD_LOGIC;
	
	Signal MemCounter_Stage3:UNSIGNED(MemAddrBits-1 DownTo 0);
	Signal XCounter_Stage3:INTEGER Range 0 To ScanWidth;
	Signal YCounter_Stage3:INTEGER Range 0 To ScanHeight+1;
	Signal BlankPixel_Stage3:STD_LOGIC;
	Signal FirstPixel_Stage3:STD_LOGIC;
	Signal PixelTime_Stage3:UNSIGNED(ScanPixelBits-1 DownTo 0);
	
	Signal XCounter_Stage4:INTEGER Range 0 To ScanWidth;
	Signal YCounter_Stage4:INTEGER Range 0 To ScanHeight+1;
	Signal BlankPixel_Stage4:STD_LOGIC;
	Signal SkipPixel_Stage4:STD_LOGIC;
	Signal PixelTime_Stage4:UNSIGNED(ScanPixelBits-1 DownTo 0);
	Signal BlankTime_Stage4:UNSIGNED(ScanPixelBits-1 DownTo 0);
	Signal ScanTime_Stage4:UNSIGNED(31 DownTo 0);
	
Begin
	
	ScanReset<=Reset Or ScanEnd;
	
	RstGen:Process(Clk)
	Begin
		If rising_edge(Clk) Then
			ResetShiftReg<=ResetShiftReg(6 DownTo 0) & ScanReset;
		End If;
	End Process;
	
	S1_YGen:Process(Clk)
	Begin
		If rising_edge(Clk) Then
			If ResetShiftReg(1)='1' Then
				LineEnd_Stage1<='0';
				ScanDirection_Stage1<='1';
				YCounter_Stage1<=0;
			Else
				If HoldPipeline='0' Then
					If ScanDirection_Stage1='0' Then
						If YCounter_Stage1=1 Then
							LineEnd_Stage1<='1';
							ScanDirection_Stage1<='1';
						Else
							LineEnd_Stage1<='0';
						End If;
						YCounter_Stage1<=YCounter_Stage1-1;
					Else
						If YCounter_Stage1=ScanHeight Then
							LineEnd_Stage1<='1';
							ScanDirection_Stage1<='0';
						Else
							LineEnd_Stage1<='0';
						End If;
						YCounter_Stage1<=YCounter_Stage1+1;
					End If;
				End If;
			End If;
		End If;
	End Process;
	
	S1_XGen:Process(Clk)
	Begin
		If rising_edge(Clk) Then
			If ResetShiftReg(1)='1' Then
				XCounter_Stage1<=0;
				ScanEnd<='0';
			Else
				If HoldPipeline='0' Then
					If LineEnd_Stage1='1' Then
						If XCounter_Stage1=ScanWidth-1 Then
							ScanEnd<='1';
						End If;
						XCounter_Stage1<=XCounter_Stage1+1;
					End If;
				End If;
			End If;
		End If;
	End Process;
	
	S2_BlankGen:Process(Clk)
	Begin
		If rising_edge(Clk) Then
			If ResetShiftReg(2)='1' Then
				XCounter_Stage2<=0;
				YCounter_Stage2<=0;
				BlankPixel_Stage2<='1';
			Else
				If HoldPipeline='0' Then
					XCounter_Stage2<=XCounter_Stage1;
					YCounter_Stage2<=YCounter_Stage1;
					If (YCounter_Stage1=ScanHeight+1) Or (YCounter_Stage1=0) Then
						BlankPixel_Stage2<='1';
					Else
						BlankPixel_Stage2<='0';
					End If;
				End If;
			End If;
		End If;
	End Process;

	S3_MemCounter:Process(Clk)
	Begin
		If rising_edge(Clk) Then
			If ResetShiftReg(3)='1' Then
				MemCounter_Stage3<=(Others=>'0');
			Else
				If HoldPipeline='0' Then
					If BlankPixel_Stage2='0' Then
						MemCounter_Stage3<=MemCounter_Stage3+1;
					End If;
				End If;
			End If;
		End If;
	End Process;
	
	S3_MemInterfaceAndDelay:Process(MemCounter_Stage3,HoldPipeline,PixelData,Clk)
	Begin
		PixelAddr<=STD_LOGIC_VECTOR(MemCounter_Stage3);
		PixelRd<=Not HoldPipeline;
		PixelTime_Stage3<=(Others=>'0');
		PixelTime_Stage3(PixelBits-1  DownTo 0)<=UNSIGNED(PixelData);
		If rising_edge(Clk) Then
			If ResetShiftReg(3)='1' Then
				XCounter_Stage3<=0;
				YCounter_Stage3<=0;
				BlankPixel_Stage3<='1';
				FirstPixel_Stage3<='0';
			Else
				If HoldPipeline='0' Then
					XCounter_Stage3<=XCounter_Stage2;
					YCounter_Stage3<=YCounter_Stage2;
					BlankPixel_Stage3<=BlankPixel_Stage2;
					If (XCounter_Stage2=0) And (YCounter_Stage2=0) Then
						FirstPixel_Stage3<='1';
					Else
						FirstPixel_Stage3<='0';
					End If;
				End If;
			End If;
		End If;
	End Process;
	
	S4_PixelJudge:Process(FirstPixel_Stage3,BlankTime_Stage4,PixelTime_Stage3,XCounter_Stage3,YCounter_Stage3,BlankPixel_Stage3)
		Variable NewPixelTime:UNSIGNED(ScanPixelBits-1 DownTo 0);
	Begin
		If FirstPixel_Stage3='1' Then
			NewPixelTime:=(Others=>'0');
			NewPixelTime(3):='1';
			SkipPixel_Stage4<='0';
		Else
			If BlankPixel_Stage3='1' Then
				NewPixelTime:=BlankTime_Stage4;
			Else
				NewPixelTime:=PixelTime_Stage3;
			End If;
			If NewPixelTime=0 Then
				SkipPixel_Stage4<='1';
			Else
				SkipPixel_Stage4<='0';
			End If;
		End If;
		PixelTime_Stage4<=NewPixelTime;
		XCounter_Stage4<=XCounter_Stage3;
		YCounter_Stage4<=YCounter_Stage3;
		BlankPixel_Stage4<=BlankPixel_Stage3;
	End Process;
	
	S4_BlankTimeCalc:Process(ScanTime_Stage4,BlankPixel_Stage4)
		Variable SubtractVal:UNSIGNED(31 DownTo 0);
	Begin
		If ScanTime_Stage4<LineMinScanTime Then
			If ScanTime_Stage4<LineMinScanTime-8000 Then
				BlankTime_Stage4<=To_UNSIGNED(8000,ScanPixelBits);
			Else
				SubtractVal:=LineMinScanTime-ScanTime_Stage4;
				BlankTime_Stage4<=SubtractVal(ScanPixelBits-1 DownTo 0);
			End If;
			BlankHold<=BlankPixel_Stage4;
		Else
			BlankTime_Stage4<=(Others=>'0');
			BlankHold<='0';
		End If;
	End Process;
	
	S4_BlankCount:Process(Clk)
		Variable LastBlankState:STD_LOGIC;
	Begin
		If rising_edge(Clk) Then
			If ResetShiftReg(4)='1' Then
				ScanTime_Stage4<=(Others=>'0');
			Else
				If BufferFull='0' Then
					If ScanTime_Stage4<LineMinScanTime Then
						ScanTime_Stage4<=ScanTime_Stage4+PixelTime_Stage4;
					Else
						If (LastBlankState='1') And (BlankPixel_Stage4='0') Then
							ScanTime_Stage4<=(Others=>'0');
							ScanTime_Stage4(ScanPixelBits-1 DownTo 0)<=PixelTime_Stage4;
						End If;
					End If;
					LastBlankState:=BlankPixel_Stage4;
				End If;
			End If;
		End If;
	End Process;
	
	PixelOutput:Process(PixelTime_Stage4,XCounter_Stage4,YCounter_Stage4,BufferFull,SkipPixel_Stage4,BlankHold)
	Begin
		If XCounter_Stage4=0 And YCounter_Stage4=0 Then
			PixelTrig<='1';
		Else
			PixelTrig<='0';
		End If;
		PixelTime<=STD_LOGIC_VECTOR(PixelTime_Stage4);
		PixelX<="0010" & STD_LOGIC_VECTOR(To_UNSIGNED(XCounter_Stage4,9)) & "000";
		PixelY<="0010" & STD_LOGIC_VECTOR(To_UNSIGNED(YCounter_Stage4,9)) & "000";
		PixelWriteWr<=(Not BufferFull) And (Not SkipPixel_Stage4);
		HoldPipeline<=BufferFull Or BlankHold;
	End Process;
	
End Behavioral;
