LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.lock_constant.ALL;
USE work.lock_types.ALL;

PACKAGE lock_functions IS
    PROCEDURE DecrementCounter(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300000;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );

    PROCEDURE IncorrectDigit(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300000;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL state : OUT state_type
    );

END PACKAGE lock_functions;

PACKAGE BODY lock_functions IS
    -- Decrement the counter by 1 in miliseconds
    PROCEDURE DecrementCounter(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300000;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    ) IS
    BEGIN
        counter <= counter - 1; -- Decrement the counter
        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4));
    END PROCEDURE DecrementCounter;

    -- The Entered Input is Incorrect, so set the state to waitTimer to wait for 30 seconds
    -- When its finish, start again from state start (code can be seen in safe_lock code)
    PROCEDURE IncorrectDigit(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300000;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL state : OUT state_type
    ) IS
    BEGIN
        state <= waitTimer; -- Incorrect  digit, go to wait state
        counter <= lockWaitTime; -- Set the counter to lockWaitTime
        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
    END PROCEDURE IncorrectDigit;

END PACKAGE BODY lock_functions;