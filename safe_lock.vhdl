library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity safe_lock is
    port (
        user_input : in integer;   -- the input from the user
        clk : in std_logic;        -- clock input
        reset : in std_logic;      -- reset input
        unlock : out std_logic     -- unlock output that indicates whether the lock is unlocked
    );
end entity safe_lock;

architecture rtl of safe_lock is
    -- Define the states for the combination lock state machine
    type state_type is (start, one, two, three, four, unlocked, waitTimer);
    -- Define the current state of the state machine
    signal current_state, next_state : state_type;

    -- Define the next state of the state machine, based on the
    -- current state and the input from the user
    signal next_state : state_type;

    -- Define the timer that is used to prevent the user from
    -- entering the password again for 5 minutes
    signal timer : time;

    -- password encrypter component
    component password_decrypter
        Port ( 
            encrypted_digit1 : in integer;
            encrypted_digit2 : in integer;
            encrypted_digit3 : in integer;
            encrypted_digit4 : in integer;
            decrypted_digit1 : in integer;
            decrypted_digit2 : in integer;
            decrypted_digit3 : in integer;
            decrypted_digit4 : in integer;
            );
    end component;

    -- password encrypter component instance
    signal encrypted_password : STD_LOGIC_VECTOR (11 downto 0) := "111000100101";
    signal decrypted_password : STD_LOGIC_VECTOR (11 downto 0);

begin
    P1: password_decrypter Port map (encrypted_password=> encrypted_password, decrypted_password => encrypted_password);
    -- The state machine that implements the combination lock
    process(current_state, user_input, timer)
    begin
        -- Set the next state based on the current state and user input
        case current_state is
                when start =>
                    -- If the user enters 1, transition to state "one"
                    if (digit_1 = encrypted_password(3 downto 0)) then
                        next_state <= one;
                    else
                        next_state <= start;
                    end if;

                when one =>
                    -- If the user enters 2, transition to state "two"
                    if (digit_2 = encrypted_password(7 downto 4)) then
                        next_state <= two;
                    else
                        next_state <= start;
                    end if;

                when two =>
                    -- If the user enters 3, transition to state "three"
                    if (digit_3 = encrypted_password(11 downto 8)) then
                        next_state <= three;
                    else
                        next_state <= start;
                    end if;

                when three =>
                    -- If the user enters 4, transition to state "four"
                    if (digit_3 = encrypted_password(11 downto 8)) then
                        next_state <= four;
                    else
                        next_state <= start;
                    end if;

                when four =>
                    -- If the user has entered the correct sequence, transition to the
                    -- "unlocked" state
                    next_state <= unlocked;

                when unlocked =>
                    -- If the lock is unlocked, stay in the "unlocked" state
                    next_state <= unlocked;

                when wait =>
                    -- If the timer has expired, transition back to the "start" state
                    if (timer = 0) then
                        next_state <= start;
                    else
                        next_state <= waitTimer;
                    end if;
        end case;
    end process;

    -- Update the current state based on the next state
    process(next_state)
    begin
        current_state <= next_state;

        -- If the user has entered the incorrect password, start the timer
        -- and transition to the "wait" state
        if (current_state = start and next_state = start) then
            timer <= 5 minutes;
            next_state <= waitTimer;
        end if;
    end process;

    
    
    
end architecture rtl;