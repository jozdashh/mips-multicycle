library ieee;
use ieee.std_logic_1164.all;

entity mux is
	generic (n: natural:= 31);
	port(
		a, b: in std_logic_vector (n downto 0);
		s: 		in std_logic;
		c: 		out std_logic_vector(n downto 0)
	);
end mux;

architecture beh of mux is
	begin
		c <= a when (s = '0') else b;
end beh;
