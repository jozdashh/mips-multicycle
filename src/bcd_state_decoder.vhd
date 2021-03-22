-- CAMBIO DE PLANES: Ahora los estados son un solo caracter
-- HOLA ahora es H (de hi)
-- SELC ahora es C (de choose)
-- OPER ahora es o (de operating)
-- NEXT ahora es n
-- SET0 ahora es 0
-- SET1 ahora es 1
-- 'G' se mantiene como el de prueba

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bcd_state_decoder is
  port (
    bcd_num : in  std_logic_vector(31 downto 0);  -- Numero en bcd
    state   : out std_logic_vector(31 downto 0)   -- Caracter del estado (7 señales, un solo 7-seg)
  );
end entity;

architecture arch of bcd_state_decoder is
  signal output_0 : std_logic_vector (31 downto 0);
begin
  state <= output_0;
  process ( bcd_num ) begin
    case bcd_num is
      when "00000000000000000000000000000000"  => output_0 <= "0000001" & "0000000000000000000000000"; -- dashline ('-')
      when "00000000000000000000000000000001"  => output_0 <= "0110111" & "0000000000000000000000000"; -- H
      when "00000000000000000000000000000010"  => output_0 <= "1001110" & "0000000000000000000000000"; -- C
      when "00000000000000000000000000000011"  => output_0 <= "0011101" & "0000000000000000000000000"; -- o
      when "00000000000000000000000000000100"  => output_0 <= "0010101" & "0000000000000000000000000"; -- n
      when "00000000000000000000000000000101"  => output_0 <= "1111110" & "0000000000000000000000000"; -- 0
      when "00000000000000000000000000000110"  => output_0 <= "0000110" & "0000000000000000000000000"; -- 1
      when others                              => output_0 <= "1011110" & "0000000000000000000000000"; -- G
    end case;
  end process;
end architecture;
