library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
	Port(
		A, B        : in STD_LOGIC_VECTOR (31 downto 0);
		alu_control : in STD_LOGIC_VECTOR (2 downto 0);
		zero        : out STD_LOGIC;
		result      : out STD_LOGIC_VECTOR (31 downto 0)
	);
end alu;

architecture behavioral of alu is
	begin
		-- add    : 010
		-- sub    : 011
		-- slt    : 100 => slt rs rt rd => if (rs < rt) rd = 1 else rd = 0

		process ( A, B, alu_control ) begin
		  result <= "00000000000000000000000000000000"; 
		  zero   <= '0';
		  
		  if    (alu_control	= "010") then -- add
		    result <= A + B;
			 

		  elsif (alu_control	= "011") then -- sub
		    result <= A - B; -- El posible output negativo queda en AluOut con los branches
			 
		  elsif (alu_control	= "100") then -- slt
		    if (A < B) then
			   result <= "00000000000000000000000000000001";
			 else
			   result <= "00000000000000000000000000000000";
			 end if;
		  end if;
		  
		  if   (alu_control= "011" and A = B) then -- para branches
		    zero <= '1';
		  else
          zero <= '0';
		  end if;

		end process;
end behavioral;
