library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity multiciclo is
	port(
		CLK50, RESET          : in std_logic;
		keyboard_input      : in std_logic_vector (31 downto 0);
		
		decode_0, decode_1,
		decode_2, decode_3,
		decode_4, decode_5,
		decode_buzz         : out std_logic_vector(31 downto 0)		
	);
end multiciclo;

architecture behavior of multiciclo is
	signal pc_current    : std_logic_vector (31 downto 0) := "00000000000000000000000000000000";
	signal alu_out,
	address, mdr, data   : std_logic_vector (31 downto 0);
	signal pc_next       : std_logic_vector (31 downto 0);
	signal after_address : std_logic_vector (25 downto 0);
	signal RS, RD, RT    : std_logic_vector(4 downto 0);
	signal funct         : std_logic_vector (2 downto 0);
	signal imm           : std_logic_vector(15 downto 0);
	
	-- Decode
	signal writeRegister         : std_logic_vector (4 downto 0);
	
	signal Branch, PCWrite, IorD, 
	MemRead, MemWrite, MemtoReg, 
	IRWrite, RegWrite, 
	RegDst, CLK                  : std_logic;
	
	signal ALUSrcA, PCSrc, ALUOp, ALUSrcB : std_logic_vector (1 downto 0);
	signal opcode                : std_logic_vector (5 downto 0);
	--signal next_state            : std_logic_vector (3 downto 0);

	signal imm_extend, address_jump: std_logic_vector (31 downto 0);

	-- Register, ALU
	signal registerWriteData : std_logic_vector(31 downto 0);
	signal data_A, data_B, 
	A, A1, B, B1, result     : std_logic_vector(31 downto 0);
	signal zero              : std_logic;
	signal alu_operation     : std_logic_vector(2 downto 0);
	-- Data
	--signal jump_signal : std_logic_vector(13 downto 0);
	
	-- Address Decoder y I/O
	signal re_kb, we_MEM, re_MEM, rd_sel, we_0, we_1, we_2, we_3,
	we_4, we_5, w_en_buzz        : std_logic;
	signal kb_output, data_mdr   : std_logic_vector(31 downto 0);
	signal bcd_0, bcd_1, bcd_2, 
	bcd_3, bcd_4, bcd_state_5    : std_logic_vector(31 downto 0);

	component digital_clock_top port (
		clk50mhz: 	in STD_LOGIC;
		clk:		out STD_LOGIC
	);
	end component;
	
	component address_decoder port(
		address                 : in std_logic_vector (31 downto 0);
		mem_write, mem_read     : in std_logic;
		w_en_reg_0, w_en_reg_1, 
		w_en_reg_2, w_en_reg_3, 
		w_en_reg_4, w_en_reg_5,
		r_en_mem, r_en_kb, 
		w_en_mem, w_en_buzz, rdsel: out std_logic
   );
	end component;
	
	component seven_seg_reg is
		generic (n: natural := 31);
		port (
		   clk      : in std_logic;
			data     : in std_logic_vector (n downto 0);
			w_en     : in std_logic;
			data_out : out std_logic_vector (n downto 0)
		);
	end component;
	
	component keyboard_register port(
	   clk       : in  std_logic;
		kb_read   : in  std_logic;
		kb_input  : in  std_logic_vector(31 downto 0);
		kb_output : out std_logic_vector(31 downto 0)
	);
	end component;
	
	component bcd_state_decoder port (
		bcd_num : in std_logic_vector(31 downto 0);
		state   : out std_logic_vector(31 downto 0)
	);
	end component;
	
	component bcd_decoder port (
		bcd_num       : in  std_logic_vector(31  downto 0);
		seven_seg_num : out std_logic_vector(31 downto 0)
	);
	end component;
	
	component Control port(
		opcode              : in std_logic_vector (5 downto 0);
		clk, reset          : in std_logic;
		
		Branch, PCWrite, 
		IorD, MemRead, 
		MemWrite, MemtoReg, 
		IRWrite, 
		RegWrite, RegDst    : out std_logic;
		
		ALUSrcA, PCSrc, ALUOp, 
		ALUSrcB             : out std_logic_vector (1 downto 0)
	);
	end component;

	component RegisterFile port (
		clk					: in std_logic;
		registerWrite     : in std_logic;
		registerRead1     : in std_logic_vector(4 downto 0);
		registerRead2     : in std_logic_vector(4 downto 0);
		writeRegister     : in std_logic_vector(4 downto 0);
		registerWriteData : in std_logic_vector(31 downto 0);
		registerReadData1 : out std_logic_vector(31 downto 0);
		registerReadData2 : out std_logic_vector(31 downto 0)
	);
	end component;

	component sign_extend is
	port (
		a : in std_logic_vector(15 downto 0);
		b : out std_logic_vector(31 downto 0)
	);
	end component;


	component shift is
	port (
		a : in std_logic_vector(31 downto 0);
		b : out std_logic_vector(31 downto 0)
	);
	end component;


	component sign_extend_jump is
	port(
		a : in std_logic_vector(25 downto 0);
		b : out std_logic_vector(31 downto 0)
	);
	end component;

	component controlAlu  port (
		functions     : in std_logic_vector(2 downto 0);
		ALUOp         : in std_logic_vector(1 downto 0);
		alu_operation : out std_logic_vector(2 downto 0)
	);
	end component;

	component alu port (
		A, B        : in std_logic_vector (31 downto 0);
		alu_control : in std_logic_vector (2 downto 0);
		zero        : out std_logic;
		result      : out std_logic_vector (31 downto 0)
	);
	end component;

	component Memory port (
		clk		 : in std_logic;
		MemWrite  : in std_logic;
		MemRead   : in std_logic;
		address   : in std_logic_vector(31 downto 0);
		writeData : in std_logic_vector(31 downto 0);
		readData  : out std_logic_vector(31 downto 0)
	);
	end component;

	component Reg
		generic (n: natural := 31);
		port (
			data : in std_logic_vector(n downto 0);
			clk  : in std_logic;
			q    : out std_logic_vector(n downto 0)
		);
	end component;

	component Instruction_Register
		port (
			IRWrite      : in  std_logic;
			instrucInput : in  std_logic_vector(31 downto 0);
			opCode       : out std_logic_vector(5 downto 0);
			regRs        : out std_logic_vector(4 downto 0);
			regRt        : out std_logic_vector(4 downto 0);
			regRd        : out std_logic_vector(4 downto 0);
			imm          : out std_logic_vector(15 downto 0);
			jumpAddr     : out std_logic_vector(25 downto 0);
			funcCode     : out std_logic_vector(2 downto 0)
      );
	end component;

	component mux
		generic (n : natural:= 31);
		port (
			a, b : in std_logic_vector (n downto 0);
			s    : std_logic;
			c    : out std_logic_vector(n downto 0)
		);
	end component;

	component mux_4_to_1
		generic (n : natural := 31);
		port(
			A, B, C : in std_logic_vector (n downto 0);
			S       : in std_logic_vector(1 downto 0);
			Z       : out std_logic_vector (n downto 0)
		);
	end component;

	begin
	
	CLOCK: digital_clock_top port map(
		clk50mhz => 	CLK50,
		clk => CLK
	);

	process(CLK, RESET)
		begin
			if(RESET = '1') then
				pc_current <= "00000000000000000000000000000000";
				
			elsif(CLK'event and CLK='1') then
				if ( (zero='1' and Branch='1') or PCWrite='1') then
					pc_current <= pc_next;
				end if;
			end if;
	end process;

	MUXPC: mux generic map(31) port map(
		a => pc_current,
		b => alu_out,
		c => address,
		s => IorD
	);

	DECODER: address_decoder port map (
		address   => alu_out,
		mem_write => MemWrite,
		mem_read  => MemRead,

		w_en_reg_0 => we_0,
		w_en_reg_1 => we_1,
		w_en_reg_2 => we_2,
		w_en_reg_3 => we_3,

		w_en_reg_4 => we_4,
		w_en_reg_5 => we_5,
		w_en_buzz => w_en_buzz,

		r_en_mem => re_MEM,
		r_en_kb  => re_kb,
		w_en_mem => we_MEM,
		rdsel    => rd_sel
	);
	
	REG0: seven_seg_reg generic map(31) port map(
	   clk      => CLK,
		data     => B,
		w_en     => we_0,
		data_out => bcd_0
	);
	
	REG1: seven_seg_reg generic map(31) port map(
	   clk      => CLK,
		data     => B,
		w_en     => we_1,
		data_out => bcd_1
	);
	
	REG2: seven_seg_reg generic map(31) port map(
		clk      => CLK,
		data     => B,
		w_en     => we_2,
		data_out => bcd_2
	);
	
	REG3: seven_seg_reg generic map(31) port map(
		clk      => CLK,
		data     => B,
		w_en     => we_3,
		data_out => bcd_3
	);
	
	REG4: seven_seg_reg generic map(31) port map(
		clk      => CLK,
		data     => B,
		w_en     => we_4,
		data_out => bcd_4
	);
	
	REG5: seven_seg_reg generic map(31) port map(
		clk      => CLK,
		data     => B,
		w_en     => we_5,
		data_out => bcd_state_5
	);
	
	REGBUZZ: seven_seg_reg generic map(31) port map(
		clk      => CLK,
		data     => B,
		w_en     => w_en_buzz,
		data_out => decode_buzz
	);
	
	BCD0: bcd_decoder port map (
		bcd_num       => bcd_0,
		seven_seg_num => decode_0
	);
	
	BCD1: bcd_decoder port map (
		bcd_num       => bcd_1,
		seven_seg_num => decode_1
	);
	
	BCD2: bcd_decoder port map (
		bcd_num       => bcd_2,
		seven_seg_num => decode_2
	);
	
	BCD3: bcd_decoder port map (
		bcd_num       => bcd_3,
		seven_seg_num => decode_3
	);
	
	BCD4: bcd_decoder port map (
		bcd_num       => bcd_4,
		seven_seg_num => decode_4
	);
	
	BCD5: bcd_state_decoder port map (
		bcd_num => bcd_state_5,
		state   => decode_5
	);

	KEYBOARD: keyboard_register port map(
		clk       => CLK,
		kb_read   => re_kb,
		kb_input  => keyboard_input,
		kb_output => kb_output
	);
	
	RAM:  Memory port map (
		clk		 => CLK,
		MemWrite  => we_MEM,
		MemRead   => re_MEM,
		address   => address,
		writeData => B,
		readData  => data
	);
	
	-- Mux
	MUXMDR: mux generic map(31) port map(
		a => data,
		b => kb_output,
		s => rd_sel,
		c => data_mdr
	);

	RegMemData: Reg port map(
		clk  => CLK,
		data => data_mdr,
		q    => mdr
	);

	IR: Instruction_Register port map(
		IRWrite      => IRWrite,
		instrucInput => data,
		opCode       => opcode,
		regRs        => RS,
		regRt        => RT,
		regRd        => RD,
		imm          => imm,
		jumpAddr     => after_address,
		funcCode     => funct
	);

	Unit_Control: Control port map(
		opcode   => opcode,
		clk      => CLK,
		reset    => RESET,
		Branch   => Branch,
		PCWrite  => PCWrite,
		IorD     => IorD,
		MemRead  => MemRead,
		MemWrite => MemWrite,
		MemtoReg => MemtoReg,
		IRWrite  => IRWrite,
		ALUSrcA  => ALUSrcA,
		RegWrite => RegWrite,
		RegDst   => RegDst,
		PCSrc    => PCSrc,
		ALUOp    => ALUOp,
		ALUSrcB  => ALUSrcB
	);

	MUXREG: mux generic map(4) port map(
		a => RT,
		b => RD,
		s => RegDst,
		c => writeRegister
	);

	MUXREGDATA: mux generic map(31) port map(
		a => alu_out,
		b => mdr,
		s => MemToReg,
		c => registerWriteData
	);

	Registers: RegisterFile port map(
		clk 					=> CLK,
		registerWrite     => RegWrite,
		registerRead1     => RS,
		registerRead2     => RT,
		writeRegister     => writeRegister,
		registerWriteData => registerWriteData,
		registerReadData1 => data_A,
		registerReadData2 => data_B
	);

	REGA: Reg port map(
		clk  => CLK,
		data => data_A,
		q    => A
	);

	REGB: Reg port map(
		clk  => CLK,
		data => data_B,
		q    => B
	);

	-- Sign extend
	EXTEND1: sign_extend port map(
		a => imm,
		b => imm_extend
	);

	MUXALUA: mux_4_to_1 generic map(31) port map(
		A => pc_current,
		B => A,
		C => "00000000000000000000000000000000",
		S => ALUSrcA,
		Z => A1 -- ALU IN
	);

	MUXALUB: mux_4_to_1 generic map(31) port map(
		A => B,
		B => "00000000000000000000000000000001",
		C => imm_extend,
		S => ALUSrcB,
		Z => B1 -- ALU IN
	);

	-- ALU
	ALU_INS: alu port map(
		A           => A1,
		B           => B1,
		alu_control => alu_operation,
		zero        => zero,
		result      => result
	);

	REGALUOUT: Reg port map(
		clk  => CLK,
		data => result,
		q    => alu_out
	);

	ALUCONTROL: controlAlu port map(
		functions     => funct,
		ALUOp         => ALUOp,
		alu_operation => alu_operation
	);

	EXTEND2: sign_extend_jump port map(
		a => after_address,
		b => address_jump
	);

	MUXNEXTPC: mux_4_to_1 generic map(31) port map(
		A => result,
		B => alu_out,
		C => address_jump,
		S => PCSrc,
		Z => pc_next
	);

end behavior;
