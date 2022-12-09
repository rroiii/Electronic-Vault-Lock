library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer_tb is
end entity;

architecture sim of timer_tb is
    constant ClockFrequencyHz : integer := 10; 
    constant ClockPeriod      : time := 1000 ms / ClockFrequencyHz;

    signal CLOCK    : std_logic := '1';
    signal RESET   : std_logic := '0';
    signal Seconds : integer;
    signal Minutes : integer;
    signal digit1  : integer;
    signal digit2  : integer;
    signal Seven_Segment_Seconds1 :  STD_LOGIC_VECTOR (6 downto 0);
    signal Seven_Segment_Seconds2 :  STD_LOGIC_VECTOR (6 downto 0);
    signal Seven_Segment_Minutes : STD_LOGIC_VECTOR (6 downto 0);

begin
    i_Timer : entity work.timer(rtl)
    generic map(ClockFrequencyHz => ClockFrequencyHz)
    port map (
        CLOCK    => CLOCK,
        RESET   => RESET,
        Seconds => Seconds,
        Minutes => Minutes,
        digit1 => digit1,
        digit2 => digit2,
        Seven_Segment_Seconds1 => Seven_Segment_Seconds1,
        Seven_Segment_Seconds2 => Seven_Segment_Seconds2,
        Seven_Segment_Minutes => Seven_Segment_Minutes );

    CLOCK <= not CLOCK after ClockPeriod / 2;

    process is
    begin
        wait until rising_edge(CLOCK);
        wait until rising_edge(CLOCK);

        RESET <= '1';

        wait;
    end process;

end architecture;