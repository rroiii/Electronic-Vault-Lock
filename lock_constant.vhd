LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE lock_constant IS

    CONSTANT inputWaitTime : INTEGER := 5000;
    CONSTANT lockWaitTime : INTEGER := 30000;

END PACKAGE lock_constant;