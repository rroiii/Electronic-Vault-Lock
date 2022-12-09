LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.lock_constant.ALL;
USE work.lock_types.ALL;

PACKAGE lock_functions IS
    PROCEDURE InputDigit(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL state : OUT state_digit;
        SIGNAL nextState : INOUT state_digit;
        SIGNAL state_lock : IN state_lock;
        setState : IN state_digit;
        d : IN STD_LOGIC_VECTOR(0 TO 3);
        SIGNAL correctDigitBinary : INOUT STD_LOGIC_VECTOR(0 TO 3);
        SIGNAL correct : OUT STD_LOGIC;
        SIGNAL seven_segment_digit : INOUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );

    PROCEDURE IncorrectDigit(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL state : OUT state_digit
    );

    PROCEDURE DecrementCounter(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );

    PROCEDURE Display_number_seven_segment(
        SIGNAL digit_value : INOUT STD_LOGIC_VECTOR(0 TO 3);
        SIGNAL seven_segment : INOUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );

END PACKAGE lock_functions;

PACKAGE BODY lock_functions IS

    -- To Check digit if the input is the correct combination or setting a new digit combination password
    PROCEDURE InputDigit(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL state : OUT state_digit;
        SIGNAL nextState : INOUT state_digit;
        SIGNAL state_lock : IN state_lock;
        setState : IN state_digit;
        d : IN STD_LOGIC_VECTOR(0 TO 3);
        SIGNAL correctDigitBinary : INOUT STD_LOGIC_VECTOR(0 TO 3);
        SIGNAL correct : OUT STD_LOGIC;
        SIGNAL seven_segment_digit : INOUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    ) IS
    BEGIN
        CASE state_lock IS
            WHEN unlocking =>
                IF d = correctDigitBinary(0 TO 3) THEN -- Check if the digit match the password digit
                    state <= nextState;
                    nextState <= setState;
                    counter <= inputWaitTime;
                    Display_number_seven_segment(correctDigitBinary(0 TO 3), seven_segment_digit);
                    IF (nextState = unlocked) THEN
                        correct <= '1';
                    END IF;
                ELSIF (counter = 0) THEN
                    IncorrectDigit(counter, seg_min, seg_sec1, seg_sec2, state);
                ELSE
                    DecrementCounter(counter, seg_min, seg_sec1, seg_sec2);
                END IF;
            WHEN setNewLock =>
                IF (counter = 0) THEN
                    state <= nextState;
                    nextState <= setState;
                    counter <= inputSetLockTime;
                    correctDigitBinary <= d; -- Set the new digit password
                ELSE
                    DecrementCounter(counter, seg_min, seg_sec1, seg_sec2);
                END IF;
        END CASE;

    END PROCEDURE InputDigit;

    -- The Entered Input is Incorrect, so set the state to waitTimer to wait for 30 seconds
    -- When its finish, start again from state start (code can be seen in safe_lock code)
    PROCEDURE IncorrectDigit(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL state : OUT state_digit
    ) IS
    BEGIN
        state <= waitTimer; -- Incorrect  digit, go to wait state
        counter <= lockWaitTime; -- Set the counter to lockWaitTime
        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 60, 4)); -- Calculate and display the minutes on the seven segment display
        seg_sec1 <= STD_LOGIC_VECTOR(to_unsigned((counter MOD 60)/10, 4)); -- Calculate and display the seconds on the seven segment display
        seg_sec2 <= STD_LOGIC_VECTOR(to_unsigned((counter MOD 60) - (((counter MOD 60) / 10) * 10), 4)); -- Calculate and display the seconds on the seven segment displa
    END PROCEDURE IncorrectDigit;

    -- Decrement the counter by 1 in miliseconds
    PROCEDURE DecrementCounter(
        SIGNAL counter : INOUT INTEGER RANGE 0 TO 300;
        SIGNAL seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        SIGNAL seg_sec2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    ) IS
    BEGIN
        counter <= counter - 1; -- Decrement the counter
        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 60, 4)); -- Calculate and display the minutes on the seven segment display
        seg_sec1 <= STD_LOGIC_VECTOR(to_unsigned((counter MOD 60)/10, 4)); -- Calculate and display the seconds on the seven segment display
        seg_sec2 <= STD_LOGIC_VECTOR(to_unsigned((counter MOD 60) - (((counter MOD 60) / 10) * 10), 4)); -- Calculate and display the seconds on the seven segment displa
    END PROCEDURE DecrementCounter;
    
    PROCEDURE Display_number_seven_segment(
        SIGNAL digit_value : INOUT STD_LOGIC_VECTOR(0 TO 3);
        SIGNAL seven_segment : INOUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    ) IS
    BEGIN
        case digit_value is
            when "0000" => --0
                seven_segment <= "0000001";
            when "0001" => --1
                seven_segment <= "1001111"; 
            when "0010" => --2
                seven_segment <= "0010010"; 
            when "0011" => --3
                seven_segment <= "0000110"; 
            when "0100" => --4
                seven_segment <= "1001100"; 
            when "0101" => --5
                seven_segment <= "0100100"; 
            when "0110" => --6
                seven_segment <= "0100000"; 
            when "0111" => --7
                seven_segment <= "0001111";
            when "1000" => --8
                seven_segment <= "0000000"; 
            when "1001" =>
                seven_segment <= "0000100"; 
            when others =>
                seven_segment <= "1111111";
        end case;
    END PROCEDURE Display_number_seven_segment;

END PACKAGE BODY lock_functions;