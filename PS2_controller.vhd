----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:50:58 08/01/2016 
-- Design Name: 
-- Module Name:    PS2_controller - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all; --//very important
use IEEE.NUMERIC_STD.all;
use work.Package1.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PS2_controller is
    Port ( CLOCK_50 : in  STD_LOGIC;
			  Resetn : in  STD_LOGIC;
		   
		     PS2_clock : in  STD_LOGIC;
		     PS2_data : in  STD_LOGIC;
		   
           PS2_code : out  STD_LOGIC_VECTOR (7 downto 0);
           PS2_code_ready : out  STD_LOGIC;
           PS2_make_code : out  STD_LOGIC
		   );
end PS2_controller;

architecture Behavioral of PS2_controller is

signal PS2_state : PS2_status;
signal PS2_clock_sync, PS2_clock_buf : STD_LOGIC;
signal PS2_shift_reg : STD_LOGIC_VECTOR (7 downto 0);
signal PS2_bit_count : STD_LOGIC_VECTOR (2 downto 0);
signal PS2_parity : STD_LOGIC;
signal PS2_code_m : STD_LOGIC_VECTOR (7 downto 0);

begin
process(Clock_50, Resetn)
begin
	if rising_edge(Clock_50) then
		if (Resetn = '0') then
				PS2_clock_buf <= '0';	
				PS2_clock_sync <= '0';			
				PS2_state <= S_PS2_IDLE;
				PS2_bit_count <= "000";
				PS2_code_ready <= '0';
				PS2_code <= x"00";
				PS2_code_m <= x"00";
				PS2_parity <= '0';
				PS2_make_code <= '0';
				PS2_shift_reg <= x"00";
		else
			--// Synchronize the data
			PS2_clock_sync <= PS2_clock;
			PS2_clock_buf <= PS2_clock_sync;
		
			--// Edge detection for PS2 clock
			if (PS2_clock_sync AND NOT PS2_clock_buf) = '1'  then
				case PS2_state is
				when S_PS2_IDLE =>
					if (PS2_data = '0') then
						--// Start bit detected
						PS2_state <= S_PS2_ASSEMBLE_CODE;
						PS2_shift_reg <= x"00";
						PS2_bit_count <= "000";
						PS2_code_ready <= '0';
					end if;
				when S_PS2_ASSEMBLE_CODE =>
					--// Shift in data
					PS2_shift_reg <= PS2_data & PS2_shift_reg(7 downto 1);
					if (PS2_bit_count < "111") then
						PS2_bit_count <= PS2_bit_count + 1;
					else
						PS2_state <= S_PS2_PARITY;
					end if;
				when S_PS2_PARITY =>
					--// Get parity bit
					PS2_parity <= PS2_data;
					PS2_state <= S_PS2_STOP;
				when S_PS2_STOP =>
					if (PS2_data = '1') then
						--// Stop bit detected
						--// Check for make or break code
						if (PS2_code_m = x"F0" OR PS2_shift_reg = x"F0") then
							PS2_make_code <= '0';
						else 
							PS2_make_code <= '1';
						end if;						
						PS2_code <= PS2_shift_reg;
						PS2_code_m <= PS2_shift_reg;
						PS2_code_ready <= '1';
					end if;
					PS2_state <= S_PS2_IDLE;
				when OTHERS =>
					PS2_state <= S_PS2_IDLE;
				end case;
			end if;
		end if;
	end if;
end process;

end Behavioral;
