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
-- DLX Instruction Cache Modul for 16-Bit RAM-Adresses.
-- Cacheline 128 Bit (4 DLX-Words a 32Bit) 
-- 32 Lines direct-mapped Cache.
-- ^^       ^^^^^^^^^^^^^
-- 
-- Addr-Bits: 111111
--            5432109876543210
--            ----------------
--            _______
--              Tag  _____
--                  Offset__
--                        Word
--                          __
--                          Byte
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
use work.dlx_global.all;


entity dlx_icache is
  port(
    clk          : in  std_logic;
    rst          : in  std_logic;
    
    ic_addr      : in  dlx_address;
    ic_data      : out dlx_word;
    ic_ready     : out std_logic;
    
    cache_line   : in  std_logic_vector( 0 to bw_cacheline-1 );
    ic_update    : in  std_logic;
    memctrl_busy : in  std_logic
  );
end dlx_icache;


-- ===================================================================
architecture behavior of dlx_icache is


  -- Component Deklarationen
  -- =======================
  component cache_memory
    generic(
      bit_width  : natural;
      addr_width : natural
    );
    port(
      clk :       in  std_logic;
      addr :      in  std_logic_vector(addr_width-1 downto 0);
      write :     in  std_logic;
      data_out :  out std_logic_vector(0 to  bit_width-1);
      data_in :   in  std_logic_vector(0 to  bit_width-1)
    ); 
  end component;

  
  -- Signale zur Ansteuerung der Cache RAMs-------------------------------------
  signal cmem_offset :  std_logic_vector( bw_ic_offset - 1 downto 0 );
  signal cmem_in     :  std_logic_vector( 0 to bw_cacheline + bw_ic_tag );
  signal cmem_out    :  std_logic_vector( 0 to bw_cacheline + bw_ic_tag );
  signal cmem_write  :  std_logic := '0';

  -- Signale zur Aufsplittung der Cache-RAM-Ausgänge ---------------------------
  signal cmem_tag    :  std_logic_vector( bw_ic_tag - 1 downto 0 );
  signal cmem_line   :  std_logic_vector( 0 to bw_cacheline - 1 );
  signal cmem_valid  :  std_logic;

  -- Signale zur Aufsplittung der Daten-Adresse --------------------------------
  signal addr_tag    :  std_logic_vector( bw_ic_tag - 1 downto 0 );
  signal addr_offset :  std_logic_vector( bw_ic_offset - 1 downto 0 );
  signal addr_word   :  std_logic_vector( 1 downto 0 );
  signal addr_byte   :  std_logic_vector( 1 downto 0 );

  -- algemeine Signale ---------------------------------------------------------
  signal cmem_hit    :  std_logic;

begin

  -- =================================================================
  -- Instanziierung des Cache-RAMs (fuer Tag, Cache-Line u. Vaild-Bit)
  -- =================================================================
  cmem_ram : cache_memory
    generic map(
      bit_width   => bw_cacheline+bw_ic_tag+1,
      addr_width  => bw_ic_offset
    )
    port map(
      clk       => clk,  
      addr      => addr_offset,
      data_out  => cmem_out,
      write     => cmem_write,  
      data_in   => cmem_in
    );


  -- =================================================================
  -- Aufsplittung des Cache-RAM-Ausgangs (Tag, Line u. Vaild-Bit)
  -- =================================================================
  cmem_valid  <= cmem_out( 0 );
  cmem_tag    <= cmem_out( 1 to bw_ic_tag);
  cmem_line   <= cmem_out( bw_ic_tag + 1 to bw_cacheline + bw_ic_tag );


  -- =================================================================
  -- Aufsplittung der Instruktions-Adresse (Tag, Offset, Word, Byte)
  -- =================================================================
  addr_tag    <= ic_addr( address_width - 1 downto address_width - bw_ic_tag );
  addr_offset <= ic_addr( address_width - bw_ic_tag - 1 downto 4 );
  addr_word   <= ic_addr( 3 downto 2 );
  addr_byte   <= ic_addr( 1 downto 0 );


  -- =================================================================
  -- Cache-Read-Access (nicht getaktet!)
  -- =================================================================
  cmem_read : process( cmem_valid, cmem_tag, cmem_line, 
                       addr_tag, addr_word )
    variable hit : std_logic;
  begin
    -- Hit Detection, Set0/Set1
    hit := '0';
    if cmem_valid = '1' and cmem_tag = addr_tag then
      hit := '1';
    end if;
    cmem_hit <= hit;

    -- Read Data Selection
    case addr_word is
      when "11" =>   ic_data <= cmem_line(96 to 127);
      when "10" =>   ic_data <= cmem_line(64 to  95);
      when "01" =>   ic_data <= cmem_line(32 to  63);
      when others => ic_data <= cmem_line( 0 to  31);
    end case;
  end process cmem_read;


  -- =================================================================
  -- Cache-Update-Access (nicht getaktet!)
  -- =================================================================
  cmem_in    <= '1' & addr_tag & cache_line;
  cmem_write <= ic_update;


  -- =================================================================
  -- Cache-Read/Write-Access completed (nicht getaktet!)
  -- =================================================================
  ic_ready   <= cmem_hit;

end behavior;
