library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BlocDisplay is
port(
	VerificarePin : in std_logic_vector(15 downto 0);
	SchimbarePin : in std_logic_vector(15 downto 0);
	DepunereSold : in std_logic_vector(15 downto 0);
	RetragereExacta : in std_logic_vector(15 downto 0);
	EliberareNumerar : in std_logic_vector(15 downto 0);
	AdaugareNumerar: in std_logic_vector(15 downto 0);
	InterogareSold : in std_logic_vector(15 downto 0);
	Selection : in std_logic_vector(2 downto 0);
	
	DISPLAY : out std_logic_vector(15 downto 0)
	);
end BlocDisplay;

architecture DisplayB of BlocDisplay is

begin
	with Selection select 
		DISPLAY <= VerificarePin when "000",
				   SchimbarePin when "001",
				   DepunereSold when "010",
				   RetragereExacta when "011",
				   EliberareNumerar when "100",
				   AdaugareNumerar when "101",
				   InterogareSold when "110",
				 
				   "0000000000000000" when others;
end DisplayB;