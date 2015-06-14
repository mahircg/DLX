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
-- DLX Opcode Package
-- Binary-Codes of all DLX instructions are declared as constants
-- This concerns the constants for subtypes opcode, Spfunc and Alu_func
-- 
-- ===================================================================
--
-- $Author: gilbert $
-- $Date: 2002/06/18 09:27:03 $
-- $Revision: 2.0 $
-- 
-- ===================================================================

-- ===================================================================
--
-- $Author: wasenmueller $
-- $Date: 2014/04/28  $
-- $Revision: 2.1 $
-- Some comments added
-- ===================================================================

library ieee;
use ieee.std_logic_1164.all;
use work.dlx_global.all;

package dlx_opcode_package is

-- Opcodes (Bits 0 to 5) 
-- constants for subtype Opcode defined in package dlx_global
  constant op_special   : opcode := "000000"; -- Opcode for R-R-ALU Type instructions
  constant op_fparith   : opcode := "000001";
  constant op_j         : opcode := "000010";
  constant op_jal       : opcode := "000011";
  constant op_beqz      : opcode := "000100";
  constant op_bnez      : opcode := "000101";
  constant op_bfpt      : opcode := "000110";
  constant op_bfpf      : opcode := "000111";
  constant op_addi      : opcode := "001000";
  constant op_addui     : opcode := "001001";
  constant op_subi	   : opcode := "001010";
  constant op_subui	   : opcode := "001011";
  constant op_andi	   : opcode := "001100";
  constant op_ori	      : opcode := "001101";
  constant op_xori   	: opcode := "001110";
  constant op_lhi	      : opcode := "001111";

  constant op_rfe	      : opcode := "010000";
  constant op_trap	   : opcode := "010001";
  constant op_jr	      : opcode := "010010";
  constant op_jalr	   : opcode := "010011";
  constant op_slli	   : opcode := "010100";
  constant op_undef_15	: opcode := "010101";
  constant op_srli	   : opcode := "010110";
  constant op_srai	   : opcode := "010111";
  constant op_seqi	   : opcode := "011000";
  constant op_snei	   : opcode := "011001";
  constant op_slti	   : opcode := "011010";
  constant op_sgti	   : opcode := "011011";
  constant op_slei	   : opcode := "011100";
  constant op_sgei	   : opcode := "011101";
  constant op_undef_1E	: opcode := "011110";
  constant op_undef_1F	: opcode := "011111";

  constant op_lb	      : opcode := "100000";
  constant op_lh	      : opcode := "100001";
  constant op_undef_22	: opcode := "100010";
  constant op_lw	      : opcode := "100011";
  constant op_lbu	      : opcode := "100100";
  constant op_lhu	      : opcode := "100101";
  constant op_lf	      : opcode := "100110"; -- nicht implementiert
  constant op_ld	      : opcode := "100111"; -- nicht implementiert
  constant op_sb	      : opcode := "101000"; 
  constant op_sh	      : opcode := "101001";
  constant op_undef_2A	: opcode := "101010";
  constant op_sw	      : opcode := "101011";
  constant op_undef_2C	: opcode := "101100";
  constant op_undef_2D	: opcode := "101101";
  constant op_sf	: opcode := "101110"; -- nicht implementiert
  constant op_sd	: opcode := "101111"; -- nicht implementiert

  constant op_sequi	   : opcode := "110000"; -- nicht implementiert
  constant op_sneui	   : opcode := "110001"; -- nicht implementiert
  constant op_sltui	   : opcode := "110010"; -- nicht implementiert
  constant op_sgtui	   : opcode := "110011"; -- nicht implementiert
  constant op_sleui	   : opcode := "110100"; -- nicht implementiert
  constant op_sgeui	   : opcode := "110101"; -- nicht implementiert
  constant op_undef_36	: opcode := "110110";
  constant op_undef_37	: opcode := "110111";
  constant op_undef_38	: opcode := "111000";
  constant op_undef_39	: opcode := "111001";
  constant op_undef_3A	: opcode := "111010";
  constant op_undef_3B	: opcode := "111011";
  constant op_undef_3C	: opcode := "111100";
  constant op_undef_3D	: opcode := "111101";
  constant op_undef_3E	: opcode := "111110";
  constant op_undef_3F  : opcode := "111111";

-- func codes for R-R-ALU Type instructions
-- constants for subtype Spfunc defined in package dlx_global
  constant sp_undef_00  : spfunc := "000000";
  constant sp_undef_01  : spfunc := "000001";
  constant sp_undef_02  : spfunc := "000010";
  constant sp_undef_03  : spfunc := "000011";
  constant sp_sll       : spfunc := "000100";
  constant sp_undef_05  : spfunc := "000101";
  constant sp_srl       : spfunc := "000110";
  constant sp_sra       : spfunc := "000111";
  constant sp_undef_08  : spfunc := "001000";
  constant sp_undef_09  : spfunc := "001001";
  constant sp_undef_0A  : spfunc := "001010";
  constant sp_undef_0B  : spfunc := "001011";
  constant sp_undef_0C  : spfunc := "001100";
  constant sp_undef_0D  : spfunc := "001101";
  constant sp_undef_0E  : spfunc := "001110";
  constant sp_undef_0F  : spfunc := "001111";
	                 
  constant sp_sequ      : spfunc := "010000";
  constant sp_sneu      : spfunc := "010001";
  constant sp_sltu      : spfunc := "010010";
  constant sp_sgtu      : spfunc := "010011";
  constant sp_sleu      : spfunc := "010100";
  constant sp_sgeu      : spfunc := "010101";
  constant sp_undef_16  : spfunc := "010110";
  constant sp_undef_17  : spfunc := "010111";
  constant sp_undef_18  : spfunc := "011000";
  constant sp_undef_19  : spfunc := "011001";
  constant sp_undef_1A  : spfunc := "011010";
  constant sp_undef_1B  : spfunc := "011011";
  constant sp_undef_1C  : spfunc := "011100";
  constant sp_undef_1D  : spfunc := "011101";
  constant sp_undef_1E  : spfunc := "011110";
  constant sp_undef_1F  : spfunc := "011111";
			     
  constant sp_add       : spfunc := "100000";
  constant sp_addu      : spfunc := "100001";
  constant sp_sub       : spfunc := "100010";
  constant sp_subu      : spfunc := "100011";
  constant sp_and       : spfunc := "100100";
  constant sp_or        : spfunc := "100101";
  constant sp_xor       : spfunc := "100110";
  constant sp_undef_27  : spfunc := "100111";
  constant sp_seq       : spfunc := "101000";
  constant sp_sne       : spfunc := "101001";
  constant sp_slt       : spfunc := "101010";
  constant sp_sgt       : spfunc := "101011";
  constant sp_sle       : spfunc := "101100";
  constant sp_sge       : spfunc := "101101";
  constant sp_undef_2E  : spfunc := "101110";
  constant sp_undef_2F  : spfunc := "101111";
	                 
  constant sp_movi2s    : spfunc := "110000";
  constant sp_movs2i    : spfunc := "110001";
  constant sp_movf      : spfunc := "110010";
  constant sp_movd      : spfunc := "110011";
  constant sp_movfp2i   : spfunc := "110100";
  constant sp_movi2fp   : spfunc := "110101";
  constant sp_undef_36  : spfunc := "110110";
  constant sp_undef_37  : spfunc := "110111";
  constant sp_undef_38  : spfunc := "111000";
  constant sp_undef_39  : spfunc := "111001";
  constant sp_undef_3A  : spfunc := "111010";
  constant sp_undef_3B  : spfunc := "111011";
  constant sp_undef_3C  : spfunc := "111100";
  constant sp_undef_3D  : spfunc := "111101";
  constant sp_undef_3E  : spfunc := "111110";
  constant sp_nop       : spfunc := "111111";

  -- nicht implementiert			     
  constant fp_addf      : fpfunc := "00000";
  constant fp_subf      : fpfunc := "00001";
  constant fp_multf     : fpfunc := "00010";
  constant fp_divf      : fpfunc := "00011";
  constant fp_addd      : fpfunc := "00100";
  constant fp_subd      : fpfunc := "00101";
  constant fp_multd     : fpfunc := "00110";
  constant fp_divd      : fpfunc := "00111";
  constant fp_cvtf2d    : fpfunc := "01000";
  constant fp_cvtf2i    : fpfunc := "01001";
  constant fp_cvtd2f    : fpfunc := "01010";
  constant fp_cvtd2i    : fpfunc := "01011";
  constant fp_cvti2f    : fpfunc := "01100";
  constant fp_cvti2d    : fpfunc := "01101";
  constant fp_mult      : fpfunc := "01110";
  constant fp_div       : fpfunc := "01111";
	                 
  constant fp_eqf       : fpfunc := "10000";
  constant fp_nef       : fpfunc := "10001";
  constant fp_ltf       : fpfunc := "10010";
  constant fp_gtf       : fpfunc := "10011";
  constant fp_lef       : fpfunc := "10100";
  constant fp_gef       : fpfunc := "10101";
  constant fp_multu     : fpfunc := "10110";
  constant fp_divu      : fpfunc := "10111";
  constant fp_eqd       : fpfunc := "11000";
  constant fp_ned       : fpfunc := "11001";
  constant fp_ltd       : fpfunc := "11010";
  constant fp_gtd       : fpfunc := "11011";
  constant fp_led       : fpfunc := "11100";
  constant fp_ged       : fpfunc := "11101";
  constant fp_undef_1E  : fpfunc := "11110";
  constant fp_undef_1F  : fpfunc := "11111";

-- Code for ALU functions
-- constants for subtype Alu_func defined in package dlx_global
  constant alu_a        : alu_func := "0000";
  constant alu_b        : alu_func := "0001";
  constant alu_add      : alu_func := "0010";
  constant alu_sub      : alu_func := "0011";
  constant alu_and      : alu_func := "0100";
  constant alu_or       : alu_func := "0101";
  constant alu_xor      : alu_func := "0110";
  constant alu_sll      : alu_func := "0111";
  constant alu_srl      : alu_func := "1000";
  constant alu_sra      : alu_func := "1001";
  constant alu_slt      : alu_func := "1010";
  constant alu_sgt      : alu_func := "1011";
  constant alu_sle      : alu_func := "1100";
  constant alu_sge      : alu_func := "1101";
  constant alu_seq      : alu_func := "1110";
  constant alu_sne      : alu_func := "1111";
  
end dlx_opcode_package;
  
