LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.lock_constant.ALL;
USE work.lock_types.ALL;
USE work.lock_functions.ALL;

ENTITY safe_lock IS
    PORT (
        clk : IN STD_LOGIC; -- Clock signal
        rst : IN STD_LOGIC := '0'; -- Reset signal
        d : IN STD_LOGIC_VECTOR(0 TO 3); -- Input for the combination lock
        btn_lock : IN STD_LOGIC := '0'; -- Button to lock the safe
        btn_set : IN STD_LOGIC := '0'; -- Button to set new password for the combination lock
        correct : OUT STD_LOGIC; -- Output indicating if the combination is correct
        Seven_Segment_Seconds1 : inout STD_LOGIC_VECTOR (6 downto 0); -- Output for the minutes on the seven segment display
        Seven_Segment_Seconds2 : inout STD_LOGIC_VECTOR (6 downto 0); -- Output for the first digit seconds on the seven segment display
        Seven_Segment_Minutes : inout STD_LOGIC_VECTOR (6 downto 0) -- Output for the second digit seconds on the seven segment display
    );
END safe_lock;

ARCHITECTURE comb_lock OF safe_lock IS
    SIGNAL state : state_digit := start; -- State of the combination lock digit
    SIGNAL nextState : state_digit := digit1; -- Next State
    SIGNAL state_lock : state_lock := unlocking; -- State whether the user is unlocking the lock or setting a new password digit

    SIGNAL correctCombination : int_array := (4, 2, 3, 5); -- Correct combination
    SIGNAL correctCombinationBinary : STD_LOGIC_VECTOR(0 TO 15) := "0100001000110101"; -- Correct combination in binary

    SIGNAL counter : INTEGER RANGE 0 TO 300; -- 5-minute counters, Default value is 5000 ms for 5 seconds

    -- password encrypter component
    COMPONENT password_decrypter
        PORT (
            encrypted_password : IN STD_LOGIC_VECTOR (0 TO 15);
            decrypted_password : OUT STD_LOGIC_VECTOR(0 TO 15)
        );
    END COMPONENT;
    -- password encrypter component instance
    SIGNAL encrypted_password : STD_LOGIC_VECTOR (0 TO 15);
    SIGNAL decrypted_password : STD_LOGIC_VECTOR (0 TO 15);

    SIGNAL seg_min : STD_LOGIC_VECTOR(3 DOWNTO 0); 
    SIGNAL seg_sec1 : STD_LOGIC_VECTOR(3 DOWNTO 0); 
    SIGNAL seg_sec2 : STD_LOGIC_VECTOR(3 DOWNTO 0); 
BEGIN
    P1 : password_decrypter PORT MAP(encrypted_password => encrypted_password, decrypted_password => decrypted_password);
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            state <= start; -- Reset the state to start
            counter <= inputWaitTime; -- Reset the counter to inputWaitTime
            seg_min <= "0000"; -- Clear the minutes on the seven segment display
            seg_sec1 <= "0000"; -- Clear the seconds on the seven segment display
            seg_sec2 <= "0000"; -- Clear the seconds on the seven segment display
        ELSIF rising_edge(clk) THEN
            CASE state IS
                WHEN start =>
                    seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 60, 4)); -- Calculate and display the minutes on the seven segment display
                    seg_sec1 <= STD_LOGIC_VECTOR(to_unsigned((counter MOD 60)/10, 4)); -- Calculate and display the seconds on the seven segment display
                    seg_sec2 <= STD_LOGIC_VECTOR(to_unsigned((counter MOD 60) - (((counter MOD 60) / 10) * 10), 4)); -- Calculate and display the seconds on the seven segment display
                    
                    InputDigit(counter, seg_min, seg_sec1, seg_sec2, state, nextState, state_lock, digit2_STATE,
                    d, correctCombinationBinary(0 TO 3), correct);

                WHEN digit1 =>
                    InputDigit(counter, seg_min, seg_sec1, seg_sec2, state, nextState, state_lock, digit3_STATE,
                    d, correctCombinationBinary(4 TO 7), correct);

                WHEN digit2 =>
                    InputDigit(counter, seg_min, seg_sec1, seg_sec2, state, nextState, state_lock, unlocked_STATE,
                    d, correctCombinationBinary(8 TO 11), correct);

                WHEN digit3 =>
                    InputDigit(counter, seg_min, seg_sec1, seg_sec2, state, nextState, state_lock, digit1_STATE,
                    d, correctCombinationBinary(12 TO 15), correct);

                WHEN waitTimer =>       -- State when to wait for 30 seconds and go back to start state
                    IF counter = 0 THEN -- If the delay has expired
                        state <= start;
                        nextState <= digit1;
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec1 <= "0000"; -- Clear the seconds on the seven segment display
                        seg_sec2 <= "0000"; -- Clear the seconds on the seven segment display
                    ELSE
                        DecrementCounter(counter, seg_min, seg_sec1, seg_sec2);
                    END IF;

                WHEN unlocked => 
                    -- When the safe is unlocked, you are given 2 buttons, either lock back the safe 
                    -- or set a new combination digit password . You are given 5 seconds until the safe gets back to being locked again

                    IF (state_lock = setNewLock) THEN 
                        -- Convert the new password to integer (for easier reading)
                        correctCombination(0) <= to_integer(unsigned(correctCombinationBinary(0 TO 3)));
                        correctCombination(1) <= to_integer(unsigned(correctCombinationBinary(4 TO 7)));
                        correctCombination(2) <= to_integer(unsigned(correctCombinationBinary(8 TO 11)));
                        correctCombination(3) <= to_integer(unsigned(correctCombinationBinary(12 TO 15)));
                    END IF;

                    IF (btn_lock = '1' OR counter = 0) THEN 
                        -- When pressed, lock the safe or when the counter hits 0
                        state <= start;
                        nextState <= digit1;
                        state_lock <= unlocking;
                        counter <= inputWaitTime;
                        correct <= '0';

                    ELSIF (btn_set = '1') THEN 
                        -- When pressed, set a new digit combination password 
                        state <= start;
                        nextState <= digit1;
                        state_lock <= setNewLock;
                        counter <= inputSetLockTime;
                        correct <= '0';
                    ELSE
                        DecrementCounter(counter, seg_min, seg_sec1, seg_sec2);
                    END IF;
            END CASE;
        END IF;
    END PROCESS;

    PROCESS(seg_min, Seven_Segment_Minutes)
    BEGIN
        case seg_min is
            when "0000" => --0
                Seven_Segment_Minutes <= "0000001";
            when "0001" => --1
                Seven_Segment_Minutes <= "1001111"; 
            when "0010" => --2
                Seven_Segment_Minutes <= "0010010"; 
            when "0011" => --3
                Seven_Segment_Minutes <= "0000110"; 
            when "0100" => --4
                Seven_Segment_Minutes <= "1001100"; 
            when "0101" => --5
                Seven_Segment_Minutes <= "0100100"; 
            when "0110" => --6
                Seven_Segment_Minutes <= "0100000"; 
            when "0111" => --7
                Seven_Segment_Minutes <= "0001111";
            when "1000" => --8
                Seven_Segment_Minutes <= "0000000"; 
            when "1001" =>
                Seven_Segment_Minutes <= "0000100"; 
            when others =>
                Seven_Segment_Minutes <= "1111111";
        end case;
    END PROCESS;
    
    PROCESS(seg_sec1, Seven_Segment_Seconds1)
    BEGIN
        case seg_sec1 is
            when "0000" => --0
                Seven_Segment_Seconds1 <= "0000001";
            when "0001" => --1
                Seven_Segment_Seconds1 <= "1001111"; 
            when "0010" => --2
                Seven_Segment_Seconds1 <= "0010010"; 
            when "0011" => --3
                Seven_Segment_Seconds1 <= "0000110"; 
            when "0100" => --4
                Seven_Segment_Seconds1 <= "1001100"; 
            when "0101" => --5
                Seven_Segment_Seconds1 <= "0100100"; 
            when "0110" => --6
                Seven_Segment_Seconds1 <= "0100000"; 
            when "0111" => --7
                Seven_Segment_Seconds1 <= "0001111";
            when "1000" => --8
                Seven_Segment_Seconds1 <= "0000000"; 
            when "1001" =>
                Seven_Segment_Seconds1 <= "0000100"; 
            when others =>
                Seven_Segment_Seconds1 <= "1111111";
        end case;
    END PROCESS;

    PROCESS(seg_sec2, Seven_Segment_Seconds2)
    BEGIN
        case seg_sec2 is
            when "0000" => --0
                Seven_Segment_Seconds2 <= "0000001";
            when "0001" => --1
                Seven_Segment_Seconds2 <= "1001111"; 
            when "0010" => --2
                Seven_Segment_Seconds2 <= "0010010"; 
            when "0011" => --3
                Seven_Segment_Seconds2 <= "0000110"; 
            when "0100" => --4
                Seven_Segment_Seconds2 <= "1001100"; 
            when "0101" => --5
                Seven_Segment_Seconds2 <= "0100100"; 
            when "0110" => --6
                Seven_Segment_Seconds2 <= "0100000"; 
            when "0111" => --7
                Seven_Segment_Seconds2 <= "0001111";
            when "1000" => --8
                Seven_Segment_Seconds2 <= "0000000"; 
            when "1001" =>
                Seven_Segment_Seconds2 <= "0000100"; 
            when others =>
                Seven_Segment_Seconds2 <= "1111111";
        end case;
    END PROCESS;

    --PROCESS(seg_min, Seven_Segment_Minutes)
    --BEGIN
    --    Display_time_seven_segment(seg_min, Seven_Segment_Minutes);
    --END PROCESS;

    --PROCESS(seg_sec1, Seven_Segment_Seconds1)
    --BEGIN
    --    Display_time_seven_segment(seg_sec1, Seven_Segment_Seconds1);
    --END PROCESS;

    --PROCESS(seg_sec2, Seven_Segment_Seconds2)
    --BEGIN
    --    Display_time_seven_segment(seg_sec2, Seven_Segment_Seconds2);
    --END PROCESS;
    

END comb_lock;