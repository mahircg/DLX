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
-- Register-File der DLX. Das Registerfile besteht aus 2 Dualport-
-- Memories der Virtex FPGA Familie von Xilinx.
-- 
-- ===================================================================
--
-- $Author: gilbert $
-- $Date: 2002/06/18 09:27:04 $
-- $Revision: 2.0 $
-- 
-- ===================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dlx_global.all;

entity register_file is
  port(
    -- algemeine Signal
    clk :     in  std_logic;
    
    rs1 :     in  std_logic_vector(0 to 4);
    rs2 :     in  std_logic_vector(0 to 4);
    rd :      in  std_logic_vector(0 to 4);

    we :      in  std_logic;
    data_in : in  dlx_word;
    
    a :       out dlx_word;
    b :       out dlx_word
  ); 
end register_file;


-- ===================================================================
architecture sim of register_file is

  type reg_ram_array is array(0 to 31) of dlx_word;
  
  signal write :          std_logic;
  
begin
  -- =================================================================
  -- Register r0 darf nicht veraendert werden (r0 = 0 per Definition)!
  -- =================================================================
  disable_write_on_r0: process( rd, we )
  begin
    if rd = "00000" then
      write <= '0';
    else
      write <= we;
    end if;
  end process disable_write_on_r0;


  -- read asynchronously
  -- =======================
  mem : process
    variable reg_ram : reg_ram_array := (others => X"00_00_00_00");
  begin
    wait on clk, rs1, rs2;
    
    -- write synchronously
    -- =======================
    if clk'event and clk = '1' then
      if is_X( write ) then
        assert false
          report "Register-File Steuersignale enthalten 'X'"
          severity error;
      elsif write = '1' then
        reg_ram(to_integer(unsigned(rd))) := data_in;
      end if;

    end if;

    -- read asynchronously
    -- =======================
    if is_X( rs1 ) then
      a <= (others => 'X');
    else
      a <= reg_ram(to_integer(unsigned(rs1)));
    end if;
      
    if is_X( rs2 ) then
      b <= (others => 'X');
    else
      b <= reg_ram(to_integer(unsigned(rs2)));
    end if;  
  end process mem;  
  
end sim;
