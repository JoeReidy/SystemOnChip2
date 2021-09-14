-- Component: CSR_4x32Reg 
-- Engineer: Fearghal Morgan, National University of Ireland, Galway
-- Date: 26/1/2021

--Description
-- 4 x 32-bit control and status register array
-- Assertion of wr, synchronous store data in register CSR(add)(31:0) = dIn(31:0) 
-- Combinationally output all 4 x register data array values on CSR(3:0)(31:0)
-- dOut(31:0) combinationally = CSR(add)
-- rst assertion asynchronously clears all registers

-- To create integer format of std_logic_vector address, for use with array addressing,
-- use ieee.numeric_std library to_integer(unsigned(<signal>))

-- Signal dictionary
--  clk				system strobe, rising edge asserted
--  rst				assertion (h) asynchronously clears all registers
--  WDTimeout       not used in model but included since used in a later model example which includes CSR update on watchdog timeout 
--  wr 				assertion (h) synchronously writes dIn(31:0) to CSR(add)
--  add(1:0)		2-bit address, addressing one of 4 CSRs 
--  dIn(31:0)		32-bit data to be written to CSR(add) 
--  CSR(3:0)(31:0)	4 x 32-bit register array 
--  dOut(31:0)	= CSR(add) combinational output 

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;
use work.arrayPackage.all;

entity CSR_4x32Reg is
    Port ( clk       : in std_logic;   
           rst       : in std_logic;   
           WDTimeout : in std_logic;   
		   
           wr        : in std_logic;  
	       add       : in std_logic_vector(1 downto 0);
	       dIn       : in std_logic_vector(31 downto 0);	  

           CSR       : out array4x32;
           CSROut      : out std_logic_vector(31 downto 0)
 		 );
end CSR_4x32Reg;

architecture RTL of CSR_4x32Reg is
signal XX_NS       : array4x32;	  
signal CS          : array4x32;	
signal selNS       : std_logic_vector(3 downto 0);

begin

NSDecode_i: process(CS, dIn ,wr,add)      				-- complete sensitivity list, including all combinational NSDecode process input signals
begin
if wr = '1' then
selNS <= "0001";
 case add is
  when "00"   => selNS <= "0001";  
  when "01"   => selNS <= "0010";
  when "10"   => selNS <= "0100";
  when "11"   => selNS <= "1000";
  when others => selNS <= "0001";
 end case;
else
 selNS <= "0000";
end if;

    case selNS(0) is
     when '0'    => XX_NS(0) <= CS(0);
     when '1'    => XX_NS(0) <= dIn;
     when others => XX_NS(0) <= CS(0);
	end case;
	
	case selNS(1) is
     when '0'    => XX_NS(1) <= CS(1);
     when '1'    => XX_NS(1) <= dIn;
     when others => XX_NS(1) <= CS(1);
	end case;
	
	case selNS(2) is
     when '0'    => XX_NS(2) <= CS(2);
     when '1'    => XX_NS(2) <= dIn;
     when others => XX_NS(2) <= CS(2);
	end case;
	
	case selNS(3) is
     when '0'    => XX_NS(3) <= CS(3);
     when '1'    => XX_NS(3) <= dIn;
     when others => XX_NS(3) <= CS(3);
	end case;
	
	
end process;

stateReg_i: process(clk, rst) 				-- include only signal clk and rst (asynchronous reset) in sensitivity list
begin
    if rst = '1' then
	   CS <= (others => (others => '0'));
	elsif clk'event and clk = '1' then
	   CS <= XX_NS;
	end if;  		-- to be completed 
end process;
asgnCSR_i:   CSR    <= CS;    				-- assigning CSR (output signal) = CS (VHDL internal signal)

gendOut_i: process(add,CS)
begin
CSROut <= std_logic_vector(CS(0)); --default
    case add(1 downto 0) is
        when "01"   => CSROut <= CS(1);
        when "10"   => CSROut <= CS(2);
        when "11"   => CSROut <= CS(3);
        when others => CSROut <= CS(0);
    end case;
end process;
end RTL;