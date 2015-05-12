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
-- DLX Top-Level Module. Instantiates DLX-Pipeline, I-Cache, D-Cache
-- and Memory Controller.
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
use work.dlx_global.all;

entity dlx_cpu is
  port(
    -- algemeine Signal
    clk          : in  std_logic;
    rst          : in  std_logic;

    -- Kontroll Signale
    halt        : out std_logic;

    -- Externes Memory Interface
    mem_addr     : out dlx_address;
    mem_enable   : out std_logic;
    mem_ready    : in  std_logic;
    mem_rdata    : in  dlx_word;
    mem_wdata    : out dlx_word;
    mem_write    : out std_logic;
    mem_width    : out Mem_width
  );
end dlx_cpu;


-- ===================================================================
architecture struct of dlx_cpu is

  -- Component Deklarationen
  -- =======================
  component dlx_pipeline
  port(
    clk         : in  std_logic;
    rst         : in  std_logic;
    halt        : out std_logic;
    ic_data     : in  dlx_word;
    ic_ready    : in  std_logic;
    ic_addr     : out dlx_address;
    dc_rdata    : in  dlx_word;    
    dc_ready    : in  std_logic;
    dc_addr     : out dlx_address;
    dc_wdata    : out dlx_word;
    dc_enable   : out std_logic;
    dc_write    : out std_logic;
    dc_width    : out work.dlx_global.Mem_width
  ); 
  end component;


  component dlx_icache
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
  end component;


  component dlx_dcache
  port(
    clk          : in  std_logic;
    rst          : in  std_logic;
    dc_addr      : in  dlx_address;
    dc_rdata     : out dlx_word;
    dc_wdata     : in  dlx_word;
    dc_enable    : in  std_logic;
    dc_write     : in  std_logic;
    dc_width     : in  work.dlx_global.Mem_width;
    dc_ready     : out std_logic;
    cache_line   : in  std_logic_vector( 0 to bw_cacheline-1 );
    dc_update    : in  std_logic;
    memctrl_busy : in  std_logic
  );
  end component;


  component dlx_memctrl
  port(
    clk          : in  std_logic;
    rst          : in  std_logic;
    ic_addr      : in  dlx_address;
    ic_ready     : in  std_logic;
    dc_addr      : in  dlx_address;
    dc_wdata     : in  dlx_word;
    dc_enable    : in  std_logic;
    dc_write     : in  std_logic;
    dc_width     : in  work.dlx_global.Mem_width;
    dc_ready     : in  std_logic;
    cache_line   : out std_logic_vector( 0 to bw_cacheline-1 );
    ic_update    : out std_logic;
    dc_update    : out std_logic;
    memctrl_busy : out std_logic;
    mem_addr     : out dlx_address;
    mem_enable   : out std_logic;
    mem_ready    : in  std_logic;
    mem_rdata    : in  dlx_word;
    mem_wdata    : out dlx_word;
    mem_write    : out std_logic;
    mem_width    : out work.dlx_global.Mem_width
  );
  end component;

  -- Verbindungssignale --------------------------------------------------------
  signal ic_data      : dlx_word;
  signal ic_ready     : std_logic;
  signal ic_addr      : dlx_address;
  signal dc_rdata     : dlx_word;    
  signal dc_ready     : std_logic;
  signal dc_addr      : dlx_address;
  signal dc_wdata     : dlx_word;
  signal dc_enable    : std_logic;
  signal dc_write     : std_logic;
  signal dc_width     : work.dlx_global.Mem_width;
  signal cache_line   : std_logic_vector( 0 to bw_cacheline-1 );
  signal ic_update    : std_logic;
  signal dc_update    : std_logic;
  signal memctrl_busy : std_logic;

begin

  -- =================================================================
  -- Instanziierung der DLX-Pipeline
  -- =================================================================
  pip: dlx_pipeline
    port map(
      clk       => clk, 
      rst       => rst, 
      halt      => halt, 
      ic_data   => ic_data, 
      ic_ready  => ic_ready, 
      ic_addr   => ic_addr, 
      dc_rdata  => dc_rdata,  
      dc_ready  => dc_ready, 
      dc_addr   => dc_addr, 
      dc_wdata  => dc_wdata, 
      dc_enable => dc_enable, 
      dc_write  => dc_write, 
      dc_width  => dc_width
    ); 


  -- =================================================================
  -- Instanziierung des Instruction Caches
  -- =================================================================
  ic: dlx_icache
    port map(
      clk          => clk,
      rst          => rst,
      ic_addr      => ic_addr,
      ic_data      => ic_data,
      ic_ready     => ic_ready,
      cache_line   => cache_line,
      ic_update    => ic_update,
      memctrl_busy => memctrl_busy
    );


  -- =================================================================
  -- Instanziierung des Daten Caches
  -- =================================================================
  dc: dlx_dcache
    port map(
      clk          => clk,
      rst          => rst,
      dc_addr      => dc_addr,
      dc_rdata     => dc_rdata,
      dc_wdata     => dc_wdata,
      dc_enable    => dc_enable,
      dc_write     => dc_write,
      dc_width     => dc_width,
      dc_ready     => dc_ready,
      cache_line   => cache_line,
      dc_update    => dc_update,
      memctrl_busy => memctrl_busy
    );


  -- =================================================================
  -- Instanziierung des Memory Controllers
  -- =================================================================
  memctrl: dlx_memctrl
    port map(
      clk          => clk, 
      rst          => rst, 
      ic_addr      => ic_addr, 
      ic_ready     => ic_ready, 
      dc_addr      => dc_addr, 
      dc_wdata     => dc_wdata, 
      dc_enable    => dc_enable, 
      dc_write     => dc_write, 
      dc_width     => dc_width, 
      dc_ready     => dc_ready, 
      cache_line   => cache_line, 
      ic_update    => ic_update, 
      dc_update    => dc_update, 
      memctrl_busy => memctrl_busy, 
      mem_addr     => mem_addr, 
      mem_enable   => mem_enable, 
      mem_ready    => mem_ready, 
      mem_rdata    => mem_rdata, 
      mem_wdata    => mem_wdata, 
      mem_write    => mem_write, 
      mem_width    => mem_width
    );

end struct;
