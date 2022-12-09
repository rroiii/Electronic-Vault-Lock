LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY password_encrypter IS
    PORT (
        decrypted_password : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        encrypted_password : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
END ENTITY password_encrypter;

ARCHITECTURE rtl OF password_encrypter IS
    SIGNAL temp : STD_LOGIC_VECTOR(0 TO 15);
BEGIN

    tempPass : FOR i IN decrypted_password'RANGE GENERATE
        temp(i) <= decrypted_password(i);
    END GENERATE;

    encryptPass : FOR i IN decrypted_password'RANGE GENERATE
        encrypted_password(i) <= decrypted_password(i) XOR temp(i);
    END GENERATE;
END ARCHITECTURE rtl;