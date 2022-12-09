LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

entity password_encrypter is
    port (
        decrypted_password : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        encrypted_password : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
end entity password_encrypter;

architecture rtl of password_encrypter is
    signal temp : STD_LOGIC_VECTOR(0 to 15);
begin

    for i in a'range generate
        temp(i) <= decrypted_password(i)  
    end generate;

    for i in decrypted_password'range generate
        encrypted_password(i) <= decrypted_password(i) xor temp(i);
    end generate;
    
    
end architecture rtl;