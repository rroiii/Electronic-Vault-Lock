LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY password_decrypter IS
    PORT (
        KEY: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        encrypted_password : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        decrypted_password : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY password_decrypter;

ARCHITECTURE rtl OF password_decrypter IS
    SIGNAL temp : STD_LOGIC_VECTOR(0 TO 15);
BEGIN
    decryptPass : FOR i IN encrypted_password'RANGE GENERATE
    temp(i) <= KEY(i) XOR encrypted_password(i);
    END GENERATE;

    tempPass : FOR i IN encrypted_password'RANGE GENERATE
    decrypted_password(i) <= temp(i);
    END GENERATE;

END ARCHITECTURE rtl;