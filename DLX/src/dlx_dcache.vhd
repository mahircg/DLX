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
-- DLX Data Cache Modul for 16-Bit RAM-Adresses.
-- Cacheline 128 Bit (4 DLX-Words a 32Bit) 
-- 2x32 Lines 2-way associative Cache.
-- ^^^^       ^^^^^^^^^^^^^^^^^
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
-- $Date: 2002/06/18 09:36:09 $
-- $Revision: 2.1 $
-- 
-- ===================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dlx_global.all;
use work.dlx_cache_support.all;


entity dlx_dcache is
  port(
    clk          : in  std_logic;
    rst          : in  std_logic;
    
    dc_addr      : in  dlx_address;
    dc_rdata     : out dlx_word;
    dc_wdata     : in  dlx_word;
    dc_enable    : in  std_logic;
    dc_write     : in  std_logic;
    dc_width     : in  Mem_width;
    dc_ready     : out std_logic;
    
    cache_line   : in  std_logic_vector( 0 to bw_cacheline-1 );
    dc_update    : in  std_logic;
    memctrl_busy : in  std_logic
  );
end dlx_dcache;


-- ===================================================================
architecture behavior of dlx_dcache is


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
  signal setX_in     :  std_logic_vector( 0 to bw_cacheline + bw_dc_tag );
  signal set0_out    :  std_logic_vector( 0 to bw_cacheline + bw_dc_tag );
  signal set1_out    :  std_logic_vector( 0 to bw_cacheline + bw_dc_tag );
  signal set0_write  :  std_logic := '0';
  signal set1_write  :  std_logic := '0';

  -- Signale zur Aufsplittung der Cache-RAM-Ausg�ge ---------------------------
  signal set0_tag    :  std_logic_vector( bw_dc_tag - 1 downto 0 );
  signal set0_line   :  std_logic_vector( 0 to bw_cacheline - 1 );
  signal set0_valid  :  std_logic;
  signal set1_tag    :  std_logic_vector( bw_dc_tag-1 downto 0 );
  signal set1_line   :  std_logic_vector( 0 to bw_cacheline - 1 );
  signal set1_valid  :  std_logic;

  -- Signale zur Aufsplittung der Daten-Adresse --------------------------------
  signal addr_tag    :  std_logic_vector( bw_dc_tag - 1 downto 0 );
  signal addr_offset :  std_logic_vector( bw_dc_offset - 1 downto 0 );
  signal addr_word   :  std_logic_vector( 1 downto 0 );
  signal addr_byte   :  std_logic_vector( 1 downto 0 );

  -- algemeine Signale ---------------------------------------------------------
  signal set0_hit    :  std_logic;
  signal set1_hit    :  std_logic;

  -- LFSR for random-Bit Generation --------------------------------------------
  signal lfsr        :  std_logic_vector( 7 downto 0 );
  signal rand_bit    :  std_logic := '0';

begin

  -- =================================================================
  -- Instanziierung der Cache-RAMs (fuer Tag, Cache-Line u. Vaild-Bit)
  -- =================================================================
  set0_ram : cache_memory
    generic map(
      bit_width   => bw_cacheline+bw_dc_tag+1,
      addr_width  => bw_dc_offset
    )
    port map(
      clk       => clk,  
      addr      => addr_offset,
      data_out  => set0_out,
      write     => set0_write,  
      data_in   => setX_in
    );

  set1_ram : cache_memory
    generic map(
      bit_width   => bw_cacheline+bw_dc_tag+1,
      addr_width  => bw_dc_offset
    )
    port map(
      clk       => clk,  
      addr      => addr_offset,
      data_out  => set1_out,
      write     => set1_write,  
      data_in   => setX_in
    );


  -- =================================================================
  -- Aufsplittung der Cache-RAM-Ausg�ge (Tag, Line u. Vaild-Bit)
  -- =================================================================
  set0_valid  <= set0_out( 0 );
  set0_tag    <= set0_out( 1 to bw_dc_tag );
  set0_line   <= set0_out( bw_dc_tag + 1 to bw_cacheline + bw_dc_tag );
  set1_valid  <= set1_out( 0 );
  set1_tag    <= set1_out( 1 to bw_dc_tag );
  set1_line   <= set1_out( bw_dc_tag + 1 to bw_cacheline + bw_dc_tag );


  -- =================================================================
  -- Aufsplittung der Daten-Adresse (Tag, Offset, Word, Byte)
  -- =================================================================
  addr_tag    <= dc_addr( address_width - 1 downto address_width - bw_dc_tag );
  addr_offset <= dc_addr( address_width - bw_dc_tag - 1 downto 4 );
  addr_word   <= dc_addr( 3 downto 2 );
  addr_byte   <= dc_addr( 1 downto 0 );


  -- =================================================================
  -- Cache-Read-Access (nicht getaktet!)
  -- =================================================================

	-- ===========================================
	-- Your code goes here:
	
	read_process: process(dc_write,dc_enable,dc_width, -- DXL signals & memory controller
						  addr_tag,addr_word,addr_byte, -- address signals
						  set0_tag,set0_valid,set0_line, -- 1st line of set
						  set1_tag,set1_valid,set1_line) -- 2nd line of set
	variable hit0 : std_logic ;
	variable hit1 : std_logic ;
	begin
		
		hit0 := '0';
		hit1 := '0';
		-- determine hit or miss
		if (addr_tag= set0_tag and set0_valid= '1') then -- valid data is in first line of the selected set
				hit0:='1'; -- hit!!!
		elsif(addr_tag= set1_tag and set1_valid='1') then -- valid data is in second line of the selected set
				hit1:='1';  -- hit!!!
		else 
			null;
		end if;-- else ???

		if (dc_write='0' and dc_enable='1') then -- if read request and memory controller is not busy
		   -- dc_ready<='0'; -- by default cache is not ready
			if hit0 ='1' then -- valid data is in first line of the selected set
				dc_rdata<=align(set0_line, addr_word, addr_byte, dc_width); -- return aligned byte to DXL read bus
				--dc_ready<= '1';-- inform DXL cache is ready
			elsif hit1 ='1' then -- valid data is in second line of the selected set	
				dc_rdata<=align(set1_line, addr_word, addr_byte, dc_width); -- return aligned byte to DXL read bus
				--dc_ready<= '1';-- inform DXL cache is ready
			else
				dc_rdata <= (others => 'X');
			end if;-- else ???
		end if;	-- else write request
		
	set0_hit <= hit0;
	set1_hit <= hit1;
	end process read_process;
	-- !!!! this process drives set#_hit signals and dc_rdata !!!!	
	
	-- END.
	-- ===========================================


  -- =================================================================
  -- Cache-Update-Access (nicht getaktet!) not clocked!
  -- =================================================================

	-- ===========================================
	-- Your code goes here:
	
	update_process: process(dc_write,dc_enable,dc_width, -- DXL signals
							dc_update,cache_line,memctrl_busy, -- memory signals
							addr_tag,addr_word,addr_byte, -- address signals
							set0_hit,set1_hit,
							set0_tag,set0_line,set0_valid, -- 1st line of set
							set1_tag,set1_line,set1_valid) -- 2nd line of set
	begin
		set0_write<='0'; -- set ram0 write enable=0 by default
		set1_write<='0'; -- set ram1 write enable=0 by default
		
		-- check for write request:
		if ( dc_write='1' and dc_enable='1' and memctrl_busy/='1') then -- it's a write request and memory controller isn't busy
		    -- in case of write hit update proper cache line :
			if set0_hit='1' then 
				setX_in <= '1'& addr_tag& update(set0_line,dc_wdata,addr_word,addr_byte,dc_width);-- update line0
				set0_write <= '1';-- write enable to ram0
			elsif set1_hit='1' then 
				setX_in <= '1'& addr_tag& update(set1_line,dc_wdata,addr_word,addr_byte,dc_width);-- update line1
				set1_write <= '1';-- write enable to ram1
			else
				null;
			end if;
  	   end if;-- don't do anything i case of write miss 
 	    
 	    
		if dc_update='1' and dc_write='0' then -- in case of read miss update cache
		    -- update random cache line:
			setX_in <= '1'& addr_tag& cache_line;
			set0_write<=not rand_bit;
			set1_write<=rand_bit;      
		end if;
	end process update_process;
	-- !!!! this process drives set#_write signals and setX_in !!!!
	
	-- END.
	-- ===========================================

  -- =================================================================
  -- Cache-Read/Write-Access completed (nicht getaktet!) not clocked!
  -- =================================================================

	-- ===========================================
	-- Your code goes here:
	ready_process: process(dc_enable,set0_hit,set1_hit,dc_write)
	begin
	  --dc_ready='1';
		if (set0_hit='0' and set1_hit='0') and dc_enable='1' and dc_write='0' then -- stall only if read miss
			dc_ready<='0';
		else 
			dc_ready<='1'; 
    end if;
	end process ready_process;
	-- this process drives dc_ready signal
	
	-- END.
	-- ===========================================


  -- =================================================================
  -- Linear Feedback Shift Register, LFSR (getaktet!)  clocked!
  -- =================================================================
  --rand_bit <= '0';
      
	-- ===========================================
	-- Your code goes here:
	LFSR_process: process(clk)
	begin
		if(rising_edge(clk)) then
			if rst='1' then
			   lfsr<= x"00";
			   rand_bit <= '0';
			else
				rand_bit <= lfsr(0);
				lfsr(0) <= lfsr(1);
				lfsr(1) <= lfsr(2);
				lfsr(2) <= lfsr(3);
				lfsr(3) <= lfsr(4);
				lfsr(4) <= lfsr(5);
				lfsr(5) <= lfsr(6);
				lfsr(6) <= lfsr(7);
				lfsr(7) <= '1' xor lfsr(1) xor lfsr(5) xor lfsr(7) ;
			end if;
	end if;
	end process LFSR_process;
	
	-- END.
	-- ===========================================

end behavior;
