library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MDR is  -- Memory Data Register, No usa señal de clock
    port(
		din  : in  STD_LOGIC_VECTOR (31 downto 0);
		dout : out STD_LOGIC_VECTOR (31 downto 0)
		);
	end MDR;

architecture arch of MDR is
	begin
		dout <= din;
	end arch;
