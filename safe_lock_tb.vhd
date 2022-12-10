LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.safe_lock;

ENTITY safe_lock_tb IS
END ENTITY safe_lock_tb;

ARCHITECTURE rtl OF safe_lock_tb IS
    CONSTANT ClockFrequencyHz : INTEGER := 1;
    CONSTANT ClockPeriod : TIME := 1 sec / ClockFrequencyHz;
    CONSTANT ClockPeriodLamp : TIME := 250 ms / ClockFrequencyHz;

    --Input digit
    TYPE digit IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(0 TO 3);
    CONSTANT lookTable : digit := (
    ("0100"), ("0010"), ("0011"), ("0101")
    );

    signal clk : STD_LOGIC := '0';      -- Clock signal
    signal clk_lamp : STD_LOGIC := '0'; -- Clock for lamp signal
    signal rst : STD_LOGIC := '0';      -- Reset signal
    signal d : STD_LOGIC_VECTOR(0 TO 3); -- Input for the combination lock
    signal btn_lock : STD_LOGIC := '0';  -- Button to lock the safe
    signal btn_set : STD_LOGIC := '0';   -- Button to set new password for the combination lock
    signal correct : STD_LOGIC := '0';   -- Output indicating if the combination is correct (Default is 0)

    signal lamp_digit1, lamp_digit2, lamp_digit3, lamp_digit4 : STD_LOGIC_VECTOR (1 DOWNTO 0); -- Output lamp for each digit, 00 = OFF, RED = 01, GREEN = 10

    signal Seven_Segment_digit1 : STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for digit 1 on the seven segment display
    signal Seven_Segment_digit2 : STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for digit 2 on the seven segment display
    signal Seven_Segment_digit3 : STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for digit 3 on the seven segment display
    signal Seven_Segment_digit4 : STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for digit 4 on the seven segment display

    signal Seven_Segment_Seconds1 : STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for the first digit seconds on the seven segment display
    signal Seven_Segment_Seconds2 : STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for the second digit seconds on the seven segment display
    signal Seven_Segment_Minutes : STD_LOGIC_VECTOR (6 DOWNTO 0);-- Output for the minutes on the seven segment display
BEGIN

    safe_lock : entity work.Safe_Lock port map (clk_lamp, clk, rst, d, btn_lock, btn_set, correct, lamp_digit1, lamp_digit2, lamp_digit3, lamp_digit4, Seven_Segment_digit1, Seven_Segment_digit2, Seven_Segment_digit3, Seven_Segment_digit4, Seven_Segment_Seconds1,Seven_Segment_Seconds2,Seven_Segment_Minutes);

    -- Generate the clock
    clk <= NOT clk AFTER 1000 ms;
    clk_lamp <= NOT clk_lamp AFTER 250 ms;

    -- -- TestBench Sequence
    PROCESS (clk)
    VARIABLE i : INTEGER RANGE 0 TO digit'length;
    BEGIN
        IF rising_edge(clk) THEN
        d <= lookTable(i);
        i := i + 1;
        END IF;
    END PROCESS;

    PROCESS (clk_lamp)
    BEGIN
    END PROCESS;

END ARCHITECTURE rtl;