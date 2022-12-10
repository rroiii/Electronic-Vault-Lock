LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.lock_constant.ALL;
USE work.lock_types.ALL;
USE work.lock_functions.ALL;

ENTITY safe_lock IS
    PORT (
        clk_lamp : IN STD_LOGIC;
        clk : IN STD_LOGIC; -- Clock signal
        rst : IN STD_LOGIC := '0'; -- Reset signal
        d : IN STD_LOGIC_VECTOR(0 TO 3); -- Input for the combination lock
        btn_lock : IN STD_LOGIC := '0'; -- Button to lock the safe
        btn_set : IN STD_LOGIC := '0'; -- Button to set new password for the combination lock
        correct : OUT STD_LOGIC := '0'; -- Output indicating if the combination is correct (Default is 0)

        -- 00 = OFF, RED = 01, GREEN = 10
        lamp_digit1, lamp_digit2, lamp_digit3, lamp_digit4 : INOUT STD_LOGIC_VECTOR (1 DOWNTO 0) := "00"; -- Output lamp for each digit 

        Seven_Segment_digit1 : INOUT STD_LOGIC_VECTOR (6 DOWNTO 0) := "1111111"; -- Output for digit 1 on the seven segment display
        Seven_Segment_digit2 : INOUT STD_LOGIC_VECTOR (6 DOWNTO 0) := "1111111"; -- Output for digit 2 on the seven segment display
        Seven_Segment_digit3 : INOUT STD_LOGIC_VECTOR (6 DOWNTO 0) := "1111111"; -- Output for digit 3 on the seven segment display
        Seven_Segment_digit4 : INOUT STD_LOGIC_VECTOR (6 DOWNTO 0) := "1111111"; -- Output for digit 4 on the seven segment display

        Seven_Segment_Seconds1 : INOUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for the first digit seconds on the seven segment display
        Seven_Segment_Seconds2 : INOUT STD_LOGIC_VECTOR (6 DOWNTO 0); -- Output for the second digit seconds on the seven segment display
        Seven_Segment_Minutes : INOUT STD_LOGIC_VECTOR (6 DOWNTO 0) -- Output for the minutes on the seven segment display
    );
END safe_lock;

ARCHITECTURE comb_lock OF safe_lock IS
    SIGNAL temp : STD_LOGIC_VECTOR(0 TO 15); -- Temporary Signal for encryption usages
    SIGNAL state : state_digit := start; -- State of the combination lock digit
    SIGNAL nextState : state_digit := digit1; -- Next State
    SIGNAL state_lock : state_lock := unlocking; -- State whether the user is unlocking the lock or setting a new password digit
    SIGNAL KEY : STD_LOGIC_VECTOR(15 DOWNTO 0) := "1010101010101010"; -- Key for the encryption and decryption password
    SIGNAL correctCombination : int_array := (4, 2, 3, 5); -- Correct combination
    SIGNAL correctCombinationBinary : STD_LOGIC_VECTOR(0 TO 15) := "0100001000110101"; -- Correct combination in binary

    SIGNAL counter : INTEGER RANGE 0 TO 300 := inputWaitTime; -- 5-minute counters, Default value is 5 seconds

    -- password encrypter component
    COMPONENT password_decrypter
        PORT (
            KEY : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            encrypted_password : IN STD_LOGIC_VECTOR (0 TO 15);
            decrypted_password : OUT STD_LOGIC_VECTOR(0 TO 15)
        );
    END COMPONENT;

    -- password encrypter component instance
    SIGNAL encrypted_password : STD_LOGIC_VECTOR (0 TO 15) := "1110100010011111";
    SIGNAL decrypted_password : STD_LOGIC_VECTOR (0 TO 15) := "0000000000000000";

    SIGNAL seg_min : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL seg_sec1 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0000";
    SIGNAL seg_sec2 : STD_LOGIC_VECTOR(3 DOWNTO 0) := "0101"; -- 5 seconds display by default

BEGIN
    P1 : password_decrypter PORT MAP(KEY => KEY, encrypted_password => encrypted_password, decrypted_password => correctCombinationBinary);

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            state <= start; -- Reset the state to start
            nextState <= digit1; -- Reset the next state to digit1
            state_lock <= unlocking; -- Reset state to unlocking
            correct <= '0'; -- Reset correct to '0'
            SetCounter(inputWaitTime, counter, seg_min, seg_sec1, seg_sec2); -- Reset the counter to inputWaitTime
            ELSIF rising_edge(clk) THEN
            CASE state IS
                WHEN start =>
                    -- Set All LED lights to RED (01)
                    IF rising_edge(clk_lamp) THEN
                        lamp_digit1 <= "01";
                        lamp_digit2 <= "01";
                        lamp_digit3 <= "01";
                        lamp_digit4 <= "01";
                    END IF;
                    -- Set All LED lights to OFF (00)
                    IF falling_edge(clk_lamp) THEN
                        lamp_digit1 <= "00";
                        lamp_digit2 <= "00";
                        lamp_digit3 <= "00";
                        lamp_digit4 <= "00";
                    END IF;

                    InputDigit(counter, seg_min, seg_sec1, seg_sec2, state, nextState, state_lock, digit2_STATE,
                    d, correctCombinationBinary(0 TO 3), correct, Seven_Segment_digit1, lamp_digit1);
                WHEN digit1 =>
                    InputDigit(counter, seg_min, seg_sec1, seg_sec2, state, nextState, state_lock, digit3_STATE,
                    d, correctCombinationBinary(4 TO 7), correct, Seven_Segment_digit2, lamp_digit2);

                WHEN digit2 =>
                    InputDigit(counter, seg_min, seg_sec1, seg_sec2, state, nextState, state_lock, unlocked_STATE,
                    d, correctCombinationBinary(8 TO 11), correct, Seven_Segment_digit3, lamp_digit3);

                WHEN digit3 =>
                    InputDigit(counter, seg_min, seg_sec1, seg_sec2, state, nextState, state_lock, digit1_STATE,
                    d, correctCombinationBinary(12 TO 15), correct, Seven_Segment_digit4, lamp_digit4);

                WHEN waitTimer => -- State when to wait for 30 seconds and go back to start state
                    IF counter = 0 THEN -- If the delay has expired
                        state <= start;
                        nextState <= digit1;
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec1 <= "0000"; -- Clear the seconds on the seven segment display
                        seg_sec2 <= "0000"; -- Clear the seconds on the seven segment display
                    ELSE
                        DecrementCounter(counter, seg_min, seg_sec1, seg_sec2);
                    END IF;

                WHEN unlocked => -- When the safe is unlocked, you are given 2 buttons, either lock back the safe 
                    -- or set a new combination digit password . You are given 5 seconds until the safe gets back to being locked again
                    -- Set All LED lights to GREEN (10)
                    IF rising_edge(clk_lamp) THEN
                        lamp_digit1 <= "10";
                        lamp_digit2 <= "10";
                        lamp_digit3 <= "10";
                        lamp_digit4 <= "10";
                    END IF;
                    -- SET All LED lights to OFF (00)
                    IF falling_edge(clk_lamp) THEN
                        lamp_digit1 <= "00";
                        lamp_digit2 <= "00";
                        lamp_digit3 <= "00";
                        lamp_digit4 <= "00";
                    END IF;

                    -- If state was setting new lock, Set the new password to the signal correctCombination
                    -- And encrypt password
                    IF (state_lock = setNewLock) THEN
                        --Encrypt password
                        EncryptPassword(temp, KEY, correctCombinationBinary, encrypted_password);
                        -- Convert the new password to integer (for easier reading)
                        correctCombination(0) <= to_integer(unsigned(correctCombinationBinary(0 TO 3)));
                        correctCombination(1) <= to_integer(unsigned(correctCombinationBinary(4 TO 7)));
                        correctCombination(2) <= to_integer(unsigned(correctCombinationBinary(8 TO 11)));
                        correctCombination(3) <= to_integer(unsigned(correctCombinationBinary(12 TO 15)));
                    END IF;

                    -- When pressed, lock the safe or when the counter hits 0
                    IF (btn_lock = '1' OR counter = 0) THEN
                        state <= start;
                        nextState <= digit1;
                        state_lock <= unlocking;
                        SetCounter(inputWaitTime, counter, seg_min, seg_sec1, seg_sec2);
                        correct <= '0';

                        -- When pressed, set a new digit combination password     
                    ELSIF (btn_set = '1') THEN
                        state <= start;
                        nextState <= digit1;
                        state_lock <= setNewLock;
                        SetCounter(inputSetLockTime, counter, seg_min, seg_sec1, seg_sec2);
                        correct <= '0';
                    ELSE
                        DecrementCounter(counter, seg_min, seg_sec1, seg_sec2);
                    END IF;
            END CASE;
        END IF;
    END PROCESS;

    --Seven segment display for minutes
    PROCESS (seg_min, Seven_Segment_Minutes)
    BEGIN
        Display_number_seven_segment(seg_min, Seven_Segment_Minutes);
    END PROCESS;

    --Seven segment display for first digit of seconds, ex = 0x, 1x, 2x
    PROCESS (seg_sec1, Seven_Segment_Seconds1)
    BEGIN
        Display_number_seven_segment(seg_sec1, Seven_Segment_Seconds1);
    END PROCESS;

    --Seven segment display for second digit of seconds, ex = x1, x2, x3
    PROCESS (seg_sec2, Seven_Segment_Seconds2)
    BEGIN
        Display_number_seven_segment(seg_sec2, Seven_Segment_Seconds2);
    END PROCESS;

END comb_lock;