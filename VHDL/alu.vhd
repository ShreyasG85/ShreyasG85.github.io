library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_functions.all;
use work.alu_procedures.all;

entity alu is
    port (
        a : in std_logic_vector(7 downto 0);-- W register
        b : in std_logic_vector(7 downto 0);-- data from RAM
        op : in alu_op;-- command
        bit_select : in std_logic_vector(2 downto 0);
        status_in : in std_logic_vector(2 downto 0); --input
        status : out std_logic_vector(2 downto 0);--output
        result : out std_logic_vector(7 downto 0)--final
    );
end entity alu;
architecture rtl of alu is
begin
    alu_process : process(a, b, op, bit_select, status_in)
        variable tmp9 : unsigned(8 downto 0);--check
        variable tmp5 : unsigned(4 downto 0);--check
        variable res8 : std_logic_vector(7 downto 0);--result holder
        variable idx  : integer range 0 to 7;--bit pick
    begin
        result <= (others => '0');
        status <= status_in;
        case op is
            when ADDWF | ADDLW => --add
                tmp9 := unsigned('0' & a) + unsigned('0' & b);
                tmp5 := unsigned('0' & a(3 downto 0)) + unsigned('0' & b(3 downto 0));
                res8 := std_logic_vector(tmp9(7 downto 0));
                result <= res8;
                status(2) <= get_z_flag(res8);--zflag
                status(1) <= tmp5(4);--dc flag
                status(0) <= tmp9(8);--c flag
            when SUBWF =>
                --f - W
                tmp9 := unsigned('0' & b) - unsigned('0' & a);
                tmp5 := unsigned('0' & b(3 downto 0)) - unsigned('0' & a(3 downto 0));
                res8 := std_logic_vector(tmp9(7 downto 0));
                result <= res8;
                status(2) <= get_z_flag(res8);
                status(1) <= not tmp5(4);
                status(0) <= not tmp9(8);
            when SUBLW =>
                tmp9 := unsigned('0' & b) - unsigned('0' & a);
                tmp5 := unsigned('0' & b(3 downto 0)) - unsigned('0' & a(3 downto 0));
                res8 := std_logic_vector(tmp9(7 downto 0));
                result <= res8;
                status(2) <= get_z_flag(res8);
                status(1) <= not tmp5(4);
                status(0) <= not tmp9(8); --k-w          
            when ANDWF | ANDLW =>
                res8 := a and b;
                result <= res8;
                status(2) <= get_z_flag(res8);
                status(1 downto 0) <= status_in(1 downto 0);
            when IORWF | IORLW =>
                res8 := a or b;
                result <= res8;
                status(2) <= get_z_flag(res8);
                status(1 downto 0) <= status_in(1 downto 0);
            when XORWF | XORLW =>
                res8 := a xor b;
                result <= res8;
                status(2) <= get_z_flag(res8);
                status(1 downto 0) <= status_in(1 downto 0);
            when COMF =>
                res8 := not b;
                result <= res8;
                status(2) <= get_z_flag(res8);
                status(1 downto 0) <= status_in(1 downto 0);  
            when DECF =>
                res8 := std_logic_vector(unsigned(b) - 1);
                result <= res8;
                status(2) <= get_z_flag(res8);
                status(1 downto 0) <= status_in(1 downto 0);
            when INCF =>
                res8 := std_logic_vector(unsigned(b) + 1);
                result <= res8;
                status(2) <= get_z_flag(res8);
                status(1 downto 0) <= status_in(1 downto 0);
            when DECFSZ =>
                result <= std_logic_vector(unsigned(b) - 1);
                status <= status_in;--no change in flag
            when INCFSZ =>
                result <= std_logic_vector(unsigned(b) + 1);
                status <= status_in;-- no update  
            when MOVF =>--input to result
                result <= b;
                status(2) <= get_z_flag(b);
                status(1 downto 0) <= status_in(1 downto 0);
            when MOVWF =>
                result <= a;
                status <= status_in; --w to f
            when MOVLW =>
                result <= b;
                status <= status_in; --go to w
            when RETLW =>
                result <= b;
                status <= status_in; -- go to w when return 
            when CLRF | CLRW =>
                result <= (others => '0');
                status(2) <= '1';
                status(1 downto 0) <= status_in(1 downto 0);
            when BCF =>
                res8 := b;
                idx := to_integer(unsigned(bit_select));
                res8(idx) := '0'; --no
                result <= res8;
                status <= status_in;
            when BSF =>
                res8 := b;
                idx := to_integer(unsigned(bit_select));
                res8(idx) := '1'; --yes
                result <= res8;
                status <= status_in;
            when RLF =>-- shift left
                result <= b(6 downto 0) & status_in(0);
                status(2 downto 1) <= status_in(2 downto 1);
                status(0) <= b(7);
            when RRF =>--shift right
                result <= status_in(0) & b(7 downto 1);
                status(2 downto 1) <= status_in(2 downto 1);
                status(0) <= b(0);
            when SWAPF =>
                result <= b(3 downto 0) & b(7 downto 4);--left 4 with right 4 swap
                status <= status_in;
            when others =>
                result <= b;
                status <= status_in;
        end case;
    end process alu_process;
end architecture rtl;
       
