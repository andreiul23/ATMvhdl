library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CommandUnit is
port(
	CLK1 : in std_logic;
	RESET : in std_logic;
	InserareCard : in std_logic;
	PinOK : in std_logic;
	I : in std_logic_vector(1 downto 0);
	T3 : in std_logic;
	SoldOK : in std_logic;
	DepunereOk: in std_logic;
	
	CardInserat : out std_logic;
	VerificarePIN : out std_logic;
	BlocareCard : out std_logic;
	DepunereSold : out std_logic; -- Output for the new Deposit Funds block
	RetragereExacta : out std_logic;
	SchimbarePin : out std_logic;
	EroareSold : out std_logic;
	EliberareNumerar : out std_logic;
	AdaugareNumerar: out std_logic; -- Acest semnal va activa Bloc Adaugare Numerar
	EliberareChitanta : out std_logic;
	
	Selection : out std_logic_vector(2 downto 0);
	
	activateb : out std_logic;

	pinschimbat_activate : out std_logic;
	
	current_state_display : out std_logic_vector(2 downto 0)

	);


end CommandUnit;


architecture Commands of CommandUnit is

	-- Am adăugat AdaugareNumerarS ca o stare distinctă
	type state_type is(Standby, VerificarePinS, CardBlocat, SelectareOperatiune, DepunereSoldS, RetragereExactaS, InterogareSold, SchimbarePinS, PinSchimbat, EroareSoldS, EliberareNumerarS, AdaugareNumerarS, ScoatetiCardul);
	signal curr_state, next_state : state_type;

begin
	process(CLK1, RESET)
		begin
			if(RESET = '1') then
				next_state <= Standby;
				EliberareChitanta <= '0';
			elsif(CLK1' event and CLK1 = '1') then
				-- Original logic for EliberareChitanta for Retragere Exacta
				if(((curr_state = RetragereExactaS) and I(1) = '1') and SoldOK = '1') then
					EliberareChitanta <= '1';
				-- New logic for EliberareChitanta for Depunere Sold
				elsif(((curr_state = AdaugareNumerarS) and I(1) = '1') and DepunereOK = '1') then -- Changed DepunereSoldS to AdaugareNumerarS for chitanta
				    EliberareChitanta <= '1';
				else
				    EliberareChitanta <='0';	
				end if;
				case curr_state is
					when Standby => if (InserareCard = '1') then
										next_state <= VerificarePinS;
									else
										next_state <= Standby;
									end if;
					when VerificarePinS => if(PinOK = '0') then
										   		if(T3 = '0') then
													next_state <= VerificarePinS;
												else
													next_state <= CardBlocat;
												end if;
											else
												next_state <= SelectareOperatiune;
											end if;
					when CardBlocat => next_state <= CardBlocat;
					when SelectareOperatiune => if(I(1) = '0') then
													if(I(0) = '0') then --case 00: Depunere Sold 
														next_state <= DepunereSoldS;
													else
														next_state <= RetragereExactaS; --case 01: Retragere Exacta
													end if;
												else
													if(I(0) = '0') then --case 10: Interogare Sold
														next_state <= InterogareSold;
													else
														next_state <= SchimbarePinS; --case 11: SchimbarePin
													end if;
												end if;
					when DepunereSoldS =>  if(DepunereOK = '1') then
					                               next_state <= EroareSoldS;
					                        else
                                                    next_state <= AdaugareNumerarS;
                                            end if;
					when AdaugareNumerarS => if(I(0) = '0') then
										   		next_state <= ScoatetiCardul;
										   else
										   		next_state <= SelectareOperatiune;
										   end if;
					when RetragereExactaS => if(SoldOK = '0') then
											  		next_state <= EroareSoldS;
											 else
													next_state <= EliberareNumerarS;
											 end if;
					when InterogareSold => if(I(0) = '0') then
										   		next_state <= ScoatetiCardul;
										   else
										   		next_state <= SelectareOperatiune;
										   end if;
					when SchimbarePinS => next_state <= PinSchimbat;
					when PinSchimbat => if(I(0) = '0') then
										   		next_state <= ScoatetiCardul;
										   else
										   		next_state <= SelectareOperatiune;
										   end if;
					when EliberareNumerarS => if(I(0) = '0') then
										   		next_state <= ScoatetiCardul;
										   else
										   		next_state <= SelectareOperatiune;
										   end if;
					when EroareSoldS => if(I(0) = '0') then
										   		next_state <= ScoatetiCardul;
										   else
										   		next_state <= SelectareOperatiune;
										   end if;
					when ScoatetiCardul => if(InserareCard = '0') then
										   		next_state <= Standby;
										   else
										   		next_state <= ScoatetiCardul;
										   end if;
					when others => next_state <= Standby;
					
				end case;
			end if;
		end process;
	
	curr_state <= next_state;
	--outputs
	CardInserat <= '0' when curr_state = Standby else
	               '1';
	VerificarePin <= '1' when curr_state = VerificarePinS else
				     '0';
	BlocareCard <= '1' when curr_state = CardBlocat else
				   '0';
	DepunereSold <= '1' when curr_state = DepunereSoldS else -- Activăm Bloc Depunere Sold când suntem în această stare
					'0';
	AdaugareNumerar <= '1' when curr_state = AdaugareNumerarS else -- Activăm Bloc Adaugare Numerar
                       '0';				
	RetragereExacta <= '1' when curr_state = RetragereExactaS else
					   '0';
	SchimbarePin <= '1' when curr_state = SchimbarePinS else
					'0';
	EroareSold <= '1' when curr_state = EroareSoldS else
				  '0';
	EliberareNumerar <= '1' when curr_state = EliberareNumerarS else
						'0';
  
	
	Selection <= "000" when curr_state = VerificarePinS else
				 "001" when curr_state = SchimbarePinS else
				 "010" when curr_state = DepunereSoldS else -- Map DepunereSoldS to "010"
				 "011" when curr_state = RetragereExactaS else
				 "100" when curr_state = EliberareNumerarS else
				 "101" when curr_state = AdaugareNumerarS else
				 "110" when curr_state = InterogareSold else
				 "111";
				 
	activateb <= '1' when curr_state = RetragereExactaS else
				 '0';
				 
	pinschimbat_activate <= '1' when curr_state = PinSchimbat else
							'0';
							
	with curr_state select
		current_state_display <= "000" when Standby,
								 "001" when VerificarePinS,
								 "010" when SelectareOperatiune,
								 "011" when DepunereSoldS, -- Display for entering deposit amount
								 "100" when RetragereExactaS,
								 "101" when SchimbarePinS,
								 "110" when ScoatetiCardul,
								 "111" when others; -- Eliberare numerar, Eroare sold, Interogare sold, Pin schimbat, AdaugareNumerar -> Alta operatiune? // Blocare card	
end Commands;