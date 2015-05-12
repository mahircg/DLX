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
-- DLX Pipeline: Instruction Decode Stufe.
-- 
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
use work.dlx_opcode_package.all;
-- synopsys translate_off
use work.dlx_debug.all;
-- synopsys translate_on

-- ===================================================================
entity dlx_pipe_id is

  port (
  
    clk                : in std_logic;
    rst                : in std_logic;
    stall              : in std_logic; 
    dc_wait            : in std_logic;
      
    -- NPC and IR from IF-Stage
    if_id_npc          : in dlx_word_us;
    if_id_ir           : in dlx_word;

    -- Data from Register-File
    id_a               : in dlx_word;
    id_b               : in dlx_word;                   
    
    -- Instr. Data to/from Forwarding-Ctrl
    id_opcode_class    : out Opcode_class;    
    id_ir_rs1          : out Regadr;
    id_ir_rs2          : out Regadr;
    id_a_fwd_sel       : in  Forward_select; 
    ex_mem_alu_out     : in  dlx_word;

    -- Ctrl-Signals for the DLX-Pipeline, IF Stage
    id_cond            : out std_logic;
    id_npc             : out dlx_word_us;
    id_illegal_instr   : out std_logic;
    id_halt            : out std_logic;

    -- Ctrl-Signals for the DLX-Pipeline, EX/MEM/WB-Stage
    id_ex_a            : out dlx_word := (others => '0');
    id_ex_b            : out dlx_word := (others => '0');
    id_ex_imm          : out Imm17    := (others => '0');
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
  
end dlx_pipe_id;

-- ===================================================================
architecture behavior of dlx_pipe_id is

  signal iar                 : dlx_word_us;
  signal id_a_fwd            : dlx_word;
  signal id_opcode_class_int : Opcode_class;
  
  signal if_id_ir_opcode     : Opcode;
  signal if_id_ir_rs1        : Regadr;
  signal if_id_ir_rs2        : Regadr;
  signal if_id_ir_rd_rtype   : Regadr;
  signal if_id_ir_rd_itype   : Regadr;
  signal if_id_ir_spfunc     : Spfunc;
  signal if_id_ir_fpfunc     : Fpfunc;
  signal if_id_ir_imm16      : std_logic_vector( 0 to 15 );
  signal if_id_ir_imm26      : std_logic_vector( 0 to 25 );

begin
  
  -- splitting of instruction word 
  if_id_ir_opcode   <= if_id_ir(  0 to  5 );
  if_id_ir_rs1      <= if_id_ir(  6 to 10 );
  if_id_ir_rs2      <= if_id_ir( 11 to 15 );
  if_id_ir_rd_rtype <= if_id_ir( 16 to 20 );
  if_id_ir_rd_itype <= if_id_ir( 11 to 15 );
  if_id_ir_spfunc   <= if_id_ir( 26 to 31 );
  if_id_ir_fpfunc   <= if_id_ir( 27 to 31 );
  if_id_ir_imm16    <= if_id_ir( 16 to 31 );
  if_id_ir_imm26    <= if_id_ir(  6 to 31 );

  id_ir_rs1         <= if_id_ir_rs1;
  id_ir_rs2         <= if_id_ir_rs2;
  id_opcode_class   <= id_opcode_class_int;
  
  
  -- =================================================================
  -- multiplexing operand a (forwarding)
  -- =================================================================
  id_fwd_a_mux : with id_a_fwd_sel select
    id_a_fwd <= ex_mem_alu_out  when FWDSEL_EX_MEM_ALU_OUT,
                id_a            when others;
  
  
  -- =================================================================
  -- combinatorial logic
  -- =================================================================
  id_comb : process(  if_id_ir_imm16,  if_id_ir_imm26,    if_id_ir_opcode,
                      if_id_npc,       id_a_fwd,          iar,            
                      if_id_ir_spfunc, if_id_ir_rd_rtype, if_id_ir_rd_itype )

    variable imm16 : unsigned(0 to 31);
    variable imm26 : unsigned(0 to 31);
    
  begin
    id_cond          <= '0';
    id_illegal_instr <= '0';
    id_halt          <= '0';
    id_npc           <= (others => '-');      

    -- Address Calculation: 32-Unsigned-Reg. + 16/26-Signed-Immediate
    imm16( 0 to 15)  := (0 to 15 => if_id_ir_imm16(0));
    imm16(16 to 31)  := unsigned(if_id_ir_imm16);
    imm26( 0 to  5)  := (0 to  5 => if_id_ir_imm26(0));
    imm26( 6 to 31)  := unsigned(if_id_ir_imm26);
    
    case if_id_ir_opcode is
      -- ====================================================
      -- Your code for combinatorial decoder logic goes here
      -- ====================================================    
      
      when others =>
        id_opcode_class_int <= NOFORW;
        id_illegal_instr    <= '1';
    end case;
  end process id_comb;


  -- =================================================================
  -- sequential logic (clocked process)
  -- =================================================================
  id_seq : process( clk )
  begin
    if clk'event and clk = '1' then
      if rst = '1' then
        iar                 <= X"00_00_00_00";
        id_ex_dm_wen        <= '0';
        id_ex_dm_en         <= '0';
        id_ex_reg_wen       <= '0';
        id_ex_a             <= X"00_00_00_00";
        id_ex_b             <= X"00_00_00_00";
        id_ex_imm           <= '0' & X"00_00";
        id_ex_opcode_class  <= NOFORW;

      else

        -- synopsys translate_off
        debug_disassemble (if_id_ir);            
        -- synopsys translate_on

        if dc_wait = '0' then
          -- NOP Verhalten als Default
          id_ex_a            <= id_a;
          id_ex_b            <= id_b;
          id_ex_imm          <= if_id_ir_imm16(0) & if_id_ir_imm16;
          id_ex_alu_opb_sel  <= SEL_ID_EX_B;
          id_ex_us_sel       <= SEL_SIGNED;
          id_ex_data_sel     <= SEL_ALU_OUT;
          id_ex_alu_func     <= alu_add;
          id_ex_dm_width     <= MEM_WIDTH_WORD;
          id_ex_dm_wen       <= '0';
          id_ex_dm_en        <= '0';
          id_ex_reg_rd       <= REG_0;
          id_ex_reg_wen      <= '0';
          id_ex_ir_rs1       <= if_id_ir_rs1;
          id_ex_ir_rs2       <= if_id_ir_rs2;
  
          if stall = '1' then
            id_ex_opcode_class <= NOFORW;
          else
            id_ex_opcode_class <= id_opcode_class_int;

            -- von NOP abweichendes Verhalten
            case if_id_ir_opcode is
              -- ====================================================
              -- Your code for sequential decoder logic goes here
              -- ====================================================    

              when others => null;
                -- Tue nichts. Illegal-Instruktion wird kombinatorisch
                -- generiert !!!
            end case;  
          end if;  -- stall
        end if;  -- wait
      end if;  -- rst
    end if;  -- clk
  end process id_seq;

end behavior;
