LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

USE work.lock_types.ALL;

PACKAGE lock_constant IS

    CONSTANT inputSetLockTime : INTEGER := 1;
    CONSTANT inputWaitTime : INTEGER := 5; --5s
    CONSTANT lockWaitTime : INTEGER := 30; -- 30s

    CONSTANT digit1_STATE : state_digit := digit1;
    CONSTANT digit2_STATE : state_digit := digit2;
    CONSTANT digit3_STATE : state_digit := digit3;
    CONSTANT unlocked_STATE : state_digit := unlocked;
END PACKAGE lock_constant;