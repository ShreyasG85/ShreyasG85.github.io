library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dpram is 
    generic(
        ADDR_WIDTH : integer := 7; --address birts
        DATA_WIDTH : integer := 8--data bits
    );
    port(
        clk : in std_logic;
        we : in std_logic; 
        re : in std_logic; -- write read
        we_status : in std_logic;--write for status bits
        d : in std_logic_vector(DATA_WIDTH-1 downto 0);--data to write
        d_status : in std_logic_vector(DATA_WIDTH-1 downto 0);--status to write
        addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);--memory
        q : out std_logic_vector(DATA_WIDTH-1 downto 0);--data out
        q_status : out std_logic_vector(2 downto 0)--satuts out bits
    );
end entity dpram;

architecture rtl of dpram is
    type ram_type is array (0 to (2**ADDR_WIDTH) - 1) of std_logic_vector(DATA_WIDTH-1 downto 0);--internal store
    signal ram : ram_type := (others => (others => '0'));
begin
    process(clk)
        variable v_addr : integer range 0 to (2**ADDR_WIDTH)-1;
    begin
        if rising_edge(clk) then
            if is_X(addr) then-- if unknown signal
                v_addr := 0;
            else
                v_addr := to_integer(unsigned(addr));
            end if;
            if re = '1' then --copy if reading yes
                q <= ram(v_addr);
            end if;
            if we = '1' then--save if writing yes
                ram(v_addr) <= d;
            end if;
            if we_status = '1' then
                ram(3)(2 downto 0) <= d_status(2 downto 0);--update status bits
            end if;
        end if;
    end process;
    q_status <= ram(3)(2 downto 0); --asynchron state to update send 2 to 0 bits of address 3
end architecture rtl;






