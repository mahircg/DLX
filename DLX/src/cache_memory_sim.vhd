-- ===================================================================
-- (C)opyright 2001, 2002
-- 
-- Lehrstuhl Entwurf Mikroelektronischer Systeme
-- Prof. Wehn
-- Universitaet Kaiserslautern
-- 
-- ===================================================================
-- 
-- Autoren:  Frank Gilbert
--           Christian Neeb
--           Timo Vogt
-- 
-- ===================================================================
-- 
-- Projekt: Mikroelektronisches Praktikum
--          SS 2002
-- 
-- ===================================================================
-- 
-- Modul:
-- Cache-Memory der DLX. Der Speicher besteht aus LUT-RAMs
-- der Virtex FPGA Familie von Xilinx.
-- 
-- ===================================================================
--
-- $Author: gilbert $
-- $Date: 2002/06/18 09:27:02 $
-- $Revision: 2.0 $
-- 
-- ===================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity cache_memory is
  generic(
    bit_width  : natural;
    addr_width : natural
  );
  port(
    -- algemeine Signal
    clk :       in  std_logic;
    
    addr :      in  std_logic_vector(addr_width-1 downto 0);
    write :     in  std_logic;
    data_out :  out std_logic_vector(0 to bit_width-1);
    data_in :   in  std_logic_vector(0 to bit_width-1)
  ); 
end cache_memory;


-- ===================================================================
architecture sim of cache_memory is

  type ram_array is array(0 to 2**addr_width-1) 
                      of std_logic_vector(0 to  bit_width-1);
                      
  constant all_zero : std_logic_vector(0 to bit_width-1) := (others => '0');
  
begin

  mem : process
    variable ram : ram_array := (others => all_zero);
  begin
    wait on clk, addr;
    
    -- write synchronously
    -- =======================
    if clk'event and clk = '1' then
      if is_X( write ) then
        assert false
          report "Cache-Memory Steuersignale enthalten 'X'"
          severity error;
      elsif write = '1' then
        ram(to_integer(unsigned(addr))) := data_in;
      end if;

    end if;

    -- read asynchronously
    -- =======================
    if is_X( addr ) then
      data_out <= (others => 'X');
    else
      data_out <= ram( to_integer( unsigned( addr ) ) );
    end if;
  end process mem;  
  
end sim;
