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
use work.support_pk.all;

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
architecture struct of register_file is

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

  -- Signal Deklarationen
  -- ====================
  signal write :          std_logic;
  signal dummy1, dummy2 : std_logic_vector( 0 to 31 );

begin  
  -- =================================================================
  -- Instantiierung der FPGA-Rams
  -- =================================================================
	regf_port1 : generic_dual_port_dist_ram
	generic map(
		nr_of_words   => 32,
		bitwidth      => 32
	)
	port map(
		clk    => clk,

		wen_A  => write,
		a_A    => rd,
		d_A    => data_in,
		q_A    => open,

		a_B    => rs1,
		q_B    => a
	);

	regf_port2 : generic_dual_port_dist_ram
	generic map(
		nr_of_words   => 32,
		bitwidth      => 32
	)
	port map(
		clk    => clk,

		wen_A  => write,
		a_A    => rd,
		d_A    => data_in,
		q_A    => open,

		a_B    => rs2,
		q_B    => b
	);

--  regf_port1 : dpram32x32 port map(
--    a     => rd,
--    clk   => clk,
--    d     => data_in,
--    we    => write,
--    dpra  => rs1,
--    dpo   => a,
--    spo   => dummy1
--  );
--
--  regf_port2 : dpram32x32 port map(
--    a     => rd,
--    clk   => clk,
--    d     => data_in, 
--    we    => write,
--    dpra  => rs2,
--    dpo   => b,
--    spo   => dummy2
--  );

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
  
end struct;
