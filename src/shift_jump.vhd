library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_jump is
	port (
		a: in std_logic_vector(11 downto 0);
		b: out std_logic_vector(13 downto 0) -- Ya se tiene en cuenta la concatenación con el PC.
	);
end entity;

architecture beh of shift_jump is
	signal temp: std_logic_vector(13 downto 0);

	begin
	temp <= std_logic_vector(resize(unsigned(a), 14));
	b <= std_logic_vector(shift_left(signed(temp), 1)); -- Multiplicamos por 2
end beh;
