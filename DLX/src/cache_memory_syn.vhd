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
use work.support_pk.all;

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
architecture struct of cache_memory is
  
	component generic_dual_port_dist_ram
    generic(
		nr_of_words       : integer;
		bitwidth          : integer
	);
    port(
		clk : in std_logic;

		wen_A : in  std_logic;
	
		a_A :   in  std_logic_vector( unsigned_num_bits(nr_of_words-1)-1 downto 0 );
		d_A :   in  std_logic_vector( bitwidth-1 downto 0 );
		q_A :   out std_logic_vector( bitwidth-1 downto 0 );

		a_B :   in  std_logic_vector( unsigned_num_bits(nr_of_words-1)-1 downto 0 );
		q_B :   out std_logic_vector( bitwidth-1 downto 0 )
	);
	end component;
begin

	cache_ram : generic_dual_port_dist_ram
	generic map(
		nr_of_words   => addr_width**2,
		bitwidth      => bit_width
	)
	port map(
		clk    => clk,

		wen_A  => write,
		a_A    => addr,
		d_A    => data_in,
		q_A    => open,

		a_B    => addr,
		q_B    => data_out
	);
  
end struct;
