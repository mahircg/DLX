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
-- Zu Debug-zwecken wird hier zu jedem DLX-Befehl eine String 
-- abegelegt. Mit der Procedure disassemble kann in der Decode-Stufe
-- der DLX-Pipeline angezeigt werden welcher Befehl aktuell decodiert
-- wird.
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
use std.textio.all;
use work.dlx_global.all;
use work.dlx_opcode_package.all;

-- ===================================================================
package dlx_debug is

  procedure debug_disassemble (instr : dlx_word);
  
end dlx_debug;


-- ===================================================================
package body dlx_debug is


  subtype instr_name is string (1 to 8);
  
  type opcode_name_array  is array (0 to 63) of instr_name;
  type sp_func_name_array is array (0 to 63) of instr_name;
  type fp_func_name_array is array (0 to 31) of instr_name;
  
  constant opcode_names : opcode_name_array
    := ( "SPECIAL ",   "FPARITH ",   "J       ",   "JAL     ",
         "BEQZ    ",   "BNEZ    ",   "BFPT    ",   "BFPF    ",
         "ADDI    ",    "ADDUI   ",   "SUBI    ",   "SUBUI   ",
         "ANDI    ",   "ORI     ",   "XORI    ",   "LHI     ",
         "RFE     ",   "TRAP    ",   "JR      ",   "JALR    ",
         "SLLI    ",   "UNDEF_15",   "SRLI    ",   "SRAI    ",
         "SEQI    ",   "SNEI    ",   "SLTI    ",   "SGTI    ",
         "SLEI    ",   "SGEI    ",   "UNDEF_1E",   "UNDEF_1F",
         "LB      ",   "LH      ",   "UNDEF_22",   "LW      ",
         "LBU     ",   "LHU     ",   "LF      ",   "LD      ",
         "SB      ",   "SH      ",   "UNDEF_2A",   "SW      ",
         "UNDEF_2C",   "UNDEF_2D",   "SF      ",   "SD      ",
         "SEQUI   ",   "SNEUI   ",   "SLTUI   ",   "SGTUI   ",
         "SLEUI   ",   "SGEUI   ",   "UNDEF_36",   "UNDEF_37",
         "UNDEF_38",   "UNDEF_39",   "UNDEF_3A",   "UNDEF_3B",
         "UNDEF_3C",   "UNDEF_3D",   "UNDEF_3E",   "UNDEF_3F" );

  constant sp_func_names : sp_func_name_array
    := ( "NOP     ",   "UNDEF_01",   "UNDEF_02",   "UNDEF_03",
         "SLL     ",   "UNDEF_05",   "SRL     ",   "SRA     ",
         "UNDEF_08",   "UNDEF_09",   "UNDEF_0A",   "UNDEF_0B",
         "UNDEF_0C",   "UNDEF_0D",   "UNDEF_0E",   "UNDEF_0F",
         "SEQU    ",   "SNEU    ",   "SLTU    ",   "SGTU    ",
         "SLEU    ",   "SGEU    ",   "UNDEF_16",   "UNDEF_17",
         "UNDEF_18",   "UNDEF_19",   "UNDEF_1A",   "UNDEF_1B",
         "UNDEF_1C",   "UNDEF_1D",   "UNDEF_1E",   "UNDEF_1F",
         "ADD     ",   "ADDU    ",   "SUB     ",   "SUBU    ",
         "AND     ",   "OR      ",   "XOR     ",   "UNDEF_27",
         "SEQ     ",   "SNE     ",   "SLT     ",   "SGT     ",
         "SLE     ",   "SGE     ",   "UNDEF_2E",   "UNDEF_2F",
         "MOVI2S  ",   "MOVS2I  ",   "MOVF    ",   "MOVD    ",
         "MOVFP2I ",   "MOVI2FP ",   "UNDEF_36",   "UNDEF_37",
         "UNDEF_38",   "UNDEF_39",   "UNDEF_3A",   "UNDEF_3B",
         "UNDEF_3C",   "UNDEF_3D",   "UNDEF_3E",   "NOP     " );

  constant fp_func_names : fp_func_name_array
    := ( "ADDF    ",   "SUBF    ",   "MULTF   ",   "DIVF    ",
         "ADDD    ",   "SUBD    ",   "MULTD   ",   "DIVD    ",
         "CVTF2D  ",   "CVTF2I  ",   "CVTD2F  ",   "CVTD2I  ",
         "CVTI2F  ",   "CVTI2D  ",   "MULT    ",   "DIV     ",
         "EQF     ",   "NEF     ",   "LTF     ",   "GTF     ",
         "LEF     ",   "GEF     ",   "MULTU   ",   "DIVU    ",
         "EQD     ",   "NED     ",   "LTD     ",   "GTD     ",
         "LED     ",   "GED     ",   "UNDEF_1E",   "UNDEF_1F" );

  procedure debug_disassemble (instr : dlx_word) is
    variable outline : line;
  
  begin
    if instr(0 to 5) = "UUUUUU" then 
      return;
    end if;
    
    if instr(0 to 5) /= "000000" then
      write (outline, opcode_names(to_integer(unsigned(instr(0 to 5)))));
      writeline (output, outline);
    else
      write (outline, sp_func_names(to_integer(unsigned(instr(26 to 31)))));
      writeline (output, outline);
    end if;  
  end debug_disassemble;

end dlx_debug;
