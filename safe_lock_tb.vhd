LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.timer;
USE work.safe_lock;

ENTITY safe_lock_tb IS
END ENTITY safe_lock_tb;

ARCHITECTURE rtl OF safe_lock_tb IS
    CONSTANT ClockFrequencyHz : INTEGER := 1;
    CONSTANT ClockPeriod : TIME := 1 sec / ClockFrequencyHz;
    CONSTANT ClockPeriodLamp : TIME := 250 ms / ClockFrequencyHz;

    SIGNAL CLOCK : STD_LOGIC := '0';
    SIGNAL CLOCK_LAMP : STD_LOGIC := '0';
    SIGNAL RESET : STD_LOGIC := '0';
    SIGNAL Seconds : INTEGER := 0;
    SIGNAL Minutes : INTEGER := 0;
BEGIN
    -- DUT_SafeLock : ENTITY safe_lock
    --     PORT MAP(

    --     );

    -- Generate the clock
    CLOCK <= NOT CLOCK AFTER 1000 ms;
    CLOCK_LAMP <= NOT CLOCK_LAMP AFTER 250 ms;

    -- -- TestBench Sequence
    PROCESS IS
    BEGIN
        WAIT UNTIL rising_edge(CLOCK);
    END PROCESS;

    PROCESS IS
    BEGIN
        WAIT UNTIL rising_edge(CLOCK_LAMP);
    END PROCESS;
END ARCHITECTURE rtl;