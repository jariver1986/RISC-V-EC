library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pc is
end entity;

architecture sim of tb_pc is
    -- Componentes
    component cont
        port(clk, reset : in std_logic;
             d          : in std_logic_vector(12 downto 0);
             q          : out std_logic_vector(12 downto 0));
    end component;

    component one
        port(o : out std_logic_vector(12 downto 0));
    end component;

    component sum
        port(a, b : in std_logic_vector(12 downto 0);
             s    : out std_logic_vector(12 downto 0));
    end component;

    component mux_c
        port(a, b : in std_logic_vector(12 downto 0);
             ci_en : in std_logic;
             c : out std_logic_vector(12 downto 0));
    end component;

    -- Señales internas
    signal clk, reset, ci_en : std_logic := '0';
    signal pc_in, pc_out, pc_plus1 : std_logic_vector(12 downto 0);
    signal branch_addr : std_logic_vector(12 downto 0) := (others => '0');

begin
    -- Instanciaciones
    U_CONT : cont port map(clk, reset, pc_in, pc_out);
    U_ONE  : one  port map(o => pc_plus1);
    U_SUM  : sum  port map(a => pc_out, b => pc_plus1, s => pc_in);
    U_MUX  : mux_c port map(a => pc_in, b => branch_addr, ci_en => ci_en, c => pc_in);

    -- Generador de reloj
    clk_process : process
    begin
        clk <= '0'; wait for 5 ns;
        clk <= '1'; wait for 5 ns;
    end process;

    -- Estímulos
    stim_proc : process
    begin
        -- Reset
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Normal counting
        wait for 100 ns;

        -- Forzar salto (branch)
        branch_addr <= std_logic_vector(to_unsigned(20, 13));
        ci_en <= '1';
        wait for 10 ns;
        ci_en <= '0';

        -- Seguir contando
        wait for 100 ns;

        wait;
    end process;
end architecture;
