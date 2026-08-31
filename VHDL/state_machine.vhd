library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_functions.all;

entity state_machine is
    port (
        clk : in std_logic;
        reset : in std_logic;
        opcode : in std_logic_vector(13 downto 0);
        status_z : in std_logic;
        alu_zero : in std_logic;
        op : out alu_op;
        we_mem : out std_logic;
        re_mem : out std_logic;
        we_w : out std_logic;
        we_status : out std_logic;
        instr_ret : out std_logic;
        push_stack : out std_logic;
        pop_stack : out std_logic;
        bit_select : out std_logic_vector(2 downto 0);
        data : out std_logic_vector(7 downto 0);
        stack_in : in std_logic_vector(12 downto 0);
        pc_out : out std_logic_vector(12 downto 0);
        addr : out std_logic_vector(6 downto 0)
    );
end entity;
architecture rtl of state_machine is
    type state_type is (iFetch, Mread, Execute, Mwrite); --execution steps
    signal current_state : state_type := iFetch;
    signal pc_reg : unsigned(12 downto 0) := (others => '0');
    signal cur_opcode : std_logic_vector(13 downto 0) := (others => '0');
    signal cur_op : alu_op := NOP;--internal signals
    signal force_branch_nop : std_logic := '0';
    signal force_skip_nop   : std_logic := '0';--if empty cycles
    function needs_read(o : alu_op) return boolean is
    begin
        case o is
            when ADDWF | ANDWF | COMF | DECF | DECFSZ | INCF | INCFSZ | IORWF | MOVF | RLF |
                 RRF | SUBWF | SWAPF | XORWF |
                 BCF | BSF | BTFSC | BTFSS =>
                return true;
            when others =>
                return false;
        end case;--check if data needed from RAM
    end function;
    function writes_mem(
        o : alu_op;
        instr : std_logic_vector(13 downto 0)
    ) return boolean is
    begin
        case o is
            when CLRF | MOVWF | BCF | BSF =>
                return true;
            when ADDWF | ANDWF | COMF | DECF | DECFSZ | INCF | INCFSZ | IORWF | MOVF | RLF |
                 RRF | SUBWF | SWAPF | XORWF =>
                return instr(7) = '1';
            when others =>
                return false;
        end case;
    end function; --check if saved result
    function writes_w(
        o : alu_op;
        instr : std_logic_vector(13 downto 0)
    ) return boolean is
    begin
        case o is
            when CLRW | ADDLW | ANDLW | IORLW | MOVLW | RETLW | SUBLW | XORLW =>
                return true;
            when ADDWF | ANDWF | COMF | DECF | DECFSZ | INCF | INCFSZ | IORWF | MOVF | RLF |
                 RRF | SUBWF | SWAPF | XORWF =>
                return instr(7) = '0';
            when others =>
                return false;
        end case;
    end function;--check if saved to w reg
    function updates_status(o : alu_op) return boolean is
    begin
        case o is
            when ADDWF | ANDWF | CLRF | CLRW | COMF | DECF | INCF | IORWF | MOVF | RLF |
                 RRF | SUBWF | XORWF | ADDLW | ANDLW | IORLW | SUBLW | XORLW =>
                return true;
            when others =>
                return false;
        end case;
    end function;--check if z,dc,c updated
    function branch_target(instr : std_logic_vector(13 downto 0))
        return unsigned is
        variable target : unsigned(12 downto 0) := (others => '0');
    begin
        target(10 downto 0) := unsigned(instr(10 downto 0));
        return target;
    end function; --jump address frrom instr bits

begin
    pc_out <= std_logic_vector(pc_reg);
    instr_ret <= '1' when current_state = iFetch and reset = '0' else '0';
    op <= cur_op;
    addr <= cur_opcode(6 downto 0);
    data <= cur_opcode(7 downto 0);
    bit_select <= cur_opcode(9 downto 7); -- internal signal to output port
    re_mem <= '1' when current_state = Mread else '0';
    we_mem <= '1' when current_state = Mwrite and writes_mem(cur_op, cur_opcode) else '0';
    we_w <= '1' when current_state = Mwrite and writes_w(cur_op, cur_opcode) else '0';
    we_status <= '1' when current_state = Mwrite and updates_status(cur_op) else '0';
    push_stack <= '1' when current_state = Mwrite and cur_op = CALL else '0';
    pop_stack <= '1' when current_state = Mwrite and (cur_op = RETUR or cur_op = RETLW) else '0'; --combination logic,set control wires on state

    process(clk)--move states and update program counter
        variable v_decode : alu_op;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state <= iFetch;--starting at zero and clear all signals
                pc_reg <= (others => '0');
                cur_opcode <= (others => '0');
                cur_op <= NOP;
                force_branch_nop <= '0';
                force_skip_nop <= '0';
            else
                case current_state is
                    when iFetch =>
                        if force_branch_nop = '1' or force_skip_nop = '1' then--check if NOP
                            cur_opcode <= (others => '0');
                            cur_op <= NOP;
                            current_state <= Mwrite;
                        else
                            v_decode := decode_op(opcode);--get new command
                            cur_opcode <= opcode;
                            cur_op <= v_decode;
                            if needs_read(v_decode) then
                                current_state <= Mread;
                            else
                                current_state <= Execute;
                            end if;
                        end if;
                    when Mread =>
                        current_state <= Execute;--wait for data to arrive
                    when Execute =>
                        current_state <= Mwrite;--wait for calculation
                    when Mwrite =>
                        if force_branch_nop = '1' then
                            force_branch_nop <= '0';
                        elsif force_skip_nop = '1' then
                            force_skip_nop <= '0';
                            pc_reg <= pc_reg + 1;
                        elsif cur_op = CALL then --next address and finsih command
                            pc_reg <= branch_target(cur_opcode); --new address wait
                            force_branch_nop <= '1';
                        elsif cur_op = GOTO then
                            pc_reg <= branch_target(cur_opcode);
                            force_branch_nop <= '1';
                        elsif cur_op = RETUR or cur_op = RETLW then--previous address
                            pc_reg <= unsigned(stack_in);
                            force_branch_nop <= '1';
                        else
                            pc_reg <= pc_reg + 1;--move to next instruction
                            if (cur_op = DECFSZ or cur_op = INCFSZ) and alu_zero = '1' then--check if skip
                                force_skip_nop <= '1';
                            end if;
                        end if;
                        current_state <= iFetch;
                end case;
            end if;
        end if;
    end process;
end architecture;
