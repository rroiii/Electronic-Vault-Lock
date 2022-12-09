LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.lock_constant.ALL;
USE work.lock_types.ALL;

PACKAGE lock_functions IS
    PROCEDURE InputDigit(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300000;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL state : OUT state_digit;
        SIGNAL nextState : INOUT state_digit;
        SIGNAL state_lock : IN state_lock;
        setState : IN state_digit;
        d : IN STD_LOGIC_VECTOR(0 TO 3);
        SIGNAL correctDigitBinary : INOUT STD_LOGIC_VECTOR(0 TO 3);
        SIGNAL correct : OUT STD_LOGIC
    );

    PROCEDURE IncorrectDigit(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300000;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL state : OUT state_digit
    );

    PROCEDURE DecrementCounter(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300000;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );

END PACKAGE lock_functions;

PACKAGE BODY lock_functions IS

    -- To Check digit if the input is the correct combination or setting a new digit combination password
    PROCEDURE InputDigit(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300000;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL state : OUT state_digit;
        SIGNAL nextState : INOUT state_digit;
        SIGNAL state_lock : IN state_lock;
        setState : IN state_digit;
        d : IN STD_LOGIC_VECTOR(0 TO 3);
        SIGNAL correctDigitBinary : INOUT STD_LOGIC_VECTOR(0 TO 3);
        SIGNAL correct : OUT STD_LOGIC
    ) IS
    BEGIN
        CASE state_lock IS
            WHEN unlocking =>
                IF d = correctDigitBinary(0 TO 3) THEN -- Check if the digit match the password digit
                    state <= nextState;
                    nextState <= setState;
                    counter <= inputWaitTime;
                    IF (nextState = unlocked) THEN
                        correct <= '1';
                    END IF;
                ELSIF (counter = 0) THEN
                    IncorrectDigit(counter, seg_min, seg_sec, state);
                ELSE
                    DecrementCounter(counter, seg_min, seg_sec);
                END IF;
            WHEN setNewLock =>
                IF (counter = 0) THEN
                    state <= nextState;
                    nextState <= setState;
                    counter <= inputSetLockTime;
                    correctDigitBinary <= d; -- Set the new digit password
                ELSE
                    DecrementCounter(counter, seg_min, seg_sec);
                END IF;
        END CASE;

    END PROCEDURE InputDigit;

    -- The Entered Input is Incorrect, so set the state to waitTimer to wait for 30 seconds
    -- When its finish, start again from state start (code can be seen in safe_lock code)
    PROCEDURE IncorrectDigit(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300000;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL state : OUT state_digit
    ) IS
    BEGIN
        state <= waitTimer; -- Incorrect  digit, go to wait state
        counter <= lockWaitTime; -- Set the counter to lockWaitTime
        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
    END PROCEDURE IncorrectDigit;

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

END PACKAGE BODY lock_functions;