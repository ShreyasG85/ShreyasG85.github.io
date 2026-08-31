library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stack is 
    port (
        clk : in std_logic;
        reset : in std_logic;
        push : in std_logic;
        pop : in std_logic;
        data_in : in std_logic_vector(12 downto 0);
        data_out : out std_logic_vector(12 downto 0)
    );
end entity stack;

architecture rtl of stack is
    type stack_array is array (0 to 7) of std_logic_vector(12 downto 0);--shelf for return address
    signal stack_mem : stack_array := (others => (others => '0'));
    signal pointer : integer range 0 to 7 := 0; --point to current slot
begin
    data_out <= stack_mem((pointer + 7) mod 8); --just used basically pointer -1 but in circle
    process(clk, reset)
    begin
        if reset = '1' then
            pointer <= 0; --reset
        elsif rising_edge(clk) then
            if push = '1' then
                stack_mem(pointer) <= data_in;
                pointer <= (pointer + 1) mod 8; --write,move up,wrap back to 0
            elsif pop = '1' then
                pointer <= (pointer + 7) mod 8;-- move down, minus 1
            end if;
        end if;
    end process;
end architecture rtl;


