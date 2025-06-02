library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- use IEEE.STD_LOGIC_ARITH.ALL; -- Comentat, conform discutiilor anterioare

entity ATM is
port(
	InserareCard : in std_logic;
	C : in std_logic_vector(2 downto 0);
	I : in std_logic_vector(1 downto 0);
	CLK1 : in std_logic;
	CLK2 : in std_logic;
	CLK : in std_logic; --internal clock
	COUNT : in std_logic;
	UPDOWN : in std_logic;
	RESET : in std_logic;
	
	DepunereOk : out std_logic; 
	
	CardInserat : out std_logic;
	EliberareNumerar : out std_logic;
	EliberareChitanta : out std_logic;
	BanknotesError : out std_logic;
	MoreThan1000 : out std_logic;
	EroareSold : out std_logic;
	BlocareCard : out std_logic;
	Display : out std_logic_vector(15 downto 0);
	
	current_state_display : out std_logic_vector(2 downto 0)
	);
end ATM;

architecture A of ATM is

	signal t3_signal, soldok_signal, pinok_signal, verificarepin_signal, blocarecard_signal, retragereexacta_signal, schimbarepin_signal, eroaresold_signal, eliberarenumerar_signal : std_logic;
	signal pinmemdin_signal, pinmemout_signal : std_logic_vector(15 downto 0);
	signal monmemdin_signal, monmemout_signal : std_logic_vector(15 downto 0);
	signal sumneeded_signal : std_logic_vector(15 downto 0);
	signal soldokB_signal : std_logic;
	signal verificarepin_display, retragereexacta_display: std_logic_vector(15 downto 0);
	signal selection_display : std_logic_vector(2 downto 0);
	signal activateb_signal, pinschimbat_signal, banknoteserror_signal, eliberarenumerar_signal_2, lessthan1000_signal, eliberarenumerarok_signal : std_logic;
	signal current_amount : std_logic_vector(15 downto 0);
    signal trigger_write_depunere : std_logic := '0';
	signal depunereactivata_signal : std_logic;
	signal adaugarenumerar_signal_cmd : std_logic;
	signal suma_introdusa_depunere_signal : std_logic_vector(15 downto 0);
	signal newamount_after_deposit_signal : std_logic_vector(15 downto 0);
	signal monmemdin_signal_withdrawal : std_logic_vector(15 downto 0);
	signal depunereok_signal_internal : std_logic;

    signal mon_mem_we_signal : std_logic;


	component CommandUnit is
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
	DepunereSold : out std_logic;
	RetragereExacta : out std_logic;
	SchimbarePin : out std_logic;
	EroareSold : out std_logic;
	EliberareNumerar : out std_logic;
	AdaugareNumerar: out std_logic;
	EliberareChitanta : out std_logic;
	
	Selection : out std_logic_vector(2 downto 0);
	
	activateb : out std_logic;

	pinschimbat_activate : out std_logic;
	
	current_state_display : out std_logic_vector(2 downto 0)
		);
	end component;
	
	component PinMemory is
	port(
		CLK : in std_logic;
		SEL : in std_logic_vector(2 downto 0);
		DIN : in std_logic_vector(15 downto 0);
		OUTPUT : out std_logic_vector(15 downto 0)
		);
	end component;
	
	component MoneyMemory is
	port(
		CLK : in std_logic;
		SEL : in std_logic_vector(2 downto 0);
		DIN : in std_logic_vector(15 downto 0);
		WE : in std_logic; -- Write Enable
		OUTPUT : out std_logic_vector(15 downto 0)
		);
	end component;
	
	component BlocVerificarePIN2 is
	port(
		VerifPin : in std_logic;
		CLK2 : in std_logic;
		CLK1 : in std_logic;
		COUNT : in std_logic;
		UPDOWN : in std_logic;
		PIN : in std_logic_vector(15 downto 0);
		DISPLAY : out std_logic_vector(15 downto 0);
		PinOK : out std_logic;
		T3 : out std_logic
		);
	end component;
	
	component RetragereExacta is
	port(
		COUNT : in std_logic;
		UPDOWN : in std_logic;
		RetragereExacta : in std_logic;
		CLK2 : in std_logic;
		SumAvailable : in std_logic_vector(15 downto 0);
		DISPLAY : out std_logic_vector(15 downto 0);
		SoldOK : out std_logic
		);
	end component;
	
	component SumToBeExtracted3 is
	port(
		A : in std_logic_vector(15 downto 0);
		B : in std_logic_vector(15 downto 0);
		ActivateB : in std_logic;
		CLK1 : in std_logic;
		SumNeeded : out std_logic_vector(15 downto 0)
		);
	end component;
	
	component BlocEliberareNumerar is
	port(
		EliberareNumerar : in std_logic;
		SumAvailable : in std_logic_vector(15 downto 0);
		SumNeeded : in std_logic_vector(15 downto 0);
		NewAmount : out std_logic_vector(15 downto 0);
		
		CLK : in std_logic;
		EliberareNumerar_OK : out std_logic;
		BanknotesError : out std_logic
		);
	end component;

	component BlocDepunereSold is -- Renaming from DepunereSold for clarity
	port(
	COUNT : in std_logic;
	UPDOWN : in std_logic;
	DepunereActivata : in std_logic;
	CLK2 : in std_logic;
	CLK1_Confirm : in std_logic; -- NOU: Adaugat in portul componentei
	DISPLAY_Depus : out std_logic_vector(15 downto 0)
	);
	end component;

	component BlocAdaugareNumerar is
	port(
	AdaugareNumerar : in std_logic;
	SumAvailable : in std_logic_vector(15 downto 0);
	SumToDeposit : in std_logic_vector(15 downto 0);
	NewAmount : out std_logic_vector(15 downto 0);
	
	CLK : in std_logic;
	DepunereOK : out std_logic
	);
	end component;
	
	component BlocSchimbarePin is
	port(
		SchimbarePin : in std_logic;
		COUNT : in std_logic;
		UPDOWN : in std_logic;
		CLK2 : in std_logic;
		NewPin : out std_logic_vector(15 downto 0)
		);
	end component;
	
	component BlocDisplay is
	port(
		VerificarePin : in std_logic_vector(15 downto 0);
		SchimbarePin : in std_logic_vector(15 downto 0);
		RetragereExacta : in std_logic_vector(15 downto 0);
		EliberareNumerar : in std_logic_vector(15 downto 0);
		InterogareSold : in std_logic_vector(15 downto 0);
		DepunereSold : in std_logic_vector(15 downto 0);
		Selection : in std_logic_vector(2 downto 0);
	
		DISPLAY : out std_logic_vector(15 downto 0)
		);
	end component;
	
	component comparator1000 is
	port(
		SumNeeded : in std_logic_vector(15 downto 0);
		LessThan1000 : out std_logic
		);
	end component;
	
begin
	
	BanknotesError <= (banknoteserror_signal and eliberarenumerar_signal) and lessthan1000_signal;
	
	process(CLK)
		begin
			if(CLK' event and CLK = '1') then
				if(retragereexacta_signal = '1') then
					current_amount <= monmemout_signal;
				end if;
			end if;
		end process;
		
	process(CLK)
    begin
        if rising_edge(CLK) then
            if depunereok_signal_internal = '1' then
                trigger_write_depunere <= '1';
            else
                trigger_write_depunere <= '0'; -- se resetează automat după un ciclu
            end if;
        end if;
    end process;
    	
	EliberareNumerar <= eliberarenumerarok_signal;
	EroareSold <= eroaresold_signal;
	BlocareCard <= blocarecard_signal;
	MoreThan1000 <= (not lessthan1000_signal) and eliberarenumerar_signal;

    mon_mem_we_signal <= trigger_write_depunere or eliberarenumerarok_signal;

	COMMAND_U : CommandUnit
	port map(
			CLK1 => CLK1,
			RESET => RESET,
			InserareCard => InserareCard,
			PinOK => pinok_signal,
			I => I,
			T3 => t3_signal,
			SoldOK => soldokB_signal,
			DepunereOk => depunereok_signal_internal, -- Iesirea DepunereOk de la BlocAdaugareNumerar
			
			CardInserat => CardInserat,
			VerificarePIN => verificarepin_signal,
			BlocareCard => blocarecard_signal,
			RetragereExacta => retragereexacta_signal,
			SchimbarePin => schimbarepin_signal,
			EroareSold => eroaresold_signal,
			EliberareNumerar => eliberarenumerar_signal,
			DepunereSold => depunereactivata_signal,
			AdaugareNumerar => adaugarenumerar_signal_cmd,
			EliberareChitanta => EliberareChitanta,
			Selection => selection_display,
			
			activateb => activateb_signal,
			pinschimbat_activate => pinschimbat_signal,
			
			current_state_display => current_state_display
			);
			
	PIN_M : PinMemory
	port map(
			CLK => pinschimbat_signal,
			SEL => C,
			DIN => pinmemdin_signal,
			OUTPUT => pinmemout_signal
			);
	
	MON_M : MoneyMemory
	port map(
			CLK => CLK,
			SEL => C,
			DIN => monmemdin_signal,
			WE => mon_mem_we_signal,
			OUTPUT => monmemout_signal
			);
	
	VERIFPIN : BlocVerificarePIN2
	port map(
			VerifPin => verificarepin_signal,
			CLK2 => CLK2,
			CLK1 => CLK1,
			COUNT => COUNT,
			UPDOWN => UPDOWN,
			PIN => pinmemout_signal,
			DISPLAY => verificarepin_display,
			PinOK => pinok_signal,
			T3 => t3_signal
			);
	
	RETREX : RetragereExacta
	port map(
			COUNT => COUNT,
			UPDOWN => UPDOWN,
			RetragereExacta => retragereexacta_signal,
			CLK2 => CLK2,
			SumAvailable => monmemout_signal,
			DISPLAY => retragereexacta_display,
			SoldOK => soldokB_signal
			);
	
	SUMTOBE : SumToBeExtracted3
	port map(
			A => (others => '0'),
			B => retragereexacta_display,
			ActivateB => activateb_signal,
			CLK1 => CLK1,
			SumNeeded => sumneeded_signal
			);
			
	CMP1000 : comparator1000
	port map(
			SumNeeded => sumneeded_signal,
			LessThan1000 => lessthan1000_signal
			);
	
	eliberarenumerar_signal_2 <= eliberarenumerar_signal and lessthan1000_signal;
	
	ELIBNUM : BlocEliberareNumerar
	port map(
			EliberareNumerar => eliberarenumerar_signal_2,
			SumAvailable => current_amount,
			SumNeeded => sumneeded_signal,
			NewAmount => monmemdin_signal_withdrawal,
			CLK => CLK,
			EliberareNumerar_OK => eliberarenumerarok_signal,
			BanknotesError => banknoteserror_signal
			);

	DEP_SOLD : BlocDepunereSold
	port map(
			COUNT => COUNT,
			UPDOWN => UPDOWN,
			DepunereActivata => depunereactivata_signal,
			CLK2 => CLK2,
			CLK1_Confirm => CLK1, -- NOU: Conecteaza CLK1 la noul port
			DISPLAY_Depus => suma_introdusa_depunere_signal
			);

	ADNUM_BLOCK : BlocAdaugareNumerar
	port map(
			AdaugareNumerar => adaugarenumerar_signal_cmd,
			SumAvailable => monmemout_signal,
			SumToDeposit => suma_introdusa_depunere_signal,
			NewAmount => newamount_after_deposit_signal,
			CLK => CLK,
			DepunereOK => depunereok_signal_internal
			);
			
	SCHPIN : BlocSchimbarePin
	port map(
			SchimbarePin => schimbarepin_signal,
			COUNT => COUNT,
			UPDOWN => UPDOWN,
			CLK2 => CLK2,
			NewPin => pinmemdin_signal
			);
			
	DSPL : BlocDisplay
	port map(
			VerificarePin => verificarepin_display,
			SchimbarePin => pinmemdin_signal,
			RetragereExacta => retragereexacta_display,
			EliberareNumerar => monmemdin_signal,
			InterogareSold => monmemout_signal,
			DepunereSold => suma_introdusa_depunere_signal,
			Selection => selection_display,
			DISPLAY => DISPLAY
			);
			
	monmemdin_signal <= newamount_after_deposit_signal when adaugarenumerar_signal_cmd = '1' else
						monmemdin_signal_withdrawal;
	
	soldok_signal <= soldokB_signal;
	
	DepunereOk <= depunereok_signal_internal;
	
end A;