library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.all;

entity digital_clock_top is
  port (
    clk50mhz : in  std_logic;
    clk   : out std_logic);
end digital_clock_top;

architecture Behavioral of digital_clock_top is

  signal prescaler : unsigned(23 downto 0);
  signal clk_2Hz_i : std_logic;
begin

  gen_clk : process (clk50mhz)
  begin  -- process gen_clk
    if rising_edge(clk50mhz) then   -- rising clock edge
      if prescaler = X"225510" then     -- 2 250 000 in hex
        prescaler   <= (others => '0');
        clk_2Hz_i   <= not clk_2Hz_i;
      else
        prescaler <= prescaler + "1";
      end if;
    end if;
  end process gen_clk;

clk <= clk_2Hz_i;

end Behavioral;