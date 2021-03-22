library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ALU is
	port(
		result: out std_logic_vector(31 downto 0);
		zero: out std_logic
	);
end tb_ALU;

architecture behavioral of tb_ALU is
	component controlAlu port (
		functions: in std_logic_vector(2 downto 0);
		ALUOp: in std_logic_vector(1 downto 0);
		alu_operation: out std_logic_vector(2 downto 0)
	);
	end component;
	
	component alu port(
		A, B: in std_logic_vector (31 downto 0);
		alu_control: in std_logic_vector (2 downto 0);
		zero: out std_logic;
		result: out std_logic_vector (31 downto 0)
	);
	end component;
	
	signal A, B: std_logic_vector(31 downto 0);
	signal functions, alu_operation: std_logic_vector(2 downto 0);
	signal ALUOp: std_logic_vector(1 downto 0);
	
	begin
		CONTROL: controlAlu port map(
			functions => functions,
			ALUOp => ALUOp,
			alu_operation => alu_operation
		);
		
		ALU_INS: alu port map(
			A => A,
			B => B,
			alu_control => alu_operation,
			result => result,
			zero => zero
		);
		
		process
			begin
				B <= std_logic_vector(to_signed(6, 32));
				A <= std_logic_vector(to_signed(5, 32));
				ALUOp <= "10";
				functions <= "000";
				wait for 10 ns;
				functions <= "001";
				wait for 10 ns;
				functions <= "010";
				wait for 10 ns;
				functions <= "011";
				wait;
		end process;
end architecture;
