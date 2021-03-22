library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity mux_4_to_1 is
	generic (n: natural:= 31);
	port (
		A, B, C: 	in std_logic_vector(n downto 0);
		S: 						in std_logic_vector(1 downto 0);
		Z: 						out std_logic_vector(n downto 0)
	);
end mux_4_to_1;

architecture arch of mux_4_to_1 is
  begin
    Z <= 	A when (S = "00") else
        	B when (S = "01") else C;
end arch;
