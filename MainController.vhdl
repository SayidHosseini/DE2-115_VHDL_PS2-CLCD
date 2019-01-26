library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.NUMERIC_STD.all;
use work.Package1.all;

entity MainController is
    Port (
			CLOCK_50 : IN STD_LOGIC; --// 50 MHz clock
			SW : in  STD_LOGIC_VECTOR (17 downto 0);	--// toggle switches

			HEX0 : out  STD_LOGIC_VECTOR (6 downto 0); --// 8 seven segment displays
			HEX1 : out  STD_LOGIC_VECTOR (6 downto 0); --// 8 seven segment displays
			HEX2 : out  STD_LOGIC_VECTOR (6 downto 0); --// 8 seven segment displays
			HEX3 : out  STD_LOGIC_VECTOR (6 downto 0); --// 8 seven segment displays
			HEX4 : out  STD_LOGIC_VECTOR (6 downto 0); --// 8 seven segment displays
			HEX5 : out  STD_LOGIC_VECTOR (6 downto 0); --// 8 seven segment displays
			HEX6 : out  STD_LOGIC_VECTOR (6 downto 0); --// 8 seven segment displays
			HEX7 : out  STD_LOGIC_VECTOR (6 downto 0); --// 8 seven segment displays
																		
			LEDG : out  STD_LOGIC_VECTOR (8 downto 0);            --// 9 green LEDs
			LEDR : out  STD_LOGIC_VECTOR (17 downto 0);             --// 18 red LEDs
			
			PS2_DAT : in  STD_LOGIC;
		  	PS2_CLK : in  STD_LOGIC;

			LCD_ON : OUT STD_LOGIC;	--// LCD power ON/OFF
			LCD_BLON : OUT STD_LOGIC;	--// LCD back light ON/OFF
			LCD_RW : OUT STD_LOGIC;	--// LCD read/write select, 0 = Write, 1 = Read
			LCD_EN : OUT STD_LOGIC;	--// LCD enable
			LCD_RS : OUT STD_LOGIC;	--// LCD command/data select, 0 = Command, 1 = Data
			LCD_DATA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)	--// LCD data bus 8 bits
		   );
end MainController;

architecture Behavioral of MainController is	
SIGNAL resetn :STD_LOGIC;

SIGNAL PS2_code :STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL PS2_code_ready, PS2_code_ready_buf :STD_LOGIC;
SIGNAL PS2_make_code :STD_LOGIC;

SIGNAL state : status;

SIGNAL LCD_instruction :STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL LCD_code :STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL LCD_position :STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL LCD_line :STD_LOGIC;

SIGNAL value_7_segment: Byte (5 downto 0);

SIGNAL line1:std_logic_vector(127 downto 0);
SIGNAL line2:std_logic_vector(127 downto 0);
SIGNAL CURSOR: Integer range 0 to 127 := 127;

begin	
	resetn <= NOT SW(17);
	LCD_ON<='1';
	
	LEDR <= resetn & x"0000" & PS2_make_code;
	LEDG <= LCD_instruction;
	
	--// PS2 unit
	ps2_unit : entity work.PS2_controller
	port map (
		Clock_50       => CLOCK_50,
		Resetn         => resetn,
		PS2_clock      => PS2_CLK,
		PS2_data       => PS2_DAT,
		PS2_code       => PS2_code,
		PS2_code_ready => PS2_code_ready,
		PS2_make_code  => PS2_make_code
	);

	PS2_to_LCD_ROM_inst : entity work.PS2_to_LCD_ROM
	port map (
		address		   => '0' & PS2_code,
		clock       => CLOCK_50,
		q			   => LCD_code
	);

	--// LCD unit
	LCD_unit :entity work.lcd16x2_ctrl
	  port map (
		 clk          => CLOCK_50,
		 rst          => '0',
		 lcd_e        => LCD_EN,
		 lcd_rs       => LCD_RS,
		 lcd_rw       => LCD_RW,
		 lcd_db       => LCD_DATA(7 downto 4),
		 line1_buffer => line1,
		 line2_buffer => line2);

	process(Clock_50, resetn, PS2_code)
	VARIABLE CURSOR_BUFF: Integer range 0 to 127 := 127;
	VARIABLE LCD_line_BUFF: STD_LOGIC;
	
	begin
		if (resetn = '0') then
			CURSOR <= 127;
			CURSOR_BUFF := 127;
			LCD_position <= x"0";
			LCD_line <= '0';
			LCD_line_BUFF := '0';
			PS2_code_ready_buf <= '0';
			
			line1(127 downto 120) <= X"20"; 
			line1(119 downto 112) <= X"20";
			line1(111 downto 104) <= X"20";
			line1(103 downto 96)  <= X"20";
			line1(95 downto 88)   <= X"20";
			line1(87 downto 80)   <= X"20";
			line1(79 downto 72)   <= X"20";
			line1(71 downto 64)   <= X"20";
			line1(63 downto 56)   <= X"20";
			line1(55 downto 48)   <= X"20";
			line1(47 downto 40)   <= X"20";
			line1(39 downto 32)   <= X"20";
			line1(31 downto 24)   <= X"20";
			line1(23 downto 16)   <= X"20";
			line1(15 downto 8)    <= X"20";
			line1(7 downto 0)     <= X"20";
			
			line2(127 downto 120) <= X"20"; 
			line2(119 downto 112) <= X"20";
			line2(111 downto 104) <= X"20";
			line2(103 downto 96)  <= X"20";
			line2(95 downto 88)   <= X"20";
			line2(87 downto 80)   <= X"20";
			line2(79 downto 72)   <= X"20";
			line2(71 downto 64)   <= X"20";
			line2(63 downto 56)   <= X"20";
			line2(55 downto 48)   <= X"20";
			line2(47 downto 40)   <= X"20";
			line2(39 downto 32)   <= X"20";
			line2(31 downto 24)   <= X"20";
			line2(23 downto 16)   <= X"20";
			line2(15 downto 8)    <= X"20";
			line2(7 downto 0)     <= X"20";
			
			state <= S_IDLE;
			
		elsif rising_edge(Clock_50) then
			PS2_code_ready_buf <= PS2_code_ready;
			
			case state is
			when  S_IDLE =>
				--// Scan code is detected
				if ((PS2_code_ready AND NOT PS2_code_ready_buf AND PS2_make_code) = '1') then
					state <= S_LCD_ISSUE_INSTRUCTION_delay;
				end if;
			when S_LCD_ISSUE_INSTRUCTION_delay =>
				state <= S_LCD_ISSUE_INSTRUCTION;
			when  S_LCD_ISSUE_INSTRUCTION =>	
					if((LCD_code >= x"61" AND LCD_code <= x"7A") OR PS2_code = x"29") then -- a to z characters and SPACE
						if(LCD_line = '0') then
							line1(CURSOR DOWNTO (CURSOR - 7)) <= LCD_code;
							
							if(LCD_position < 15) then
								CURSOR <= CURSOR - 8;
								CURSOR_BUFF := CURSOR_BUFF - 8;							
								LCD_position <= LCD_position + 1;
							else
								CURSOR <= 127;
								CURSOR_BUFF := 127;
								LCD_position <= x"0";
								LCD_line <= '1';
								LCD_line_BUFF := '1';
							end if;
						else
							line2(CURSOR DOWNTO (CURSOR - 7)) <= LCD_code;
							
							if(LCD_position < 15) then
								CURSOR <= CURSOR - 8;
								CURSOR_BUFF := CURSOR_BUFF - 8;							
								LCD_position <= LCD_position + 1;
							else
								CURSOR <= 127;
								CURSOR_BUFF := 127;
								LCD_position <= x"0";
								LCD_line <= '0';
								LCD_line_BUFF := '0';
							end if;
						end if;
						
					elsif(PS2_code = x"66") then 							 -- BACKSPACE
						CURSOR <= CURSOR + 8;
						CURSOR_BUFF := CURSOR_BUFF + 8;
						LCD_position <= LCD_position - 1;
						if(CURSOR_BUFF = 7) then
							LCD_line <= NOT LCD_line;
							LCD_line_BUFF := NOT LCD_line_BUFF;
--							CURSOR <= 7;
--							CURSOR_BUFF <= 7;
						end if;
						
						if(LCD_line_BUFF = '0') then
							line1(CURSOR_BUFF DOWNTO (CURSOR_BUFF - 7)) <= x"20";
						else
							line2(CURSOR_BUFF DOWNTO (CURSOR_BUFF - 7)) <= x"20";
						end if;
					elsif(PS2_code = x"5A") then							 -- ENTER
						LCD_position <= x"0";
						LCD_line <= NOT LCD_line;
						LCD_line_BUFF := NOT LCD_line_BUFF;
						CURSOR <= 127;
						CURSOR_BUFF := 127;
					elsif(PS2_code = x"6b")	then							 -- LEFT arrow
						CURSOR <= CURSOR + 8;
						CURSOR_BUFF := CURSOR_BUFF + 8;
						LCD_position <= LCD_position - 1;
					elsif(PS2_code = x"74") then							 -- RIGTH arrow
						CURSOR <= CURSOR - 8;
						CURSOR_BUFF := CURSOR_BUFF - 8;
						LCD_position <= LCD_position + 1;
					elsif(PS2_code = x"75") then							 -- UP arrow
						LCD_line <= '0';
						LCD_line_BUFF := '0';
					elsif(PS2_code = x"72") then							 -- DOWN arrow
						LCD_line <= '1';
						LCD_line_BUFF := '1';
					elsif(PS2_code = x"76") then							 -- ESC
						CURSOR <= 127;
						CURSOR_BUFF := 127;
						LCD_position <= x"0";
						LCD_line <= '0';
						LCD_line_BUFF := '0';
						PS2_code_ready_buf <= '0';
						
						line1(127 downto 120) <= X"20"; 
						line1(119 downto 112) <= X"20";
						line1(111 downto 104) <= X"20";
						line1(103 downto 96)  <= X"20";
						line1(95 downto 88)   <= X"20";
						line1(87 downto 80)   <= X"20";
						line1(79 downto 72)   <= X"20";
						line1(71 downto 64)   <= X"20";
						line1(63 downto 56)   <= X"20";
						line1(55 downto 48)   <= X"20";
						line1(47 downto 40)   <= X"20";
						line1(39 downto 32)   <= X"20";
						line1(31 downto 24)   <= X"20";
						line1(23 downto 16)   <= X"20";
						line1(15 downto 8)    <= X"20";
						line1(7 downto 0)     <= X"20";
						
						line2(127 downto 120) <= X"20"; 
						line2(119 downto 112) <= X"20";
						line2(111 downto 104) <= X"20";
						line2(103 downto 96)  <= X"20";
						line2(95 downto 88)   <= X"20";
						line2(87 downto 80)   <= X"20";
						line2(79 downto 72)   <= X"20";
						line2(71 downto 64)   <= X"20";
						line2(63 downto 56)   <= X"20";
						line2(55 downto 48)   <= X"20";
						line2(47 downto 40)   <= X"20";
						line2(39 downto 32)   <= X"20";
						line2(31 downto 24)   <= X"20";
						line2(23 downto 16)   <= X"20";
						line2(15 downto 8)    <= X"20";
						line2(7 downto 0)     <= X"20";
					end if;
				state <= S_IDLE;
			when others => 
				state <= S_IDLE;
			end case;
		end if;
	end process;
  
  	Unit5 : entity work.HexToSevenSegment
	port map (
		 hex_value => "000" & LCD_line,
		 converted_value => value_7_segment(5)
		);
  
	Unit4 : entity work.HexToSevenSegment
	port map (
		 hex_value => LCD_position,
		 converted_value => value_7_segment(4)
		);

	Unit3 : entity work.HexToSevenSegment
	port map (
		 hex_value => PS2_code(7 downto 4),
		 converted_value => value_7_segment(3)
		);

	Unit2 : entity work.HexToSevenSegment
	port map (
		 hex_value => PS2_code(3 downto 0),
		 converted_value => value_7_segment(2)
		);
		
	Unit1 : entity work.HexToSevenSegment
	port map (
		 hex_value => LCD_code(7 downto 4),
		 converted_value => value_7_segment(1)
		);
		
	Unit0 : entity work.HexToSevenSegment
	port map (
		 hex_value => LCD_code(3 downto 0),
		 converted_value => value_7_segment(0)
		);
  
	HEX0 <= value_7_segment(0);
	HEX1 <= value_7_segment(1);
	HEX2 <= value_7_segment(2);
	HEX3 <= value_7_segment(3);
	HEX4 <= value_7_segment(4);
	HEX5 <= value_7_segment(5);
	HEX6 <= "1111111";
	HEx7 <= "1111111";
end Behavioral;
