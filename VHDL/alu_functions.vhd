library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package alu_functions is
    type alu_op is (ADDWF, ANDWF, ADDLW, ANDLW, BCF, BTFSC, BSF, BTFSS,
                    CLRF, CLRW, COMF, DECF, DECFSZ, INCF, INCFSZ, IORLW,
                    MOVF, MOVWF, CALL, GOTO, MOVLW, RETLW, RETUR, IORWF,
                    NOP, RLF, RRF, SUBLW, SUBWF, SWAPF, XORLW, XORWF);--all instructions

    subtype word9 is std_logic_vector(8 downto 0);
    subtype word8 is std_logic_vector(7 downto 0);
    subtype word5 is std_logic_vector(4 downto 0);
    subtype word3 is std_logic_vector(2 downto 0);--sizes for bit groups

    function str2op(op_str : string(1 to 5)) return alu_op;
    function get_z_flag(res : std_logic_vector) return std_logic;
    function decode_op(instr : std_logic_vector(13 downto 0)) return alu_op;--text or bits into opeartion
end package alu_functions;

package body alu_functions is
    function str2op(op_str : string(1 to 5)) return alu_op is--5 letter strings to operation
    begin
        if op_str = "ADDWF" then return ADDWF;
        elsif op_str = "ANDWF" then return ANDWF;
        elsif op_str = "CLRF" then return CLRF;
        elsif op_str = "CLRW" then return CLRW;
        elsif op_str = "COMF" then return COMF;
        elsif op_str = "DECF" then return DECF;
        elsif op_str = "INCF" then return INCF;
        elsif op_str = "IORWF" then return IORWF;
        elsif op_str = "MOVF" then return MOVF;
        elsif op_str = "MOVLW" then return MOVLW;
        elsif op_str = "MOVWF" then return MOVWF;
        elsif op_str = "RLF" then return RLF;
        elsif op_str = "RRF" then return RRF;
        elsif op_str = "SUBWF" then return SUBWF;
        elsif op_str = "SWAPF" then return SWAPF;
        elsif op_str = "XORWF" then return XORWF;
        elsif op_str = "XORLW" then return XORLW;
        elsif op_str = "BCF" then return BCF;
        elsif op_str = "BSF" then return BSF;
        elsif op_str = "BTFSC" then return BTFSC;
        elsif op_str = "BTFSS" then return BTFSS;
        elsif op_str = "CALL" then return CALL;
        elsif op_str = "GOTO" then return GOTO;
        elsif op_str = "RETUR" then return RETUR;
        elsif op_str = "RETLW" then return RETLW;
        elsif op_str = "SUBLW" then return SUBLW;
        elsif op_str = "IORLW" then return IORLW;
        elsif op_str = "ADDLW" then return ADDLW;
        elsif op_str = "ANDLW" then return ANDLW;
        elsif op_str = "DECFS" then return DECFSZ;
        elsif op_str = "INCFS" then return INCFSZ;
        else return NOP;
        end if;
    end function;

    function get_z_flag(res : std_logic_vector) return std_logic is
    begin
        if unsigned(res) = 0 then return '1';
        else return '0';
        end if;--return 1 if result 0
    end function;

    function decode_op(instr : std_logic_vector(13 downto 0)) return alu_op is--convert 14 bit to opeartion
    begin
        if instr = "00000000000000" then
            return NOP;
        elsif instr = "00000000001000" then
            return RETUR;
        end if; --filter those that could caus problems down the line beforehand as happened will testing

        if instr(13 downto 12) = "00" then -- tell from first 2 bits
            if instr(11 downto 7) = "00010" then 
                return CLRW; 
            end if;
            case instr(11 downto 8) is -- rest of th cases
                when "0111" => return ADDWF;
                when "0101" => return ANDWF;
                when "0001" => return CLRF;
                when "1001" => return COMF;
                when "0011" => return DECF;
                when "1011" => return DECFSZ;
                when "1010" => return INCF;
                when "1111" => return INCFSZ;
                when "0100" => return IORWF;
                when "1000" => return MOVF;
                when "0000" =>
                    if instr(7) = '1' then
                        return MOVWF;
                    else 
                        return NOP; --problem area
                    end if;
                when "1101" => return RLF;
                when "1100" => return RRF;
                when "0010" => return SUBWF;
                when "1110" => return SWAPF;
                when "0110" => return XORWF;
                when others => return NOP;
            end case;
        elsif instr(13 downto 12) = "01" then
            if instr(11 downto 10) = "00" then return BCF;
            elsif instr(11 downto 10) = "01" then return BSF;
            elsif instr(11 downto 10) = "10" then return BTFSC;
            else return BTFSS; --bitops
            end if;
        elsif instr(13 downto 11) = "100" then
            return CALL;
        elsif instr(13 downto 11) = "101" then
            return GOTO;
        else
            case instr(13 downto 8) is --check first 6 for math
                when "111110" | "111111" => return ADDLW;
                when "111001" => return ANDLW;
                when "111000" => return IORLW;
                when "110000" | "110001" | "110010" | "110011"=> return MOVLW;
                when "110100" | "110101" | "110110" | "110111" => return RETLW;
                when "111100" | "111101" => return SUBLW;
                when "111010" => return XORLW;
                when others => return NOP;
            end case;
        end if;
    end function;
end package body;

