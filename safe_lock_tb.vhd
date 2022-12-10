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
    TYPE DigitArray IS ARRAY (0 TO 10) OF STD_LOGIC_VECTOR(0 TO 3);

    -- Default Password is 4 2 3 5 (0100) (0010) (0011) (0101)
    CONSTANT unlockTable : DigitArray := (
    ("0100"), ("0010"), ("0000"), ("0000"), ("0011"), ("0000"), ("0000"), ("0000"), ("0000"), ("0101"), ("0000")
    );

    -- New Password 6 7 5 4 (0110) (0111) (0101) (0100)
    CONSTANT setPaswordTable : DigitArray := (
    ("0110"), ("0110"), ("0111"), ("0111"), ("0101"), ("0101"), ("0100"), ("0100"), ("0000"), ("0000"), ("0000")
    );

    SIGNAL i : INTEGER RANGE 0 TO 22 := 0;

    SIGNAL clk : STD_LOGIC := '0'; -- Clock signal
    SIGNAL clk_lamp : STD_LOGIC := '0'; -- Clock for lamp signal
    SIGNAL rst : STD_LOGIC := '0'; -- Reset signal
    SIGNAL d : STD_LOGIC_VECTOR(0 TO 3) := unlockTable(0); -- Input for the combination lock
    SIGNAL btn_lock : STD_LOGIC := '0'; -- Button to lock the safe
    SIGNAL btn_set : STD_LOGIC := '1'; -- Button to set new password for the combination lock
    SIGNAL correct : STD_LOGIC := '0'; -- Output indicating if the combination is correct (Default is 0)

    SIGNAL lamp_digit1, lamp_digit2, lamp_digit3, lamp_digit4 : STD_LOGIC_VECTOR (1 DOWNTO 0); -- Output lamp for each digit, 00 = OFF, RED = 01, GREEN = 10

    SIGNAL Seven_Segment_digit1 : STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for digit 1 on the seven segment display
    SIGNAL Seven_Segment_digit2 : STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for digit 2 on the seven segment display
    SIGNAL Seven_Segment_digit3 : STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for digit 3 on the seven segment display
    SIGNAL Seven_Segment_digit4 : STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for digit 4 on the seven segment display

    SIGNAL Seven_Segment_Seconds1 : STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for the first digit seconds on the seven segment display
    SIGNAL Seven_Segment_Seconds2 : STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for the second digit seconds on the seven segment display
    SIGNAL Seven_Segment_Minutes : STD_LOGIC_VECTOR (6 DOWNTO 0);-- Output for the minutes on the seven segment display
BEGIN
    DUT_Safe_Lock : ENTITY safe_Lock PORT MAP (clk_lamp, clk, rst, d, btn_lock, btn_set,
        correct, lamp_digit1, lamp_digit2, lamp_digit3, lamp_digit4, Seven_Segment_digit1,
        Seven_Segment_digit2, Seven_Segment_digit3, Seven_Segment_digit4, Seven_Segment_Seconds1,
        Seven_Segment_Seconds2, Seven_Segment_Minutes);

    -- Generate the clock
    clk <= NOT clk AFTER 1000 ms;
    clk_lamp <= NOT clk_lamp AFTER 250 ms;

    -- -- TestBench Sequence
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF i < DigitArray'length - 1 OR i = DigitArray'length - 1 THEN
                d <= unlockTable(i);
                ELSIF i > DigitArray'length - 1 THEN
                d <= setPaswordTable(i - DigitArray'length);
                btn_set <= '0';
                btn_lock <= '1';
            END IF;
            i <= i + 1;
        END IF;
    END PROCESS;

    PROCESS (clk_lamp)
    BEGIN
    END PROCESS;
END ARCHITECTURE rtl;