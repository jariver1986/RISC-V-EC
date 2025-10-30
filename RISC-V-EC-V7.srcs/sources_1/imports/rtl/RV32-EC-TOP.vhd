library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rv32i is
    port(
        clk   : in  std_logic
        -- no I/O for now; simulation-only top
    );
end rv32i;

architecture rtl of rv32i is
    -- Program counter path (13-bit address space)
    signal pc_cur   : std_logic_vector(12 downto 0);
    signal pc_nxt   : std_logic_vector(12 downto 0);
    signal pc_inc1  : std_logic_vector(12 downto 0);
    signal pc_br    : std_logic_vector(12 downto 0);
    signal one13    : std_logic_vector(12 downto 0);

    -- Instruction fields
    signal funct7_s : std_logic_vector(6 downto 0);
    signal rs2_s    : std_logic_vector(4 downto 0);
    signal rs1_s    : std_logic_vector(4 downto 0);
    signal func3_s  : std_logic_vector(2 downto 0);
    signal rd_s     : std_logic_vector(4 downto 0);
    signal opcode_s : std_logic_vector(6 downto 0);

    -- Control signals (from CU)
    signal wer      : std_logic;
    signal alu_scr  : std_logic;
    signal alu2reg  : std_logic;
    signal wem      : std_logic;
    signal imm_rd   : std_logic;
    signal ci_en    : std_logic;
    signal men      : std_logic;
    signal alu_op   : std_logic_vector(3 downto 0);

    -- Register file
    signal reg_do1  : std_logic_vector(31 downto 0);
    signal reg_do2  : std_logic_vector(31 downto 0);
    signal reg_din  : std_logic_vector(31 downto 0);

    -- ALU path
    signal alu_a1   : std_logic_vector(31 downto 0);
    signal alu_a2   : std_logic_vector(31 downto 0);
    signal alu_y    : std_logic_vector(31 downto 0);

    -- Data memory
    signal dm_dout  : std_logic_vector(31 downto 0);

    -- Immediate (13-bit from sign extend), then sign-extended to 32
    signal imm13    : std_logic_vector(12 downto 0);
    signal imm32    : std_logic_vector(31 downto 0);

    -- Branch condition (e.g., zero flag from ALU result)
    signal zflag    : std_logic;
begin
    ----------------------------------------------------------------------------
    -- PROGRAM COUNTER + FETCH
    ----------------------------------------------------------------------------

    U_PC : entity work.cont
        port map (
            clk => clk,
            din => pc_nxt,
            sal => pc_cur
        );

    U_ONE : entity work.one
        port map (
            one => one13
        );

    U_SUM_INC : entity work.sum
        port map (
            a    => pc_cur,
            b    => one13,
            dout => pc_inc1
        );

    -- Immediate path from instruction bits (heuristic: funct7 + rs2)
    U_SIGNE : entity work.sign_oe
        port map (
            i1  => funct7_s,
            i2  => rs2_s,
            sal => imm13
        );

    -- PC + immediate
    U_SUM_BR : entity work.sum
        port map (
            a    => pc_cur,
            b    => imm13,
            dout => pc_br
        );

    -- Branch decision helper: pick next PC.
    -- NOTE: The exact behavior of mux_c in your sources is not fully known (a, c, en -> sal).
    -- Here we use a simple choice:
    -- if (ci_en='1' and zflag='1') then pc_nxt := pc_br else pc_nxt := pc_inc1;
    -- If your mux_c implements this logic internally, wiring below should work.
    U_MUXC : entity work.mux_c
        port map (
            a   => pc_inc1,   -- default path
            c   => zflag,     -- condition (e.g., zero)
            en  => ci_en,     -- enable from CU
            sal => pc_nxt
        );

    -- INSTRUCTION MEMORY (fetch by PC)
    U_IMEM : entity work.prog_m
        port map (
            a      => pc_cur,
            funct7 => funct7_s,
            rs2    => rs2_s,
            rs1    => rs1_s,
            func3  => func3_s,
            rd     => rd_s,
            opcode => opcode_s
        );

    ----------------------------------------------------------------------------
    -- CONTROL UNIT
    ----------------------------------------------------------------------------
    U_CU : entity work.CU
        port map (
            opcode  => opcode_s,
            func7   => funct7_s,
            func3   => func3_s,
            wer     => wer,
            alu_scr => alu_scr,
            alu2reg => alu2reg,
            wem     => wem,
            imm_rd  => imm_rd,
            ci_en   => ci_en,
            men     => men,
            alu_op  => alu_op
        );

    ----------------------------------------------------------------------------
    -- REGISTER FILE
    ----------------------------------------------------------------------------
    U_REGS : entity work.reg_b
        port map (
            d1  => reg_din,
            a1  => rs1_s,
            a2  => rs2_s,
            ad  => rd_s,
            we  => wer,
            clk => clk,
            do1 => reg_do1,
            do2 => reg_do2
        );

    ----------------------------------------------------------------------------
    -- ALU + OPERAND SELECT
    ----------------------------------------------------------------------------
    alu_a1 <= reg_do1;

    -- 13->32 sign extension for immediate
    imm32 <= (31 downto 13 => imm13(12)) & imm13;

    -- ALU second operand: register or immediate (from control alu_scr)
    with alu_scr select
        alu_a2 <= reg_do2 when '0',
                  imm32   when others;

    U_ALU : entity work.alu
        port map (
            a1     => alu_a1,
            a2     => alu_a2,
            opcode => alu_op,
            alu_sal=> alu_y
        );

    -- Zero flag from ALU result (assumes slicer extracts one bit;
    -- if slicer picks bit 0==zero/equal flag use alu_y)
    U_SLICER : entity work.slicer
        port map (
            a => alu_y,
            b => zflag
        );

    ----------------------------------------------------------------------------
    -- DATA MEMORY + WRITEBACK
    ----------------------------------------------------------------------------
    U_DMEM : entity work.data_m
        port map (
            di  => reg_do2,  -- store value
            a   => alu_y,    -- address from ALU
            we  => wem,
            clk => clk,
            dout=> dm_dout
        );

    -- Writeback mux: ALU result vs Data Memory
    U_WB : entity work.mux2_1
        port map (
            a    => alu_y,
            b    => dm_dout,
            cont => alu2reg,
            sal  => reg_din
        );

end rtl;
