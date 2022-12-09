LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY password_decrypter IS
    PORT (
        encrypted_password : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        decrypted_password : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END ENTITY password_decrypter;

ARCHITECTURE rtl OF password_decrypter IS

BEGIN

END ARCHITECTURE rtl;