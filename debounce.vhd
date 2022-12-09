library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Debounce entity
entity debounce is
    port(
        clk: in std_logic;
        raw_signal: in std_logic
        debounced_signal: out std_logic;
    );
end debounce;

-- Debounce architecture
architecture debounce_arch of debounce is
    signal counter: integer range 0 to 100;
    signal debounce_delay: integer range 0 to 100;
begin

    -- Initialize the counter and debounce delay
    counter <= 0;
    debounce_delay <= 10;

    -- Debouncing process
    debouncing : process(clk)
    begin
            if rising_edge(clk) then
            if raw_signal = '1' then
            counter <= counter + 1;
            else
            counter <= 0;
            end if;
        end if;
    end process;

    -- Output process
    output: process(clk)
        begin
        if rising_edge(clk) then
            if counter >= debounce_delay then
            debounced_signal <= raw_signal;
            end if;
        end if;
    end process;

end debounce_arch;