library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sign_extend is
	port (
		a: in std_logic_vector(15 downto 0);
		b: out std_logic_vector(31 downto 0)
	);
end sign_extend;

architecture behavior of sign_extend is
	begin
	b <= std_logic_vector(resize(signed(a), b'length));
end behavior;
