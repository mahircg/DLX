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
-- Globale Deklarationen von Typen, Subtypen und Konstanten,
-- die in der gesamten DLX-Architektur benoetigt werden.
-- 
-- ===================================================================
--
-- $Author: gilbert $
-- $Date: 2002/06/18 09:27:03 $
-- $Revision: 2.0 $
-- 
-- ===================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package dlx_global is

  -- ========================================================
  -- Subtypes
  -- ========================================================
  subtype Dlx_word_s     is signed   ( 0 to 31 );
  subtype Dlx_word_us    is unsigned ( 0 to 31 );

  subtype Dlx_address    is std_logic_vector ( 31 downto 0 );
  subtype Dlx_word       is std_logic_vector ( 0  to 31 );
  subtype Dlx_arith_word is std_logic_vector ( 0  to 32 );
  
  subtype Opcode         is std_logic_vector( 0 to 5 );
  subtype Spfunc         is std_logic_vector( 0 to 5 );
  subtype Fpfunc         is std_logic_vector( 0 to 4 );
  subtype RegAdr         is std_logic_vector( 0 to 4 );
  subtype Imm16          is std_logic_vector( 0 to 15 );
  subtype Imm26          is std_logic_vector( 0 to 25 ); 
  subtype Imm17          is std_logic_vector( 0 to 16 ); 

  subtype Alu_func       is std_logic_vector( 3 downto 0);
  subtype Mem_width      is std_logic_vector( 1 downto 0);

  -- Op-Code Klassen für Forwarding
  -- NOJump: reg-reg-Alu, reg-im-Alu, Load, Jump-Branch-Store
  type Opcode_class   is ( NOFORW, LOAD, STORE, RR_ALU, IM_ALU, BRANCH, 
                           MOVEI2S, MOVES2I );

  type Forward_Select is ( FWDSEL_NOFORW,      FWDSEL_EX_MEM_ALU_OUT,
                           FWDSEL_MEM_WB_DATA );


  -- ===========================================================================
  -- Constants
  -- ===========================================================================
  constant ADDRESS_WIDTH       : natural    := 16;

  constant DLX_WORD_ZERO       : Dlx_word   := (others => '0');

  constant SEL_ALU_OUT         : std_logic  := '1';
  constant SEL_DM_OUT          : std_logic  := '0';
  constant SEL_UNSIGNED        : std_logic  := '0';
  constant SEL_SIGNED          : std_logic  := '1'; 
  
  
  -- Konstanten zur Selektion des Alu-Operand-B (EX)
  constant SEL_ID_EX_B         : std_logic := '1';
  constant SEL_ID_EX_IMM       : std_logic := '0';
  
  constant REG_0               : Regadr        := "00000";
  constant REG_31              : Regadr        := "11111"; 
  
  constant MEM_WIDTH_WORD      : Mem_width     := "00";
  constant MEM_WIDTH_HALFWORD  : Mem_width     := "10";
  constant MEM_WIDTH_BYTE      : Mem_width     := "01";

  -- Bitbreiten fuer Adressen (Tag u. Offset) fuer ICache/DCache
  constant bw_ic_offset : integer :=   5;
  constant bw_ic_tag    : integer :=   7;
  constant bw_dc_offset : integer :=   5;
  constant bw_dc_tag    : integer :=   7;

  -- Bitbreite einer Cacheline, fest 4x32 Bit = 128 Bit
  -- Die Bitbreite hat Konsequenzen auf die gesamte
  -- Cache Architektur und kann nicht geaendert werden !!!
  constant bw_cacheline : integer := 128;

  
end dlx_global;
