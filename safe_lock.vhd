LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY safe_lock IS
    PORT (
        clk : IN STD_LOGIC; -- Clock signal
        rst : IN STD_LOGIC; -- Reset signal
        d : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- Input for the combination lock
        correct : OUT STD_LOGIC; -- Output indicating if the combination is correct
        done : OUT STD_LOGIC; -- Output indicating if the combination has been entered
        seg_min : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- Output for the minutes on the seven segment display
        seg_sec : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- Output for the seconds on the seven segment display
    );
END safe_lock;

ARCHITECTURE comb_lock OF safe_lock IS
    TYPE state_type IS (start, digit1, digit2, digit3, unlocked, waitTimer); -- Define states for the combination lock
    SIGNAL state : state_type := start; -- State of the combination lock

    TYPE int_array IS ARRAY(0 TO 3) OF INTEGER;
    SIGNAL correctCombination : int_array := (4, 2, 3, 5);
    SIGNAL digitLength : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL correctD1, correctD2, correctD3, correctD4 : STD_LOGIC_VECTOR(3 DOWNTO 0);

    --    SIGNAL combination : STD_LOGIC_VECTOR(3 DOWNTO 0); -- Correct combination

    SIGNAL counter : INTEGER RANGE 0 TO 300000 := 0; -- 5-minute counters

    -- password encrypter component
    COMPONENT password_decrypter
        PORT (
            encrypted_password : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            decrypted_password : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;

    -- password encrypter component instance
    SIGNAL encrypted_password : STD_LOGIC_VECTOR (11 DOWNTO 0) := "111000100101";
    SIGNAL decrypted_password : STD_LOGIC_VECTOR (11 DOWNTO 0);
BEGIN
    P1 : password_decrypter PORT MAP(encrypted_password => encrypted_password, decrypted_password => decrypted_password);
    correctD1 <= STD_LOGIC_VECTOR(to_unsigned(correctCombination(0), digitLength'length));
    correctD2 <= STD_LOGIC_VECTOR(to_unsigned(correctCombination(1), digitLength'length));
    correctD3 <= STD_LOGIC_VECTOR(to_unsigned(correctCombination(2), digitLength'length));
    correctD4 <= STD_LOGIC_VECTOR(to_unsigned(correctCombination(3), digitLength'length));

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            state <= start; -- Reset the state to start
            counter <= 0; -- Reset the counter to 0
            seg_min <= "0000"; -- Clear the minutes on the seven segment display
            seg_sec <= "0000"; -- Clear the seconds on the seven segment display
        ELSIF rising_edge(clk) THEN
            CASE state IS
                WHEN start =>
                    IF counter = 0 THEN -- If the delay has expired
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000"; -- Clear the seconds on the seven segment display
                        IF d = correctD1 THEN -- First digit of combination
                            state <= digit1;
                        ELSE
                            state <= waitTimer; -- Incorrect first digit, go to wait state
                            counter <= 30000; -- Set the counter to 5 minutes
                            seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                            seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
                        END IF;
                    END IF;
                WHEN digit1 =>
                    IF d = correctD2 THEN -- Second digit of combination
                        state <= digit2;
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000";
                    ELSE
                        state <= waitTimer; -- Incorrect second digit, go to wait state
                        counter <= 30000; -- Set the counter to 5 minutes
                        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
                    END IF;
                WHEN digit2 =>
                    IF d = correctD3 THEN -- Third digit of combination
                        state <= digit3;
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000"; -- Clear the seconds on the seven segment display
                    ELSE
                        state <= waitTimer; -- Incorrect third digit, go to wait state
                        counter <= 30000; -- Set the counter to 5 minutes
                        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
                    END IF;
                WHEN digit3 =>
                    IF d = correctD4 THEN -- Fourth digit of combination
                        state <= unlocked;
                        correct <= '1'; -- Correct combination has been entered
                        done <= '1'; -- Combination has been entered
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000"; -- Clear the seconds on the seven segment display
                    ELSE
                        state <= waitTimer; -- Incorrect fourth digit, go to wait state
                        counter <= 30000; -- Set the counter to 5 minutes
                        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
                    END IF;

                WHEN waitTimer =>
                    IF counter = 0 THEN -- If the delay has expired
                        state <= start; -- Go back to start state
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000"; -- Clear the seconds on the seven segment display
                    ELSE
                        counter <= counter - 1; -- Decrement the counter
                        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4));

                    END IF;
                WHEN unlocked =>

            END CASE;
        END IF;
    END PROCESS;
END comb_lock;