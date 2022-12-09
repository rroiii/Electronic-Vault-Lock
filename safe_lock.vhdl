library ieee;
use ieee.std_logic_1164.all;

entity safe_lock is
    port (
        clk: in std_logic;     -- Clock signal
        rst: in std_logic;     -- Reset signal
        d: in std_logic_vector(3 downto 0);     -- Input for the combination lock
        correct: out std_logic;     -- Output indicating if the combination is correct
        done: out std_logic;     -- Output indicating if the combination has been entered
        seg_min: out std_logic_vector(3 downto 0);     -- Output for the minutes on the seven segment display
        seg_sec: out std_logic_vector(3 downto 0)     -- Output for the seconds on the seven segment display
    );
end safe_lock;

architecture comb_lock of safe_lock is
    type state_type is (start, digit1, digit2, digit3, digit4, unlocked, wait);     -- Define states for the combination lock
    signal state: state_type;     -- State of the combination lock
    signal combination: std_logic_vector(3 downto 0);     -- Correct combination
    signal counter: integer range 0 to 300000;     -- 5-minute counter
begin
    process(clk, rst)
    begin
        if rst = '1' then
            state <= start;     -- Reset the state to start
            combination <= "0000";     -- Set the combination to 0000
            counter <= 0;     -- Reset the counter to 0
            seg_min <= "0000";     -- Clear the minutes on the seven segment display
            seg_sec <= "0000";     -- Clear the seconds on the seven segment display
        elsif rising_edge(clk) then
            case state is
                when start =>
                    if counter = 0 then     -- If the delay has expired
                        if d = "0000" then     -- First digit of combination
                            state <= digit1;
                            combination <= "0???;     -- Set next digit to ?
                            seg_min <= "0000";     -- Clear the minutes on the seven segment display
                            seg_sec <= "0000";     -- Clear the seconds on the seven segment display
                        else
                            state <= start;     -- Incorrect first digit, reset to start state
                        end if;
                    else
                        counter <= counter - 1;     -- Decrement the counter
                        seg_min <= to_unsigned(counter / 6000, 4);     -- Calculate and display the minutes on the seven segment display
                        seg_sec <= to_unsigned(counter mod 6000, 4);     -- Calculate and display the seconds on the seven segment display
                    end if;
                when digit1 =>
                    if d = "0???" then     -- Second digit of combination
                        state <= digit2;
                        combination <= "0??0";     -- Set next digit to 0
                        seg_min <= "0000";     -- Clear the minutes on the seven segment display
                        seg_sec <= "0000";    
                        state <= wait;     -- Incorrect second digit, go to wait state
                        counter <= 300000;     -- Set the counter to 5 minutes
                        seg_min <= to_unsigned(counter / 6000, 4);     -- Calculate and display the minutes on the seven segment display
                        seg_sec <= to_unsigned(counter mod 6000, 4);     -- Calculate and display the seconds on the seven segment display
                    end if;
                when digit2 =>
                    if d = "0??0" then     -- Third digit of combination
                        state <= digit3;
                        combination <= "0?00";     -- Set next digit to 0
                        seg_min <= "0000";     -- Clear the minutes on the seven segment display
                        seg_sec <= "0000";     -- Clear the seconds on the seven segment display
                    else
                        state <= wait;     -- Incorrect third digit, go to wait state
                        counter <= 300000;     -- Set the counter to 5 minutes
                        seg_min <= to_unsigned(counter / 6000, 4);     -- Calculate and display the minutes on the seven segment display
                        seg_sec <= to_unsigned(counter mod 6000, 4);     -- Calculate and display the seconds on the seven segment display
                    end if;
                when digit3 =>
                    if d = "0?00" then     -- Fourth digit of combination
                        state <= digit4;
                        correct <= '1';     -- Correct combination has been entered
                        done <= '1';     -- Combination has been entered
                        seg_min <= "0000";     -- Clear the minutes on the seven segment display
                        seg_sec <= "0000";     -- Clear the seconds on the seven segment display
                    else
                        state <= wait;     -- Incorrect fourth digit, go to wait state
                        counter <= 300000;     -- Set the counter to 5 minutes
                        seg_min <= to_unsigned(counter / 6000, 4);     -- Calculate and display the minutes on the seven segment display
                        seg_sec <= to_unsigned(counter mod 6000, 4);     -- Calculate and display the seconds on the seven segment display
                    end if;
                when digit4 =>
                    if d /= "0?00" then     -- If the combination is not entered again
                        state <= wait;     -- Go to wait state
                        counter <= 300000;     -- Set the counter to 5 minutes
                        seg_min <= to_unsigned(counter / 6000, 4);     -- Calculate and display the minutes on the seven segment display
                        seg_sec <= to_unsigned(counter mod 6000, 4);     -- Calculate and display the seconds on the seven segment display
                    end if;
                when wait =>
                    if counter = 0 then     -- If the delay has expired
                        state <= start;     -- Go back to start state
                        seg_min <= "0000";     -- Clear the minutes on the seven segment display
                        seg_sec <= "0000";     -- Clear the seconds on the seven segment display
                    else
                        counter <= counter - 1;     -- Decrement the counter
                        seg_min <= to_unsigned(counter / 6000, 4);     -- Calculate and display the minutes on the seven segment display
                        seg_sec <= to_unsigned(counter mod 6000, 4);
                        state <= unlocked;     -- Unlock the combination lock
                        seg_min <= "0000";     -- Clear the minutes on the seven segment display
                        seg_sec <= "0000";     -- Clear the seconds on the seven segment display
                    end if;
                when unlocked =>
                    if d /= "0?00" then     -- If the combination is not entered again
                        state <= start;     -- Reset to start state
                        correct <= '0';     -- Incorrect combination
                        done <= '0';     -- Combination has not been entered
                        seg_min <= "0000";     -- Clear the minutes on the seven segment display
                        seg_sec <= "0000";     -- Clear the seconds on the seven segment display
                    end if;
            end case;
        end if;
    end process;
end comb_lock;
