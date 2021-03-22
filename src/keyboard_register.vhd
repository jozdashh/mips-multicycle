library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity keyboard_register is
  port(
    clk       : in  std_logic;
    kb_read   : in  std_logic;
    kb_input  : in  std_logic_vector(31 downto 0);
    kb_output : out std_logic_vector(31 downto 0)
  );
end keyboard_register;

architecture arch of keyboard_register is
  signal kb_out_0 : std_logic_vector(31 downto 0);
  begin
  kb_output <= kb_out_0;
	process (clk) begin
	    if (rising_edge(clk)) then
		    --if (kb_read = '1') then
            kb_out_0 <= kb_input;
          --end if;
		end if;
	end process;
end architecture;
