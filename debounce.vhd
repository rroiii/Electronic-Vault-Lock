LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

-- Debounce entity
ENTITY debounce IS
    PORT (
        clk : IN STD_LOGIC;
        raw_signal : IN STD_LOGIC;
        debounced_signal : OUT STD_LOGIC
    );
END debounce;

-- Debounce architecture
ARCHITECTURE debounce_arch OF debounce IS

    -- Initialize the counter and debounce delay
    SIGNAL counter : INTEGER RANGE 0 TO 100 := 0;
    SIGNAL debounce_delay : INTEGER RANGE 0 TO 100 := 10;
BEGIN

    -- Debouncing process
    debouncing : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF raw_signal = '1' THEN
                counter <= counter + 1;
            ELSE
                counter <= 0;
            END IF;
        END IF;
    END PROCESS;

    -- Output process
    output : PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF counter >= debounce_delay THEN
                debounced_signal <= raw_signal;
            END IF;
        END IF;
    END PROCESS;

END debounce_arch;