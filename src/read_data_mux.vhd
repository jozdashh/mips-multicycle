library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity read_data_mux is -- Selecciona datos a leer entre la memoria y el teclado (I/O)
  port (
    mem_data,
    kb_data : in std_logic_vector (31 downto 0);
    sel     : in std_logic;
    out_mux : out std_logic_vector (31 downto 0)
  );
end entity;

architecture arch of read_data_mux is
  signal output_mux : std_logic_vector(31 downto 0);
begin
  out_mux    <= output_mux;
  output_mux <= mem_data when (sel = '0') else kb_data;
end architecture;
