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
-- DLX Pipeline, Instanziierung der einzelnen Pipeline-Stufen.
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
use work.dlx_opcode_package.all;
-- synopsys translate_off
use work.dlx_debug.all;
-- synopsys translate_on
use work.dlx_pipe_if;
use work.dlx_pipe_id;
use work.dlx_pipe_ex;
use work.dlx_pipe_mem;
use work.dlx_pipe_ctrl;



entity dlx_pipeline is
  port(

    -- algemeine Signal
    clk         : in  std_logic;
    rst         : in  std_logic;
    
    -- Kontroll Signale
    halt        : out std_logic;
 
    -- Instruction Memory
    ic_data     : in  dlx_word;
    ic_ready    : in  std_logic;
    ic_addr      : out dlx_address;
        
    -- Data Memory 
    dc_rdata    : in  dlx_word;    
    dc_ready    : in  std_logic;

    dc_addr     : out dlx_address;
    dc_wdata    : out dlx_word;

    dc_enable   : out std_logic;
    dc_write    : out std_logic;
    dc_width    : out Mem_width
    
  ); 
end dlx_pipeline;


-- ===================================================================
architecture behavior of dlx_pipeline is

  -- Component Deklarationen
  -- =======================
  component register_file
  port (
    clk     : in  std_logic;
    we      : in  std_logic;
    rs1     : in  std_logic_vector(0 to 4);
    rs2     : in  std_logic_vector(0 to 4);
    rd      : in  std_logic_vector(0 to 4);
    data_in : in  dlx_word;

    a       : out dlx_word;
    b       : out dlx_word
  );
  end component;


  component dlx_pipe_if
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    stall      : in  std_logic;
    dc_wait    : in  std_logic;

    id_npc     : in  dlx_word_us;
    id_cond    : in  std_logic;
    
    ic_data    : in  dlx_word;
    ic_addr    : out dlx_address;

    if_id_ir   : out dlx_word;
    if_id_npc  : out dlx_word_us
  );
  end component;


  component dlx_pipe_id
  port (
    clk                : in  std_logic;
    rst                : in  std_logic;
    stall              : in  std_logic; 
    dc_wait            : in  std_logic;
      
    if_id_npc          : in  dlx_word_us;
    if_id_ir           : in  dlx_word;

    id_a               : in  dlx_word;
    id_b               : in  dlx_word;                   
    
    id_opcode_class    : out Opcode_class;    
    id_ir_rs1          : out Regadr;
    id_ir_rs2          : out Regadr;
    id_a_fwd_sel       : in  Forward_select; 
    ex_mem_alu_out     : in  dlx_word;

    id_cond            : out std_logic;
    id_npc             : out dlx_word_us;
    id_illegal_instr   : out std_logic;
    id_halt            : out std_logic;

    id_ex_a            : out dlx_word;
    id_ex_b            : out dlx_word;
    id_ex_imm          : out Imm17;
    id_ex_alu_func     : out Alu_func; 
    id_ex_alu_opb_sel  : out std_logic;
    id_ex_dm_en        : out std_logic;
    id_ex_dm_wen       : out std_logic;
    id_ex_dm_width     : out Mem_width;
    id_ex_us_sel       : out std_logic;
    id_ex_data_sel     : out std_logic;
    id_ex_reg_rd       : out RegAdr;
    id_ex_reg_wen      : out std_logic;
    id_ex_opcode_class : out Opcode_class;
    id_ex_ir_rs1       : out RegAdr;
    id_ex_ir_rs2       : out RegAdr
  );
  end component;


  component dlx_pipe_ex
  port (
    clk                 : in  std_logic;
    rst                 : in  std_logic;
    dc_wait             : in  std_logic;

    id_ex_a             : in  dlx_word;
    id_ex_b             : in  dlx_word;
    id_ex_imm           : in  Imm17;
    id_ex_alu_func      : in  Alu_func;
    id_ex_alu_opb_sel   : in  std_logic;
    id_ex_dm_en         : in  std_logic;
    id_ex_dm_wen        : in  std_logic;
    id_ex_dm_width      : in  Mem_width; 
    id_ex_us_sel        : in  std_logic;
    id_ex_data_sel      : in  std_logic;
    id_ex_reg_rd        : in  RegAdr; 
    id_ex_reg_wen       : in  std_logic;
    id_ex_opcode_class  : in  Opcode_class;
    id_ex_ir_rs1        : in  RegAdr; 
    id_ex_ir_rs2        : in  RegAdr;      
    mem_wb_data         : in  dlx_word;
   
    ex_alu_opa_sel      : in  Forward_select; 
    ex_alu_opb_sel      : in  Forward_select;
    ex_dm_data_sel      : in  Forward_select;
    
    ex_mem_alu_out      : out dlx_word;
    ex_mem_dm_en        : out std_logic;
    ex_mem_dm_data      : out dlx_word;
    ex_mem_dm_width     : out Mem_width;
    ex_mem_dm_wen       : out std_logic;     
    ex_mem_us_sel       : out std_logic;
    ex_mem_data_sel     : out std_logic;
    ex_mem_reg_rd       : out RegAdr;
    ex_mem_reg_wen      : out std_logic;
    ex_mem_opcode_class : out Opcode_class
  );
  end component;


  component dlx_pipe_mem
  port (
    clk                 : in  std_logic;
    rst                 : in  std_logic;
    dc_wait             : in  std_logic;
    
    dc_rdata            : in  dlx_word;

    ex_mem_alu_out      : in  dlx_word;
    ex_mem_dm_width     : in  Mem_width;
    ex_mem_us_sel       : in  std_logic;
    ex_mem_data_sel     : in  std_logic; 
    ex_mem_reg_rd       : in  RegAdr;
    ex_mem_opcode_class : in  Opcode_class;
    
    mem_wb_opcode_class : out Opcode_class;
    mem_wb_reg_rd       : out RegAdr;
    mem_wb_data         : out dlx_word;
    
    mem_data            : out dlx_word

  );
  end component;


  component dlx_pipe_ctrl
  port(
      
    id_ir_rs1           : in  RegAdr;
    id_ir_rs2           : in  RegAdr;
    id_opcode_class     : in  Opcode_class;
    
    id_ex_opcode_class  : in  Opcode_class;
    id_ex_ir_rs1        : in  RegAdr;
    id_ex_ir_rs2        : in  RegAdr;
    id_ex_reg_rd        : in  RegAdr;

    ex_mem_opcode_class : in  Opcode_class;
    ex_mem_reg_rd       : in  RegAdr;

    mem_wb_opcode_class : in  Opcode_class;
    mem_wb_reg_rd       : in  RegAdr;
    
    ic_ready            : in  std_logic;    
    dc_ready            : in  std_logic;    

    id_a_fwd_sel        : out Forward_select;
    ex_alu_opa_sel      : out Forward_select;
    ex_alu_opb_sel      : out Forward_select;
    ex_dm_data_sel      : out Forward_select;
    stall               : out std_logic;
    dc_wait             : out std_logic
    
  );
  end component;


  -- algemeine Signale ---------------------------------------------------------
  signal stall              : std_logic;
  signal dc_wait            : std_logic;

  -- IF-Pipeline-Stufe
  signal if_id_ir           : dlx_word;
  signal if_id_npc          : dlx_word_us;
  

  -- ID-Pipeline-Stufe ---------------------------------------------------------
  signal id_ex_a            : dlx_word;
  signal id_ex_b            : dlx_word;

  signal id_ex_imm          : Imm17;
  signal id_ex_alu_func     : Alu_func;
  signal id_ex_alu_opb_sel  : std_logic;

  signal id_ex_dm_en        : std_logic;
  signal id_ex_dm_wen       : std_logic;
  signal id_ex_dm_width     : Mem_width;

  signal id_ex_us_sel       : std_logic;
  signal id_ex_data_sel     : std_logic;
  signal id_ex_reg_wen      : std_logic := '0';
  signal id_ex_reg_rd       : Regadr;

  signal id_ex_opcode_class : Opcode_class;
  signal id_ex_ir_rs1       : Regadr;
  signal id_ex_ir_rs2       : Regadr;

  signal id_npc             : dlx_word_us;
  signal id_a               : dlx_word;
  signal id_b               : dlx_word;
  signal id_a_fwd_sel       : Forward_select;
  signal id_cond            : std_logic;
  signal id_illegal_instr   : std_logic;
  signal id_opcode_class    : Opcode_class;
  signal id_ir_rs1          : Regadr;
  signal id_ir_rs2          : Regadr;  
 

  -- EX-Pipeline-Stufe ---------------------------------------------------------
  signal ex_mem_opcode_class: Opcode_class;

  signal ex_mem_alu_out     : dlx_word;
  signal ex_mem_dm_data     : dlx_word;
  signal ex_mem_dm_en       : std_logic;
  signal ex_mem_dm_wen      : std_logic;
  signal ex_mem_dm_width    : Mem_width;


  signal ex_mem_us_sel      : std_logic;
  signal ex_mem_data_sel    : std_logic;
  signal ex_mem_reg_rd      : Regadr;
  signal ex_mem_reg_wen     : std_logic := '0';

  signal ex_alu_opa_sel     : Forward_select;
  signal ex_alu_opb_sel     : Forward_select;
  signal ex_dm_data_sel     : Forward_select;
  

  -- MEM-Pipeline-Stufe --------------------------------------------------------
  signal mem_wb_reg_rd      : Regadr;
  signal mem_wb_opcode_class: Opcode_class;
  signal mem_wb_data        : dlx_word;
  signal mem_data           : dlx_word;
 
  
begin

  -- =================================================================
  -- Instanziierung des Register-Files
  -- =================================================================
  reg_file : register_file
    port map(
      clk     => clk,
      rs1     => id_ir_rs1,
      rs2     => id_ir_rs2,
      rd      => ex_mem_reg_rd,
      we      => ex_mem_reg_wen,
      data_in => mem_data,
      a       => id_a,
      b       => id_b
    );


  -- =================================================================
  -- Instanziierung der Instruction-Fetch Stufe
  -- =================================================================

      -- Instruction Cache Miss: IF and ID-Stage must be stalled
      -- because of Branch-Instructions, the rest of the pipeline
      -- may continue to resolve data dependencies.
      -- ic_ready = '0' => stall = '1'

  if_stage : dlx_pipe_if
    port map(
  
      clk         => clk,
      rst         => rst,
      stall       => stall,
      dc_wait     => dc_wait,

      id_npc      => id_npc,
      id_cond     => id_cond,
     
      ic_addr     => ic_addr,
      ic_data     => ic_data,

      if_id_ir    => if_id_ir,
      if_id_npc   => if_id_npc
    );
    
    

  -- =================================================================
  -- Instanziierung der Instruction-Decode Stufe
  -- =================================================================
  id_stage : dlx_pipe_id
    port map(
 
      clk                  => clk,
      rst                  => rst,
      stall                => stall,
      dc_wait              => dc_wait,

      if_id_npc            => if_id_npc,
      if_id_ir             => if_id_ir,
      ex_mem_alu_out       => ex_mem_alu_out,

      id_a_fwd_sel         => id_a_fwd_sel,
      id_a                 => id_a,
      id_b                 => id_b,

      id_cond              => id_cond,
      id_npc               => id_npc,
      id_illegal_instr     => id_illegal_instr,
      id_halt              => halt,
      id_ir_rs1            => id_ir_rs1,
      id_ir_rs2            => id_ir_rs2,
      id_opcode_class      => id_opcode_class,

      id_ex_a              => id_ex_a,
      id_ex_b              => id_ex_b,
      id_ex_imm            => id_ex_imm,
      id_ex_alu_func       => id_ex_alu_func,
      id_ex_alu_opb_sel    => id_ex_alu_opb_sel,
      id_ex_dm_en          => id_ex_dm_en,
      id_ex_dm_wen         => id_ex_dm_wen,
      id_ex_dm_width       => id_ex_dm_width,
      id_ex_us_sel         => id_ex_us_sel,
      id_ex_data_sel       => id_ex_data_sel,
      id_ex_reg_rd         => id_ex_reg_rd,
      id_ex_reg_wen        => id_ex_reg_wen,
      id_ex_opcode_class   => id_ex_opcode_class,
      id_ex_ir_rs1         => id_ex_ir_rs1,
      id_ex_ir_rs2         => id_ex_ir_rs2
    );
    

  -- =================================================================
  -- Instanziierung der Execution Stufe
  -- =================================================================
  ex_stage : dlx_pipe_ex
    port map(
    
      clk                  => clk,
      rst                  => rst,
      dc_wait              => dc_wait,
 
      id_ex_a              => id_ex_a,
      id_ex_b              => id_ex_b,
      id_ex_imm            => id_ex_imm,
      id_ex_alu_func       => id_ex_alu_func,
      id_ex_alu_opb_sel    => id_ex_alu_opb_sel,
      id_ex_dm_en          => id_ex_dm_en,
      id_ex_dm_wen         => id_ex_dm_wen,
      id_ex_dm_width       => id_ex_dm_width,
      id_ex_us_sel         => id_ex_us_sel,
      id_ex_data_sel       => id_ex_data_sel,
      id_ex_reg_rd         => id_ex_reg_rd,
      id_ex_reg_wen        => id_ex_reg_wen,
      id_ex_opcode_class   => id_ex_opcode_class,
      id_ex_ir_rs1         => id_ex_ir_rs1,
      id_ex_ir_rs2         => id_ex_ir_rs2,
      mem_wb_data          => mem_wb_data,
 
      ex_alu_opa_sel       => ex_alu_opa_sel,
      ex_alu_opb_sel       => ex_alu_opb_sel,
      ex_dm_data_sel       => ex_dm_data_sel,
 
      ex_mem_alu_out       => ex_mem_alu_out,
      ex_mem_dm_en         => ex_mem_dm_en,
      ex_mem_dm_data       => ex_mem_dm_data,
      ex_mem_dm_width      => ex_mem_dm_width,
      ex_mem_dm_wen        => ex_mem_dm_wen,
      ex_mem_us_sel        => ex_mem_us_sel,
      ex_mem_data_sel      => ex_mem_data_sel,
      ex_mem_reg_rd        => ex_mem_reg_rd,
      ex_mem_reg_wen       => ex_mem_reg_wen,
      ex_mem_opcode_class  => ex_mem_opcode_class
    );
    

  -- =================================================================
  -- Instanziierung der Memory Stufe
  -- =================================================================
  mem_stage : dlx_pipe_mem
    port map(

      clk                  => clk,
      rst                  => rst,
      dc_wait              => dc_wait,

      dc_rdata             => dc_rdata,

      ex_mem_alu_out       => ex_mem_alu_out,
      ex_mem_dm_width      => ex_mem_dm_width,
      ex_mem_us_sel        => ex_mem_us_sel,
      ex_mem_data_sel      => ex_mem_data_sel,
      ex_mem_reg_rd        => ex_mem_reg_rd,
      ex_mem_opcode_class  => ex_mem_opcode_class,

      mem_wb_data          => mem_wb_data,
      mem_wb_opcode_class  => mem_wb_opcode_class,
      mem_wb_reg_rd        => mem_wb_reg_rd,
      
      mem_data             => mem_data
    );
    
        
  -- =================================================================
  -- Instanziierung des Pipeline-Controllers
  -- =================================================================

      -- Instruction Cache Miss: IF and ID-Stage must be stalled
      -- because of Branch-Instructions, the rest of the pipeline
      -- may continue to resolve data dependencies.
      -- ic_ready = '0' => stall = '1'

  pipe_ctrl : dlx_pipe_ctrl
    port map(
      
      id_ir_rs1            => id_ir_rs1,
      id_ir_rs2            => id_ir_rs2,
      id_opcode_class      => id_opcode_class,
      
      id_ex_opcode_class   => id_ex_opcode_class,
      id_ex_ir_rs1         => id_ex_ir_rs1,
      id_ex_ir_rs2         => id_ex_ir_rs2,
      id_ex_reg_rd         => id_ex_reg_rd,
      
      ex_mem_opcode_class  => ex_mem_opcode_class,
      ex_mem_reg_rd        => ex_mem_reg_rd,
      
      mem_wb_opcode_class  => mem_wb_opcode_class,
      mem_wb_reg_rd        => mem_wb_reg_rd,
      
      ic_ready             => ic_ready,       
      dc_ready             => dc_ready,       

      id_a_fwd_sel         => id_a_fwd_sel,
      ex_alu_opa_sel       => ex_alu_opa_sel,
      ex_alu_opb_sel       => ex_alu_opb_sel,
      ex_dm_data_sel       => ex_dm_data_sel,
      stall                => stall,
      dc_wait              => dc_wait
    );  

  
  -- Signalzuweisung der primaeren Ausgaengen
  dc_wdata   <= ex_mem_dm_data;
  dc_addr    <= ex_mem_alu_out;
  dc_enable  <= ex_mem_dm_en;
  dc_write   <= ex_mem_dm_wen;
  dc_width   <= ex_mem_dm_width;

end behavior;
