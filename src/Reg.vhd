library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Reg is
 generic (n: natural:= 31);
	port (
		data:		in std_logic_vector (n downto 0);
		clk: 		in std_logic;
		q: 		out std_logic_vector (n downto 0)
	);
end entity;

architecture behavior of Reg is
begin
    process (clk) begin
	    if (rising_edge(clk)) then
		    q <= data;
		end if;
	end process;
end architecture;
