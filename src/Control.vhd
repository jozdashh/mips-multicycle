library ieee;
use ieee.std_logic_1164.all;

entity Control is
	port(
		opcode: 		in std_logic_vector (5 downto 0);
		clk, reset: in std_logic;

		Branch,
		PCWrite,
		IorD,
		MemRead,
		MemWrite,
		MemtoReg,
		IRWrite,
		RegWrite,
		RegDst: 	out std_logic;

		PCSrc,
		ALUOp,
		ALUSrcA,
		ALUSrcB: 	out std_logic_vector (1 downto 0)
	);
end Control;

-- (OPCODES)
-- TIPO R	: 000000
--				(campo function)
-- 			ADD		: 000
-- 			SUB		: 001
--          SLT      : 010
--
-- ADDI 	   : 000001
-- LW 		: 000010
-- SW 		: 000011
--
-- BEQ		: 000100
-- J			: 000101

architecture behavior of Control is
	-- Los estados estan numerados haciendo un recorrido por niveles del grafo de estados
	signal state:      std_logic_vector (3 downto 0);
	signal next_state: std_logic_vector (3 downto 0);
	begin
		process ( clk, reset )
			begin
				if (reset = '1') then
						state <= "0001";
				elsif (falling_edge(clk)) then --(clk'event and clk='1') then
					state <= next_state;
				end if;
		end process;

	process ( opcode, state )
		begin
		if ( state = "0001" ) then -- Fetch
				next_state 	<= "0010";
				--
				IorD 			<= '0';
				MemRead 	<= '1';
				ALUSrcA 	<= "00";
				ALUSrcB 	<= "01";
				ALUOp			<= "00";
				PCSrc 		<= "00";
				IRWrite 	<= '1';
				PCWrite 	<= '1';
				--
				MemWrite 	<= '0';
				MemtoReg 	<= '0';
				Branch 		<= '0';
				RegWrite 	<= '0';
				RegDst 		<= 'X';

		  elsif ( state = "0010" ) then -- Decode
				if ( opcode = "000000" ) then
					next_state <= "0100"; -- tipo R

				elsif ( opcode =  "000001" or opcode =  "000010" or opcode = "000011" ) then
					next_state <= "0011"; -- addi | lw | sw ) then

				elsif ( opcode = "000100" ) then
					next_state <= "0101"; -- beq
				elsif ( opcode = "000101" ) then
					next_state <= "0110"; -- jump
				else
					next_state <= "0001"; -- Inicio
				end if;
				--
				if (opcode = "000100") then
					ALUSrcA <= "10";
				else
					ALUSrcA 	<= "00";
				end if;

				ALUSrcB 	<= "11";
				ALUOp 		<= "00";
				--
				PCSrc 		<= "00";
				IRWrite 	<= '0';
				PCWrite 	<= '0';
				MemWrite 	<= '0';
				MemRead 	<= '0';
				RegWrite 	<= '0';
				Branch 		<= '0';
				RegDst	 	<= 'X';
				IorD 			<= 'X';
				MemtoReg 	<= 'X';

		elsif ( state = "0011" ) then -- MemAddr
				ALUSrcA 	<= "01";
				ALUSrcB 	<= "10";
				ALUOp    <= "00";
				--
				if ( opcode = "000010" ) then
					next_state <= "0111"; -- lw

				elsif ( opcode = "000011" ) then
					next_state <= "1000"; -- sw

				elsif ( opcode = "000001" ) then
					next_state <= "1001"; -- addi

				else
					next_state <= "0001"; -- Inicio
				end if;
				--
				PCSrc 		<= "00";
				IRWrite 	<= '0';
				PCWrite 	<= '0';
				MemWrite 	<= '0';
				MemRead 	<= '0';
				RegWrite 	<= '0';
				Branch 		<= '0';
				MemtoReg 	<= '0';
				RegDst 		<= 'X';
				IorD 			<= 'X';

		elsif ( state = "0100" ) then -- Execute
				next_state	<= "1010";
				--
				ALUSrcA 	   <= "01";
				ALUSrcB 	   <= "00";
				ALUOp 		<= "10";
				--
				PCSrc 		<= "00";
				IRWrite 	   <= '0';
				PCWrite 	   <= '0';
				MemWrite 	<= '0';
				MemRead 	   <= '0';
				RegWrite 	<= '0';
				Branch 		<= '0';
				RegDst 		<= 'X';
				IorD 			<= 'X';
				MemtoReg 	<= 'X';

		elsif ( state = "0101" ) then -- Branch
				next_state  <= "0001";
				--
				ALUSrcA 	  <= "01";
				ALUSrcB 	  <= "00";
				ALUOp      <= "01";
				PCSrc      <= "01";
				Branch     <= '1';
				PCWrite    <= '0';
				--
				IRWrite    <= '0';
				MemWrite   <= '0';
				MemRead    <= '0';
				RegWrite 	<= '0';
				RegDst 		<= 'X';
				IorD 			<= 'X';
				MemtoReg 	<= 'X';

		elsif ( state = "0110" ) then -- Jump
				next_state <= "0001";
				--
				PCSrc 		<= "10";
				ALUOp 		<= "00";
				PCWrite 	<= '1';
				--
				ALUSrcA 	<= "01";
				ALUSrcB 	<= "00";
				IRWrite 	<= '0';
				MemWrite 	<= '0';
				MemRead 	<= '0';
				RegWrite 	<= '0';
				RegDst 		<= 'X';
				IorD 			<= 'X';
				MemtoReg 	<= 'X';
				Branch 		<= 'X';

		elsif ( state = "0111" ) then -- MemRead
				next_state 	<= "1011";
				--
				IorD 			<= '1';
				MemRead 	<= '1';
				--
				ALUSrcA 	<= "01";
				ALUSrcB 	<= "00";
				ALUOp 		<= "00";
				IRWrite 	<= '0';
				MemWrite 	<= '0';
				RegWrite 	<= '0';
				PCWrite 	<= '0';
				RegDst 		<= 'X';
				MemtoReg 	<= 'X';
				Branch 		<= 'X';
				PCSrc 		<= "00";

		elsif ( state = "1000" ) then -- MemWrite
				next_state 	<= "0001";
				--
				IorD 			<= '1';
				MemWrite 	<= '1';
				--
				ALUSrcA 	<= "01";
				ALUSrcB 	<= "00";
				ALUOp 		<= "00";
				PCSrc 		<= "00";
				IRWrite 	<= '0';
				MemRead 	<= '0';
				RegWrite 	<= '0';
				PCWrite 	<= '0';
				RegDst 		<= 'X';
				MemtoReg 	<= 'X';
				Branch 		<= 'X';

		elsif ( state = "1001" ) then -- ADDI Writeback (nuevo estado)
				next_state 	<= "0001";
				--
				RegDst 		<= '0';
				MemtoReg 	<= '0';
				RegWrite 	<= '1';
				--
				ALUSrcA 	<= "01";
				ALUSrcB 	<= "00";
				ALUOp 		<= "00";
				PCSrc 		<= "00";
				IRWrite 	<= '0';
				MemRead 	<= '0';
				PCWrite 	<= '0';
				IorD 			<= '0';
				MemWrite 	<= '0';
				Branch 		<= '0';

		elsif ( state = "1010" ) then -- ALU Writeback
				next_state 	<= "0001";
				--
				RegDst 		<= '1';
				MemtoReg 	<= '0';
				RegWrite 	<= '1';
				--
				ALUSrcA 	<= "01";
				ALUSrcB 	<= "00";
				ALUOp 		<= "00";
				PCSrc 		<= "00";
				IRWrite 	<= '0';
				MemRead 	<= '0';
				PCWrite 	<= '0';
				IorD 			<= '0';
				MemWrite 	<= '0';
				Branch 		<= 'X';

		else -- elseif ( state = "1011" ) then -- Mem Writeback (s11)
				next_state 	<= "0001";
				--
				RegDst 		<= '0';
				MemtoReg 	<= '1';
				RegWrite 	<= '1';
				--
				ALUSrcA 	<= "01";
				ALUSrcB 	<= "00";
				ALUOp 		<= "00";
				PCSrc 		<= "00";
				IRWrite 	<= '0';
				MemRead 	<= '0';
				PCWrite 	<= '0';
				IorD 			<= '0';
				MemWrite 	<= '0';
				Branch 		<= 'X';
	end if;
	end process;
end behavior;
