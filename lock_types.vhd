LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;


PACKAGE lock_types IS

    TYPE state_digit IS (start, digit1, digit2, digit3, unlocked, waitTimer); -- Define states for the combination lock
    TYPE state_lock IS (unlocking, setNewLock); -- Defines the state of locks
    TYPE int_array IS ARRAY(0 TO 3) OF INTEGER;

END PACKAGE lock_types;