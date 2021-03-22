library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Memory is
  port(
    clk:			 in std_logic;
    MemWrite:   in std_logic;
    MemRead:    in std_logic;
    address:    in std_logic_vector(31 downto 0);
    writeData:  in std_logic_vector(31 downto 0);
    readData:   out std_logic_vector(31 downto 0)
  );
end Memory;

architecture behavior of Memory is
	type MEM is array (integer range<>) of std_logic_vector (31 downto 0);
	signal ram : MEM(0 to 63) := (
	0 => "00000100000000110000000000111011", -- addi r0, r3, 59     (r3 <= r0 + 59) (cargar 59 segundos en r3)
	1 => "00000100000111110000000000000000", -- addi r0, r31, 0     (r30 <= r0 + 0) (set 0 para el contador del delay)
	2 => "00000000011000010001100000000001", -- sub r3, r1, r3      (r3 <= r3 - r1) (3 clk's) # Restar segundos
	3 => "00001100000000110110000000000000", -- sw r0, r3, decode3  (2 de la fpga) # Mostrar en 7 segmentos
   4 => "00010100000000000000000000000010", -- jump 2 (pc <= 2) :   Volver a mostrar el dato, hacer el delay, y restarlo
	--
	
  others => (others => '0')
	);

	signal data_out1: std_logic_vector (31 downto 0);

	begin
		readData <= data_out1;
		
		process ( clk, address, writeData, MemWrite, ram )
			begin
				if(rising_edge(clk) and MemWrite='1') then
					ram(to_integer(unsigned(address))) <= writeData;
				end if;
		end process;

		process ( clk, address, MemRead, ram, data_out1 )
			begin
				if(rising_edge(clk) and MemRead='1') then
					data_out1 <= ram(to_integer(unsigned(address)));
				end if;
		end process;
end behavior;
