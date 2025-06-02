library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Modulo7Counter is
port(
	UP : in std_logic;
	RESET : in std_logic;
	TC : out std_logic; --terminal count
	Q : out std_logic_vector(2 downto 0) -- Changed to 3 bits for modulo 7 (0-6)
	);
end Modulo7Counter;

architecture M of Modulo7Counter is

signal tmp : std_logic_vector(2 downto 0); -- Changed to 3 bits

begin
	process(UP, RESET)
		begin
			if(RESET = '1') then
				tmp <= "000"; -- Reset value
			elsif(UP' event and UP = '1') then
				if tmp = "110" then -- Check for terminal count (decimal 6)
					tmp <= "000"; -- Reset to 0
				else
					tmp <= tmp + 1;	-- Increment
				end if;
			end if;
		end process;
	Q <= tmp;
	TC <= '1' when tmp = "110" else -- TC is active when counter reaches "110" (decimal 6)
		  '0';
end M;