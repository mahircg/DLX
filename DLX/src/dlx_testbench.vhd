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
-- DLX Testumgebung. Taktgenerierung, ideales RAM fuer DLX-Pipeline
-- ohne Cache Module. Das auszufuehrende Assembler-Programm wird 
-- als Memory-Image aus einer Datei gelesen (siehe Generic 
-- ram_image_file). Der Test ist beendet, wenn die DLX-Pipeline
-- eine Halt (Signal halt = '1') meldet.
-- 
-- ===================================================================
--
-- $Author: gilbert $
-- $Date: 2002/06/18 09:27:04 $
-- $Revision: 2.0 $
-- 
-- ===================================================================
--
-- $Author: wasenmueller $
-- $Date: 2014/04/28 $
-- $Revision: 2.1 $
-- Some comments added
--
-- ===================================================================

library ieee;
use std.textio.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.dlx_global.all;

entity dlx_tb is
  generic(
						
		ram_image_file :  string  := "E:\backup_PC\Documents\Kaiserslautern\Embedded_Processor_Lab\EMPLab_15\DLX\asm\sieb_forw.out";
    --ram_image_file :  string  := "C:\Users\Mahircan\Ders\embedded_processor_lab\EMPLab_15\DLX\asm\sieb_forw.out";
                                 -- Take care to choose the right file and take 
                                 -- care to choose the proper path for ram_image_file!
    clk_period :      time    := 50 ns
  );
end dlx_tb;


-- ===================================================================
architecture sim of dlx_tb is

  -- Constant Deklarationen
  -- ======================
  constant max_addr : integer := 2**(address_width-2)-1;
  -- =================================================================


  -- Typen Deklarationen
  -- ===================
  type ram_type is array( 0 to max_addr ) of dlx_word;
  -- =================================================================

  
  -- Procedure Deklarationen
  -- =======================
  procedure load_ram ( 
    variable        r :  inout ram_type; 
    constant filename :  in    string
  ) is
  
    file     source          : text open read_mode is filename;
    variable inline, outline : line;
    variable testline        : line;
    variable c               : character;
    variable space           : string(1 to 1);
    variable addr32          : dlx_address;
    variable data            : dlx_word;
    variable addr_int        : natural;

  begin
    write(outline, string'("Lade Ram-Datei ..."));
    writeline(output, outline);
    
    while not endfile(source) loop
      readline(source, inline);
      testline := new string(1 to inline'length);
      testline.all := inline.all; 
      read(testline, c );
      
      if c /= '#' then
        hread(inline, addr32);
        read(inline, space);
        hread(inline, data);
        addr_int := to_integer(unsigned(addr32(31 downto 2)));
        assert addr_int <= 2**(address_width-2) - 1
          report "Illegale Adresse beim Laden des Testprogramms!"
          severity failure;
        r(addr_int) := data;
      end if;
      
    end loop;
    write(outline, string'("fertig!"));
    writeline(output, outline);
  end load_ram;
  -- =================================================================


  -- Component Deklarationen
  -- =======================
  component dlx_pipeline
    port(
      clk         : in  std_logic;
      rst         : in  std_logic;
      halt        : out std_logic;
      ic_data     : in  dlx_word;
      ic_ready    : in  std_logic;
      ic_addr      : out dlx_address;
      dc_rdata    : in  dlx_word;    
      dc_ready    : in  std_logic;
      dc_addr      : out dlx_address;
      dc_wdata    : out dlx_word;
      dc_enable   : out std_logic;
      dc_write    : out std_logic;
      dc_width    : out Mem_width
    ); 
  end component;
  -- =================================================================


  -- algemeine Signale ---------------------------------------------------------
  signal clk, rst    : std_logic;
  signal halt        : std_logic;

  signal ic_addr     : dlx_address;
  signal ic_data     : dlx_word;
  signal ic_ready    : std_logic;

  signal dc_addr     : dlx_address;
  signal dc_rdata    : dlx_word;
  signal dc_wdata    : dlx_word;
  signal dc_enable   : std_logic;
  signal dc_write    : std_logic;
  signal dc_ready    : std_logic;
  signal dc_width    : mem_width;     

-- ===================================================================

begin

  -- =================================================================
  -- Instanziierung der DLX-Pipeline
  -- =================================================================
  dut : dlx_pipeline
    port map(
      clk         => clk,
      rst         => rst,
      halt        => halt,
      ic_addr     => ic_addr,
      ic_data     => ic_data,
      ic_ready    => ic_ready,
      dc_addr     => dc_addr,
      dc_enable   => dc_enable,
      dc_write    => dc_write,
      dc_rdata    => dc_rdata,
      dc_wdata    => dc_wdata,
      dc_width    => dc_width,
      dc_ready    => dc_ready
    );
  

  -- =================================================================
  -- Simulation des Speicher-Verhaltens
  -- =================================================================
  mem : process
    variable ram       : ram_type;
    variable addr_word : natural;
    variable tmp       : std_logic_vector( 0 to 31 );
    
  begin 
    ic_ready <= '1';
    dc_ready <= '1';

    -- Initialisierung
    load_ram( ram, ram_image_file );

    -- Die schreibfunktion wird fuer 50 ns abgeschaltet.
    -- Dadurch soll verhindert werden, dass durch die Initialisierung
    -- aller Signale durch den Simulator, der gesamte Speicher ge-
    -- loescht wird.
    wait for 50 ns;
    
    ram_service : loop
      wait on ic_addr, dc_addr, dc_enable, clk;

        -- Write Data Memory
      if clk'event and clk='1' then
        if is_X( dc_enable ) or (dc_enable='1' and is_X( dc_write )) then
          -- Steuersignal unknown => komplettes RAM auf "X"-en
          assert false
            report "RAM Steuersignale enthalten 'X'"
            severity error;
          for i in 0 to max_addr loop
            ram( i ) := (others => 'X');
          end loop;
        elsif dc_enable = '1' and dc_write = '1' then
          if is_X( dc_addr ) then
            -- Adressleitung unknown => komplettes RAM auf "X"-en
            assert false
              report "RAM Steuersignale enthalten 'X'"
              severity error;
            for i in 0 to max_addr loop
              ram( i ) := (others => 'X');
            end loop;
          else
            addr_word :=to_integer(unsigned(dc_addr(address_width-1 downto 2)));
            case dc_width is
    
              when MEM_WIDTH_WORD => 
                ram( addr_word ) := dc_wdata;
              
              when MEM_WIDTH_HALFWORD => 
                if dc_addr(1) = '0' then
                  ram(addr_word)( 0 to 15) := dc_wdata(16 to 31);
                else
                  ram(addr_word)(16 to 31) := dc_wdata(16 to 31);            
                end if;
                
              when MEM_WIDTH_BYTE => 
                case dc_addr(1 downto 0) is
                  when "00" =>
                    ram(addr_word)( 0 to  7) := dc_wdata(24 to 31);
                 when "01" =>
                    ram(addr_word)( 8 to 15) := dc_wdata(24 to 31);
                 when "10" =>
                    ram(addr_word)(16 to 23) := dc_wdata(24 to 31);
                 when others =>
                    ram(addr_word)(24 to 31) := dc_wdata(24 to 31);
                end case;
                
              when others => 
                assert false
                report "Fehlerhafte Angabe fuer Wortbreite beim Schreiben!"
                severity failure;
            end case;
          end if;
        end if;
      end if;

      if is_X( ic_addr ) then
        ic_data <= (others => 'X');
      else
        -- Read Instruction Memory
        addr_word := to_integer( unsigned(ic_addr(address_width-1 downto 2)) );
        ic_data <= ram( addr_word );
      end if;

      if is_X( dc_addr ) or  is_X(dc_enable) or dc_enable = '0' then
        dc_rdata <= (others => 'X');
      elsif dc_enable = '1' then
        -- Read Data Memory
        addr_word := to_integer( unsigned( dc_addr(address_width-1 downto 2)));
      
        case dc_width is

          when MEM_WIDTH_WORD => 
            dc_rdata <= ram( addr_word );
        
          when MEM_WIDTH_HALFWORD => 
            if dc_addr(1) = '0' then
              dc_rdata(16 to 31) <= ram(addr_word)( 0 to 15);
            else
              dc_rdata(16 to 31) <= ram(addr_word)(16 to 31);            
            end if;
          
          when MEM_WIDTH_BYTE => 
            case dc_addr(1 downto 0) is
              when "00" =>
                dc_rdata(24 to 31) <= ram(addr_word)( 0 to  7);
             when "01" =>
                dc_rdata(24 to 31) <= ram(addr_word)( 8 to 15);
             when "10" =>
                dc_rdata(24 to 31) <= ram(addr_word)(16 to 23);
             when others =>
                dc_rdata(24 to 31) <= ram(addr_word)(24 to 31);
            end case;
          
          when others => 
            assert false
            report "Fehlerhafte Angabe fuer Wortbreite beim Lesen!"
            severity failure;
        end case;
      end if;

    end loop;
  end process mem;

  
  -- =================================================================
  -- Generierung des Systemtakts
  -- =================================================================
  clock : process
  begin
    clk <= '0';
    loop
      wait for clk_period / 2;
      clk <= not clk;
    end loop;
  end process clock;


  -- =================================================================
  -- Ablauf der Simulation
  -- =================================================================
  sim : process

  begin
    rst      <= '1', '0' after 5*clk_period / 3;
    wait until halt = '1';

    assert false
      report "Simulation beendet!"
      severity failure;

  end process sim;

end sim;


