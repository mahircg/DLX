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
-- DLX Pipeline Memory Stufe.
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


-- ===================================================================
entity dlx_pipe_mem is

  port (
    clk                 : in  std_logic;
    rst                 : in  std_logic;
    dc_wait             : in  std_logic;
    
    dc_rdata            : in  dlx_word;

    ex_mem_alu_out      : in  dlx_word;
    ex_mem_dm_width     : in  Mem_width;
    ex_mem_us_sel       : in  std_logic;
    ex_mem_data_sel     : in  std_logic; 
    ex_mem_reg_rd       : in  RegAdr;
    ex_mem_opcode_class : in  Opcode_class;
    
    mem_wb_opcode_class : out Opcode_class;
    mem_wb_reg_rd       : out RegAdr;
    mem_wb_data         : out dlx_word;
    
    mem_data            : out dlx_word

  );
  
end dlx_pipe_mem;

-- ===================================================================
architecture behavior of dlx_pipe_mem is

  signal mem_dm_ext     : dlx_word;
  signal mem_data_int   : dlx_word;
  
begin

  -- kombinatorischer Teil
  -- =====================
  mem_data     <= mem_data_int;
  mem_data_int <= mem_dm_ext     when ex_mem_data_sel = SEL_DM_OUT else
                  ex_mem_alu_out;

  dout_ext : process( ex_mem_dm_width, ex_mem_us_sel, dc_rdata )
  begin
    case ex_mem_dm_width is
      
      when MEM_WIDTH_HALFWORD =>
        if ex_mem_us_sel = SEL_SIGNED then
          mem_dm_ext( 0 to 15) <= (others => dc_rdata(16));
          mem_dm_ext(16 to 31) <= dc_rdata(16 to 31);
        else
          mem_dm_ext( 0 to 15) <= (others => '0');
          mem_dm_ext(16 to 31) <= dc_rdata(16 to 31);
        end if;
      
      when MEM_WIDTH_BYTE =>
        if ex_mem_us_sel = SEL_SIGNED then
          mem_dm_ext( 0 to 23) <= (others => dc_rdata(24));
          mem_dm_ext(24 to 31) <= dc_rdata(24 to 31);
        else
          mem_dm_ext( 0 to 23) <= (others => '0');
          mem_dm_ext(24 to 31) <= dc_rdata(24 to 31);
        end if;
      
      when others =>
        mem_dm_ext <= dc_rdata;
    
    end case;
  end process dout_ext;


  -- sequentieller Teil
  -- ==================
  mem_seq : process (clk)
  begin
    if clk'event and clk = '1' then
      if dc_wait = '0' then
        mem_wb_opcode_class <= ex_mem_opcode_class;
        mem_wb_reg_rd       <= ex_mem_reg_rd;
        mem_wb_data         <= mem_data_int;
      end if;
    end if;  

  end process mem_seq;


end behavior;
