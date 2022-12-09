LIBRARY ieee;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.lock_types.ALL;
USE work.lock_functions.ALL;

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
    SIGNAL state : state_type := start; -- State of the combination lock

    SIGNAL correctCombination : int_array := (4, 2, 3, 5); -- Correct combination
    SIGNAL correctCombinationBiner : STD_LOGIC_VECTOR(15 DOWNTO 0);

    SIGNAL counter : INTEGER RANGE 0 TO 300000 := 0; -- 5-minute counters

    -- password encrypter component
    COMPONENT password_decrypter
        PORT (
            encrypted_password : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            decrypted_password : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    -- password encrypter component instance
    SIGNAL encrypted_password : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL decrypted_password : STD_LOGIC_VECTOR (15 DOWNTO 0);
BEGIN
    P1 : password_decrypter PORT MAP(encrypted_password => encrypted_password, decrypted_password => decrypted_password);

    correctCombinationBiner(3 DOWNTO 0) <= STD_LOGIC_VECTOR(to_unsigned(correctCombination(0), 4));
    correctCombinationBiner(7 DOWNTO 4) <= STD_LOGIC_VECTOR(to_unsigned(correctCombination(1), 4));
    correctCombinationBiner(11 DOWNTO 8) <= STD_LOGIC_VECTOR(to_unsigned(correctCombination(2), 4));
    correctCombinationBiner(15 DOWNTO 12) <= STD_LOGIC_VECTOR(to_unsigned(correctCombination(3), 4));

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
                        IF d = correctCombinationBiner(3 DOWNTO 0) THEN -- First digit of combination
                            state <= digit1;
                            counter <= 5000;
                        ELSE
                            state <= waitTimer; -- Incorrect first digit, go to wait state
                            counter <= 30000; -- Set the counter to 5 minutes
                            seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                            seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
                        END IF;
                    END IF;
                WHEN digit1 =>
                    IF d = correctCombinationBiner(7 DOWNTO 4) THEN -- Second digit of combination
                        state <= digit2;
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000";
                        counter <= 5000;
                    ELSIF (counter = 0) THEN
                        state <= waitTimer; -- Incorrect second digit, go to wait state
                        counter <= 30000; -- Set the counter to 5 minutes
                        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
                    ELSE
                        waitCounter(counter, seg_min, seg_sec);
                    END IF;
                WHEN digit2 =>
                    IF d = correctCombinationBiner(11 DOWNTO 8) THEN -- Third digit of combination
                        state <= digit3;
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000"; -- Clear the seconds on the seven segment display
                        counter <= 5000;
                    ELSIF (counter = 0) THEN
                        state <= waitTimer; -- Incorrect third digit, go to wait state
                        counter <= 30000; -- Set the counter to 5 minutes
                        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
                    ELSE
                        waitCounter(counter, seg_min, seg_sec);
                    END IF;
                WHEN digit3 =>
                    IF d = correctCombinationBiner(15 DOWNTO 12) THEN -- Fourth digit of combination
                        state <= unlocked;
                        correct <= '1'; -- Correct combination has been entered
                        done <= '1'; -- Combination has been entered
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000"; -- Clear the seconds on the seven segment display
                    ELSIF (counter = 0) THEN
                        state <= waitTimer; -- Incorrect fourth digit, go to wait state
                        counter <= 30000; -- Set the counter to 5 minutes
                        seg_min <= STD_LOGIC_VECTOR(to_unsigned(counter / 6000, 4)); -- Calculate and display the minutes on the seven segment display
                        seg_sec <= STD_LOGIC_VECTOR(to_unsigned(counter MOD 6000, 4)); -- Calculate and display the seconds on the seven segment display
                    ELSE
                        waitCounter(counter, seg_min, seg_sec);
                    END IF;

                WHEN waitTimer =>
                    IF counter = 0 THEN -- If the delay has expired
                        state <= start;
                        seg_min <= "0000"; -- Clear the minutes on the seven segment display
                        seg_sec <= "0000"; -- Clear the seconds on the seven segment display
                    ELSE
                        waitCounter(counter, seg_min, seg_sec);
                    END IF;
                WHEN unlocked =>

            END CASE;
        END IF;
    END PROCESS;
END comb_lock;