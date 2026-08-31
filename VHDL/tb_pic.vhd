library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_pic is
end entity tb_pic;

architecture sim of tb_pic is
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal opcode : std_logic_vector(13 downto 0) := (others => '0');
    signal program_counter : std_logic_vector(12 downto 0);
    signal instruction_return : std_logic;
    signal work_reg : std_logic_vector(7 downto 0);
    signal status : std_logic_vector(2 downto 0);
    constant CLK_period : time := 10 ns;
    type program_mem_t is array (0 to 8191) of std_logic_vector(13 downto 0);
    signal program_mem : program_mem_t := (others => (others => '0'));
begin
    clk <= not clk after CLK_PERIOD/2;
    dut: entity work.PIC
    port map (
        clk => clk,
        reset => reset,
        opcode => opcode,
        program_counter => program_counter,
        instruction_return => instruction_return,
        work_reg => work_reg,
        status => status
    );
    process(program_counter, program_mem)
    begin
        if is_x(program_counter) then
            opcode <= (others => '0');
        else 
            opcode <= program_mem(to_integer(unsigned(program_counter)));
        end if;
    end process;
    process
        file input_file : text open read_mode is "pic_code.txt";
        variable input_line : line;
        variable instr : std_logic_vector(13 downto 0);
        variable idx : integer := 0;
    begin
        while not endfile(input_file) loop
            readline(input_file, input_line);
            read(input_line, instr);
            program_mem(idx) <= instr;
            idx := idx + 1;
        end loop;
        reset <= '1';
        wait for 23 ns;
        reset <= '0';
        wait for 2000 ns;
        report "Sim comp. check res";
        wait;
    end process;
end architecture;
