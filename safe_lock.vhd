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
    TYPE state_type IS (start, digit1, digit2, digit3, digit4, unlocked, waitTimer); -- Define states for the combination lock
    SIGNAL state : state_type; -- State of the combination lock
    SIGNAL combination : STD_LOGIC_VECTOR(3 DOWNTO 0); -- Correct combination
    SIGNAL counter : INTEGER RANGE 0 TO 300000; -- 5-minute counters

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

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            state <= start; -- Reset the state to start
            combination <= "0000"; -- Set the combination to 0000
            counter <= 0; -- Reset the counter to 0
            seg_min <= "0000"; -- Clear the minutes on the seven segment display
            seg_sec <= "0000"; -- Clear the seconds on the seven segment display
        ELSIF rising_edge(clk) THEN
            CASE state IS
                WHEN start =>
                    IF counter = 0 THEN -- If the delay has expired
                        IF d = "0000" THEN -- First digit of combination
                            state <= digit1;
                            combination <= "0XXX"; -- Set next digit to ?
                            seg_min <= "0000"; -- Clear the minutes on the seven segment display
                            seg_sec <= "0000"; -- Clear the seconds on the seven segment display
                        ELSE
                            state <= start; -- Incorrect first digit, reset to start state
                        END IF;
                    ELSE
                        counter <= counter - 1; -- Decrement the counter
                        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
                    END IF;
                WHEN digit1 =>
                    IF d = "0XXX" THEN -- Second digit of combination
                        state <= digit2;
                        combination <= "0XX0"; -- Set next digit to 0
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000";
                        state <= waitTimer; -- Incorrect second digit, go to wait state
                        counter <= 300000; -- Set the counter to 5 minutes
                        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
                    END IF;
                WHEN digit2 =>
                    IF d = "0XX0" THEN -- Third digit of combination
                        state <= digit3;
                        combination <= "0X00"; -- Set next digit to 0
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000"; -- Clear the seconds on the seven segment display
                    ELSE
                        state <= waitTimer; -- Incorrect third digit, go to wait state
                        counter <= 300000; -- Set the counter to 5 minutes
                        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
                    END IF;
                WHEN digit3 =>
                    IF d = "0X00" THEN -- Fourth digit of combination
                        state <= digit4;
                        correct <= '1'; -- Correct combination has been entered
                        done <= '1'; -- Combination has been entered
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000"; -- Clear the seconds on the seven segment display
                    ELSE
                        state <= waitTimer; -- Incorrect fourth digit, go to wait state
                        counter <= 300000; -- Set the counter to 5 minutes
                        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
                    END IF;
                WHEN digit4 =>
                    IF d /= "0X00" THEN -- If the combination is not entered again
                        state <= waitTimer; -- Go to wait state
                        counter <= 300000; -- Set the counter to 5 minutes
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
                        state <= unlocked; -- Unlock the combination lock
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000"; -- Clear the seconds on the seven segment display
                    END IF;
                WHEN unlocked =>
                    IF d /= "0X00" THEN -- If the combination is not entered again
                        state <= start; -- Reset to start state
                        correct <= '0'; -- Incorrect combination
                        done <= '0'; -- Combination has not been entered
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000"; -- Clear the seconds on the seven segment display
                    END IF;
            END CASE;
        END IF;
    END PROCESS;
END comb_lock;