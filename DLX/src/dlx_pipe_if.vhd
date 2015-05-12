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
-- DLX Pipeline: Instruction Fetch Stufe.
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
entity dlx_pipe_if is
  port (
  
    clk        : in std_logic;
    rst        : in std_logic;
    stall      : in std_logic;
    dc_wait    : in std_logic;

    id_npc     : in dlx_word_us;
    id_cond    : in std_logic;
    
    ic_data    : in  dlx_word;
    ic_addr    : out dlx_address;

    if_id_ir   : out dlx_word;
    if_id_npc  : out dlx_word_us
  );
end dlx_pipe_if;

-- ===================================================================
architecture behavior of dlx_pipe_if is

  signal pc : dlx_word_us := (others => '0');

begin

  -- kombinatorischer Anteil
  -- =======================
  ic_addr <= std_logic_vector( pc ); -- Adressierung des Instr.-Memories


  -- sequentieller Anteil
  -- ====================
  if_seq : process( clk )
    variable npc : dlx_word_us;
    
  begin
    if clk'event and clk = '1' then

      if rst = '1' then
        pc       <= X"00_00_00_00";
        if_id_ir <= X"00_00_00_3f";
      else
        -- Instruction Cache Miss: IF and ID-Stage must be stalled
        -- because of Branch-Instructions, the rest of the pipeline
        -- may continue to resolve data dependencies.
        -- ic_ready = '0' => stall = '1'
        
        if dc_wait = '0' and stall = '0' then
          if_id_ir <= ic_data;
          if id_cond = '0' then 
            npc := pc + 4; 
          elsif id_cond = '1' then 
            npc := id_npc;
          end if;
          if_id_npc <= npc;
          pc        <= npc;
        end if;

      end if;

    end if;
  end process if_seq;

end behavior;
