Library IEEE;
Use IEEE.STD_LOGIC_1164.All;
Use IEEE.NUMERIC_STD.All;

Entity IOExpand Is
	Port(
		HDMI_LRCLK:In STD_LOGIC;
		HDMI_AP:In STD_LOGIC;
		HDMI_MCLK:In STD_LOGIC;
		HDMI_SCLK:In STD_LOGIC;
		HDMI_VS:In STD_LOGIC;
		HDMI_HS:In STD_LOGIC;
		HDMI_DE:In STD_LOGIC;
		HDMI_PCLK:In STD_LOGIC;
		HDMI_Data:In STD_LOGIC_VECTOR(23 DownTo 0);
		
		LAudioOut:Out STD_LOGIC;
		RAudioOut:Out STD_LOGIC;
		
		FPGA_VS:Out STD_LOGIC;
		FPGA_HS:Out STD_LOGIC;
		FPGA_DE:Out STD_LOGIC;
		FPGA_PCLK:Out STD_LOGIC;
		FPGA_Data:Out STD_LOGIC_VECTOR(15 DownTo 0)
	);
End Entity IOExpand;

Architecture Behavioral Of IOExpand Is

	Component I2SReceiver Is
		Port(
			LRCLK:In STD_LOGIC;
			AP:In STD_LOGIC;
			SCLK:In STD_LOGIC;
			
			DataClk:Out STD_LOGIC;
			LData:Out STD_LOGIC_VECTOR(31 DownTo 0);
			RData:Out STD_LOGIC_VECTOR(31 DownTo 0)
		);
	End Component I2SReceiver;
	
	component dac_dsm2 is
		generic (
			nbits : integer := 16);
		port (
			din   : in  signed((nbits-1) downto 0);
			dout  : out std_logic;
			clk   : in  std_logic;
			n_rst : in  std_logic);
	end component dac_dsm2;

	Signal R:UNSIGNED(9 DownTo 0);
	Signal G:UNSIGNED(9 DownTo 0);
	Signal B:UNSIGNED(9 DownTo 0);
	
	Signal AudioModulatorClock:STD_LOGIC;
	
	Signal AudioL:STD_LOGIC_VECTOR(31 DownTo 0);
	Signal AudioR:STD_LOGIC_VECTOR(31 DownTo 0);
Begin

	I2SRecv:I2SReceiver Port Map(
		LRCLK=>HDMI_LRCLK,
		AP=>HDMI_AP,
		SCLK=>HDMI_SCLK,
			
		DataClk=>Open,
		LData=>AudioL,
		RData=>AudioR
	);

	LModulator:dac_dsm2
		Generic Map(
			nbits=>32
		)
		Port Map(
			din=>SIGNED(AudioL),
			dout=>LAudioOut,
			clk=>AudioModulatorClock,
			n_rst=>'1'
		);

	RModulator:dac_dsm2
		Generic Map(
			nbits=>32
		)
		Port Map(
			din=>SIGNED(AudioR),
			dout=>RAudioOut,
			clk=>AudioModulatorClock,
			n_rst=>'1'
		);

	AudioModulatorClock<=HDMI_SCLK;
	
	B<=UNSIGNED("00" & HDMI_Data(7 DownTo 0));
	G<=UNSIGNED("00" & HDMI_Data(15 DownTo 8));
	R<=UNSIGNED("00" & HDMI_Data(23 DownTo 16));
	
	FPGA_VS<=HDMI_VS;
	FPGA_HS<=HDMI_HS;
	FPGA_DE<=HDMI_DE;
	FPGA_PCLK<=HDMI_PCLK;
	FPGA_Data(9 DownTo 0)<=STD_LOGIC_VECTOR(B+G+R);
	FPGA_Data(15 DownTo  10)<=(Others=>'0');
	
End Behavioral;
