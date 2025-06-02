library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BlocDepunereSold is
port(
	DepunereSold : in std_logic;
	SumAvailable : in std_logic_vector(15 downto 0);
	UP : in std_logic;
	DISPLAY : out std_logic_vector(15 downto 0);
	SoldOK : out std_logic
	);
end BlocDepunereSold;

architecture D of BlocDepunereSold is

	signal a : std_logic;
	signal sel : std_logic_vector(1 downto 0);
	signal choice : std_logic_vector(15 downto 0);
	
	component Modulo7Counter is
port(
	UP : in std_logic;
	RESET : in std_logic;
	TC : out std_logic; --terminal count
	Q : out std_logic_vector(2 downto 0) -- Changed to 3 bits for modulo 7 (0-6)
	);
end component;
	
	component SumComparator is
	port(
		Available : in std_logic_vector(15 downto 0);
		Needed : in std_logic_vector(15 downto 0);
		SoldOK : out std_logic
		);
	end component;

begin
	DISPLAY <= choice;
	a <= not DepunereSold;
	
	CP_3 : Modulo7Counter
	port map(
			UP => UP,
			RESET => a,
			Q => sel
			);
			
	with sel select
    choice <= "0000000000000101" when "000", -- 5 EUR
              "0000000000010000" when "001", -- 10 EUR
              "0000000000100000" when "010", -- 20 EUR
              "0000000001010000" when "011", -- 50 EUR
              "0000000100000000" when "100", -- 100 EUR
              "0000001000000000" when "101", -- 200 EUR
              "0000010100000000" when others; -- 500 EUR (for "110" and any other unhandled states)
	
	SC_1 : SumComparator
	port map(
			Available => SumAvailable,
			Needed => choice,
			SoldOK => SoldOK
			);

end D;