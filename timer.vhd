library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
generic(ClockFrequencyHz : integer);
port(
    CLOCK     : in std_logic;
    RESET     : in std_logic := '1'; 
    Seconds : inout integer;
    Minutes : inout integer;
    digit1  : inout integer;
    digit2  : inout integer;
    Seven_Segment_Seconds1 : inout STD_LOGIC_VECTOR (6 downto 0);
    Seven_Segment_Seconds2 : inout STD_LOGIC_VECTOR (6 downto 0);
    Seven_Segment_Minutes : inout STD_LOGIC_VECTOR (6 downto 0));
end entity;

architecture rtl of timer is
    signal Ticks : integer;
begin

    process(CLOCK) is
    begin
        if rising_edge(CLOCK) then

            if RESET = '0' then
                Ticks   <= 0;
                Seconds <= 0;
                Minutes <= 0;
            else

                if Ticks = ClockFrequencyHz - 1 then
                    Ticks <= 0;
                    if Seconds = 59 then
                        Seconds <= 0;
                        if Minutes = 5 then
                            Minutes <= 0;
                        else
                            Minutes <= Minutes + 1;
                        end if;
                    else
                        Seconds <= Seconds + 1;
                    end if;
                else
                    Ticks <= Ticks + 1;
                end if;

            end if;
        end if;
    end process;

    digit1 <= Seconds / 10;
    digit2 <= Seconds - ((Seconds / 10) * 10);
    
    process(Minutes)
    begin
		case Minutes is
		when 0 =>
            Seven_Segment_Minutes  <= "0000001";
		when 1 =>
            Seven_Segment_Minutes  <= "1001111"; 
		when 2 =>
            Seven_Segment_Minutes  <= "0010010"; 
		when 3 =>
            Seven_Segment_Minutes  <= "0000110"; 
		when 4 =>
            Seven_Segment_Minutes  <= "1001100"; 
		when 5 =>
            Seven_Segment_Minutes  <= "0100100"; 
		when others =>
            Seven_Segment_Minutes  <= "1111111";
		end case;
    end process;

    process(digit1)
    begin
        case digit1 is
        when 0 =>
        Seven_Segment_Seconds1 <= "0000001";
        when 1 =>
        Seven_Segment_Seconds1 <= "1001111"; 
        when 2 =>
        Seven_Segment_Seconds1 <= "0010010"; 
        when 3 =>
        Seven_Segment_Seconds1 <= "0000110"; 
        when 4 =>
        Seven_Segment_Seconds1 <= "1001100"; 
        when 5 =>
        Seven_Segment_Seconds1 <= "0100100"; 
        when 6 =>
        Seven_Segment_Seconds1 <= "0100000"; 
        when 7 =>
        Seven_Segment_Seconds1 <= "0001111";
        when 8 =>
        Seven_Segment_Seconds1 <= "0000000"; 
        when 9 =>
        Seven_Segment_Seconds1 <= "0000100"; 
        when others =>
        Seven_Segment_Seconds1 <= "1111111";
        end case;
    end process;

    process(digit2)
    begin
        case digit2 is
        when 0 =>
        Seven_Segment_Seconds2 <= "0000001";
        when 1 =>
        Seven_Segment_Seconds2 <= "1001111"; 
        when 2 =>
        Seven_Segment_Seconds2 <= "0010010"; 
        when 3 =>
        Seven_Segment_Seconds2 <= "0000110"; 
        when 4 =>
        Seven_Segment_Seconds2 <= "1001100"; 
        when 5 =>
        Seven_Segment_Seconds2 <= "0100100"; 
        when 6 =>
        Seven_Segment_Seconds2 <= "0100000"; 
        when 7 =>
        Seven_Segment_Seconds2 <= "0001111";
        when 8 =>
        Seven_Segment_Seconds2 <= "0000000"; 
        when 9 =>
        Seven_Segment_Seconds2 <= "0000100"; 
        when others =>
        Seven_Segment_Seconds2 <= "1111111";
        end case;
    end process;
end architecture;