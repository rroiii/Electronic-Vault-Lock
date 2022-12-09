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
        btn_lock : IN STD_LOGIC := '0';
        btn_set : IN STD_LOGIC := '0';
        correct : OUT STD_LOGIC; -- Output indicating if the combination is correct
        seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Output for the minutes on the seven segment display
        seg_sec : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- Output for the seconds on the seven segment display
    );
END safe_lock;

ARCHITECTURE comb_lock OF safe_lock IS
    SIGNAL state : state_digit := start; -- State of the combination lock
    SIGNAL nextState : state_digit := digit1;
    SIGNAL state_lock : state_lock := unlocking;

    SIGNAL correctCombination : int_array := (4, 2, 3, 5); -- Correct combination
    SIGNAL correctCombinationBinary : STD_LOGIC_VECTOR(0 TO 15);

    -- 5-minute counters, Default value is 5000 for 5 seconds
    SIGNAL counter : INTEGER RANGE 0 TO 300000 := 5000;

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
BEGIN
    P1 : password_decrypter PORT MAP(encrypted_password => encrypted_password, decrypted_password => decrypted_password);

    correctCombinationBinary(0 TO 3) <= STD_LOGIC_VECTOR(to_unsigned(correctCombination(0), 4));
    correctCombinationBinary(4 TO 7) <= STD_LOGIC_VECTOR(to_unsigned(correctCombination(1), 4));
    correctCombinationBinary(8 TO 11) <= STD_LOGIC_VECTOR(to_unsigned(correctCombination(2), 4));
    correctCombinationBinary(12 TO 15) <= STD_LOGIC_VECTOR(to_unsigned(correctCombination(3), 4));

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            state <= start; -- Reset the state to start
            counter <= inputWaitTime; -- Reset the counter to 0
            seg_min <= "0000"; -- Clear the minutes on the seven segment display
            seg_sec <= "0000"; -- Clear the seconds on the seven segment display
        ELSIF rising_edge(clk) THEN
            CASE state IS
                WHEN start =>
                    seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                    seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
                    CheckDigit(counter, seg_min, seg_sec, state, nextState, digit1_STATE, d,
                    correctCombinationBinary(0 TO 3), correct);

                WHEN digit1 =>
                    CheckDigit(counter, seg_min, seg_sec, state, nextState, digit2_STATE, d,
                    correctCombinationBinary(4 TO 7), correct);

                WHEN digit2 =>

                    CheckDigit(counter, seg_min, seg_sec, state, nextState, digit3_STATE, d,
                    correctCombinationBinary(8 TO 11), correct);

                WHEN digit3 =>
                    CheckDigit(counter, seg_min, seg_sec, state, nextState, unlocked_STATE, d,
                    correctCombinationBinary(12 TO 15), correct);

                WHEN waitTimer => -- State when to wait for 30 seconds and go back to start state
                    IF counter = 0 THEN -- If the delay has expired
                        state <= start;
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000"; -- Clear the seconds on the seven segment display
                    ELSE
                        DecrementCounter(counter, seg_min, seg_sec);
                    END IF;

                WHEN unlocked => -- When the safe is unlocked, you are given 2 buttons, either lock back the safe 
                    -- or set a new combination digit password . You are given 5 seconds until the safe gets back to being locked again
                    IF (btn_lock = '1' OR counter = 0) THEN -- When pressed, lock the safe
                        state <= start;
                        nextState <= digit1;
                        state_lock <= unlocking;
                        counter <= inputWaitTime;
                    ELSIF (btn_set = '1') THEN -- When pressed, set a new combination digit password 
                        state <= start;
                        nextState <= digit1;
                        state_lock <= setNewLock;
                        counter <= inputWaitTime;
                    ELSE
                        DecrementCounter(counter, seg_min, seg_sec);
                    END IF;

            END CASE;
        END IF;
    END PROCESS;
END comb_lock;