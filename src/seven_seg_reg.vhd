library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity seven_seg_reg is
	generic (n: natural := 31);
	port (
		clk       : in  std_logic;
		data      : in std_logic_vector (n downto 0);
		w_en      : in std_logic;
		data_out  : out std_logic_vector (n downto 0)
	);
end entity;

architecture behavior of seven_seg_reg is
signal d_out : std_logic_vector(n downto 0);
begin
   data_out <= d_out;
	
	process (clk) begin
	    if (rising_edge(clk)) then
		    if (w_en = '1') then
			   d_out <= data;
		    end if;
		end if;
	end process;
	
--	process ( w_en, data ) begin
--		if (w_en = '1') then
	--		d_out <= data;
		--end if;
	--end process;
end architecture;
