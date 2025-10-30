library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_reg_b is
end entity;

architecture sim of tb_reg_b is
    -- Componentes
    component reg_b
    port(
        d1  : in  std_logic_vector(31 downto 0);
        a1, a2, ad : in std_logic_vector(4 downto 0);
        we, clk    : in std_logic;
        do1, do2   : out std_logic_vector(31 downto 0)
    );
    end component;

    -- Señales
    signal clk, reset, wer : std_logic := '0';
    signal rs1, rs2, rd    : std_logic_vector(4 downto 0) := (others => '0');
    signal data_in         : std_logic_vector(31 downto 0) := (others => '0');
    signal data_out1, data_out2 : std_logic_vector(31 downto 0);

begin
    U_REG : reg_b
    port map(
        d1  => data_in,
        a1  => rs1,
        a2  => rs2,
        ad  => rd,
        we  => wer,
        clk => clk,
        do1 => data_out1,
        do2 => data_out2
    );

    -- Generador de reloj
    clk_proc : process
    begin
        clk <= '0'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
    end process;

    -- Estímulos
    stim_proc : process
    begin
        -- Reset inicial
        reset <= '1';
        wait for 15 ns;
        reset <= '0';

        -- Escribir r1 = 0xAAAA5555
        wer <= '1'; rd <= "00001"; data_in <= x"AAAA5555";
        wait for 10 ns;

        -- Escribir r2 = 0x12345678
        rd <= "00010"; data_in <= x"12345678";
        wait for 10 ns;

        -- Escribir r3 = 0x0000ABCD
        rd <= "00011"; data_in <= x"0000ABCD";
        wait for 10 ns;

        -- Desactivar escritura
        wer <= '0';

        -- Leer r1 y r2
        rs1 <= "00001"; rs2 <= "00010";
        wait for 20 ns;

        -- Leer r2 y r3
        rs1 <= "00010"; rs2 <= "00011";
        wait for 20 ns;

        -- Intentar escribir con wer=0 (no debe cambiar)
        rd <= "00001"; data_in <= x"FFFFFFFF";
        wait for 20 ns;

        wait;
    end process;
end architecture;
