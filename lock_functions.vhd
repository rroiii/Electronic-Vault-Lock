LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.lock_types.ALL;

PACKAGE lock_functions IS
    PROCEDURE waitCounter(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300000;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END PACKAGE lock_functions;

PACKAGE BODY lock_functions IS

    PROCEDURE waitCounter(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300000;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    ) IS
    BEGIN
        counter <= counter - 1; -- Decrement the counter
        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4));
    END PROCEDURE waitCounter;

END PACKAGE BODY lock_functions;