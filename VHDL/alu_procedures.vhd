library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_functions.all;

package alu_procedures is 
    procedure do_add(W, f : in word8; signal status_in : in word3; signal status : out word3; signal res : out word8); -- add
    procedure do_sub(W, f : in word8; signal status_in : in word3; signal status : out word3; signal res : out word8); --subrtact
    procedure do_logic(val : in word8; op : in alu_op; status_in : in word3; signal status : out word3; signal res : out word8); --copy or compare
    procedure do_bit_op(signal f : in word8; signal bit_sel : in word3; signal op : in alu_op; signal status_in : in word3; signal status : out word3; signal res : out word8); -- flip
end package;

package body alu_procedures is 
    procedure do_add(W, f : in word8; signal status_in : in word3; signal status : out word3; signal res : out word8) is
        variable v_res : unsigned(8 downto 0); -- carry
        variable v_dc : unsigned(4 downto 0); --half carry
    begin
        v_res := unsigned('0' & W) + unsigned('0' & f);
        v_dc := unsigned('0' & W(3 downto 0)) + unsigned('0' & f(3 downto 0)); --check spills
        res <= std_logic_vector(v_res(7 downto 0)); --save
        status(2) <= get_z_flag(std_logic_vector(v_res(7 downto 0))); --zero
        status(1) <= v_dc(4); --dc
        status(0) <= v_res(8); --c
    end procedure;

    procedure do_sub(W, f : in word8; signal status_in : in word3; signal status : out word3; signal res : out word8) is
        variable v_res : unsigned(8 downto 0);
        variable v_dc : unsigned(4 downto 0);
    begin
        v_res := unsigned('0' & f) - unsigned('0' & W);
        v_dc := unsigned('0' & f(3 downto 0)) - unsigned('0' & W(3 downto 0)); --w-f
        res <= std_logic_vector(v_res(7 downto 0));
        status(2) <= get_z_flag(std_logic_vector(v_res(7 downto 0))); --flip flag
        status(1) <= not v_dc(4);
        status(0) <= not v_res(8);
    end procedure;

    procedure do_logic(val : in word8; op : in alu_op; status_in : in word3; signal status : out word3; signal res : out word8) is
    begin --check for zero
        res <= val;
        status(2) <= get_z_flag(val);
        status(1 downto 0) <= status_in(1 downto 0);
    end procedure;

    procedure do_bit_op(signal f : in word8; signal bit_sel : in word3; signal op : in alu_op; signal status_in : in word3; signal status : out word3; signal res : out word8) is
        variable v_res : word8;
        variable b_idx : integer;
    begin
        v_res := f;
        b_idx := to_integer(unsigned(bit_sel)); --I chnage into 0-7 index
        if op = BCF then 
            v_res(b_idx) := '0';--bit clear
        else 
            v_res(b_idx) := '1';--bit set
        end if;
        res <= v_res;
        status <= status_in;
    end procedure;
end package body;




