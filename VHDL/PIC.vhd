library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_functions.all;

entity PIC is
    port (
        clk : in std_logic;
        reset : in std_logic;
        opcode : in std_logic_vector(13 downto 0); --input instr
        program_counter : out std_logic_vector(12 downto 0);
        instruction_return : out std_logic; --pulse after command
        work_reg : out std_logic_vector(7 downto 0); --w reg output
        status : out std_logic_vector(2 downto 0)--z,dc,c
    );
end entity PIC;

architecture struct of PIC is
    signal s_op : alu_op;
    signal s_we_mem : std_logic := '0';
    signal s_we_status : std_logic := '0';
    signal s_re_mem : std_logic := '0';
    signal s_we_w : std_logic := '0';
    signal s_bit_select : std_logic_vector(2 downto 0) := (others => '0');
    signal s_data : std_logic_vector(7 downto 0) := (others => '0');
    signal s_addr : std_logic_vector(6 downto 0) := (others => '0');
    signal s_pc : std_logic_vector(12 downto 0) := (others => '0');
    signal s_ram_q : std_logic_vector(7 downto 0) := (others => '0');
    signal s_ram_stat : std_logic_vector(2 downto 0) := (others => '0');
    signal s_alu_res : std_logic_vector(7 downto 0) := (others => '0');
    signal s_alu_stat : std_logic_vector(2 downto 0) := (others => '0');
    signal s_alu_zero : std_logic := '0';
    signal s_w_reg : std_logic_vector(7 downto 0) := (others => '0');
    signal s_alu_b : std_logic_vector(7 downto 0) := (others => '0');
    signal s_push, s_pop : std_logic := '0';
    signal s_stack_out : std_logic_vector(12 downto 0) := (others => '0');
    signal s_pc_plus_one : std_logic_vector(12 downto 0) := (others => '0'); --internal wirres
begin
    process(all)
    begin
        case s_op is
            when ADDLW | ANDLW | IORLW | MOVLW | RETLW | SUBLW | XORLW =>
                s_alu_b <= s_data;
            when others =>
                s_alu_b <= s_ram_q;
        end case;--select if alu math uses fixed no.s or RAM data
    end process;
    s_alu_zero <= '1' when s_alu_res = x"00" else '0';
    s_pc_plus_one <= std_logic_vector(unsigned(s_pc) + 1);--address calculation
    DECODER_INST: entity work.state_machine
        port map (
            clk => clk,
            reset => reset,
            opcode => opcode,
            status_z => s_ram_stat(2),
            alu_zero => s_alu_zero,
            op => s_op,
            we_mem => s_we_mem,
            re_mem => s_re_mem,
            we_w => s_we_w,
            we_status => s_we_status,
            instr_ret => instruction_return,
            push_stack => s_push,
            pop_stack => s_pop,
            bit_select => s_bit_select,
            data => s_data,
            stack_in => s_stack_out,
            pc_out => s_pc,
            addr => s_addr
        );
    ALU_INST: entity work.alu
        port map (
            a => s_w_reg,
            b => s_alu_b,
            op => s_op,
            bit_select => s_bit_select,
            status_in => s_ram_stat,
            status => s_alu_stat,
            result => s_alu_res
        );
    RAM_INST: entity work.dpram
        port map (
            clk => clk,
            we => s_we_mem,
            re => s_re_mem,
            we_status => s_we_status,
            d => s_alu_res,
            d_status => ("00000" & s_alu_stat),
            addr => s_addr, 
            q => s_ram_q,
            q_status => s_ram_stat
        );
    STACK_INST: entity work.stack
        port map (
            clk => clk,
            reset => reset,
            push => s_push,
            pop => s_pop,
            data_in => s_pc_plus_one,
            data_out => s_stack_out
        );-- all instances
    process(clk) begin
        if rising_edge(clk) then
            if s_we_w = '1' then
                s_w_reg <= s_alu_res;
            end if;
        end if;--update w reg on edge if write
    end process;
    program_counter <= s_pc;
    work_reg <= s_w_reg;
    status <= s_alu_stat;--map
end architecture;



