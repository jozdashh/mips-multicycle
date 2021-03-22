library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity controlAlu is
port (
	functions: 			in std_logic_vector(2 downto 0);
	ALUOp: 				in std_logic_vector(1 downto 0);
	alu_operation: 	out std_logic_vector(2 downto 0)
);
end controlAlu;

architecture behavioral of controlAlu is begin
		process ( functions, ALUOp ) begin
		alu_operation <= "010"; -- Por dejar un valor default
		  if    ( ALUop = "00" ) then -- add
		    alu_operation <= "010"; 
			 
			 
		  elsif ( ALUop = "10" ) then -- R operation
		    if    ( functions = "000" ) then
			   alu_operation <= "010"; -- add
				
			 elsif ( functions = "001" ) then
			   alu_operation <= "011"; -- sub
				
			 elsif ( functions = "010" ) then
			   alu_operation <= "100"; -- slt
			 end if;
			 
			 
			elsif ( ALUop = "01" ) then -- Branch instruction (como no hay campo func, toca hacer esto)
			  alu_operation <= "011";
			 
		  end if;
		end process;
end behavioral;

--alu_operation(2) <= ( ALUOp(0) or (ALUOp(1) and functions(1)) );--
--alu_operation(1) <= ( not(ALUOp(1)) or not(functions(2)) );
--alu_operation(0) <= ( ALUOp(1) and functions(0));