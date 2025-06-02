library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- use IEEE.STD_LOGIC_ARITH.ALL; -- STD_LOGIC_ARITH adesea este descurajat impreuna cu STD_LOGIC_UNSIGNED datorita conflictelor.
                                -- Daca ai nevoie de functii din STD_LOGIC_ARITH (ex: conv_integer pentru signed/unsigned),
                                -- foloseste pachetul numeric_std.

entity MoneyMemory is
port(
	CLK : in std_logic;
	SEL : in std_logic_vector(2 downto 0);
	DIN : in std_logic_vector(15 downto 0);
	WE : in std_logic; -- NOU: Write Enable (Activare Scriere)
	OUTPUT : out std_logic_vector(15 downto 0)
	);
end MoneyMemory;

architecture A1 of MoneyMemory is

	type T is array(7 downto 0) of std_logic_vector(15 downto 0);
	signal content : T := ("0101011101111001", "1001000000101001", "0110010101110011", "0101011101010001", "0010010101100010", "0001010110000100", "0010000100100011", "0001000001010110");  
																																														
begin
	process(CLK)
		begin
			if(CLK' event and CLK = '1') then
				if(WE = '1') then -- Scrie in memorie doar cand WE este activ
					content(conv_integer(SEL)) <= DIN;
				end if;
			end if;
		end process;
	OUTPUT <= content(conv_integer(SEL));
end A1;