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
-- DLX Pipeline: Execution Stufe.
-- 
-- ===================================================================
--
-- $Author: gilbert $
-- $Date: 2002/06/18 09:27:03 $
-- $Revision: 2.0 $
-- 
-- Author: wasenmueller
-- Date: 2010/06/18
-- Revision: shift range extended; assignment to alu_out_us extended
--
-- ===================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.dlx_global.all;
use work.dlx_opcode_package.all;


-- ===================================================================
entity dlx_pipe_ex is

  port (

    clk                 : in std_logic;
    rst                 : in std_logic;
    dc_wait             : in std_logic;
    id_ex_a             : in dlx_word;
    id_ex_b             : in dlx_word;
    id_ex_imm           : in Imm17;
    id_ex_alu_func      : in Alu_func;
    id_ex_alu_opb_sel   : in std_logic;
    id_ex_dm_en         : in std_logic;
    id_ex_dm_wen        : in std_logic;
    id_ex_dm_width      : in Mem_width; 
    id_ex_us_sel        : in std_logic;
    id_ex_data_sel      : in std_logic;
    id_ex_reg_rd        : in RegAdr; 
    id_ex_reg_wen       : in std_logic;
    id_ex_opcode_class  : in Opcode_class;
    id_ex_ir_rs1        : in RegAdr; 
    id_ex_ir_rs2        : in RegAdr;      
    mem_wb_data         : in dlx_word;
   
    ex_alu_opa_sel      : in Forward_select; 
    ex_alu_opb_sel      : in Forward_select;
    ex_dm_data_sel      : in Forward_select;
    
    ex_mem_alu_out      : out dlx_word;
    ex_mem_dm_en        : out std_logic;
    ex_mem_dm_data      : out dlx_word;
    ex_mem_dm_width     : out Mem_width;
    ex_mem_dm_wen       : out std_logic;     
    ex_mem_us_sel       : out std_logic;
    ex_mem_data_sel     : out std_logic;
    ex_mem_reg_rd       : out RegAdr;
    ex_mem_reg_wen      : out std_logic := '0';
    ex_mem_opcode_class : out Opcode_class

  );
  
end dlx_pipe_ex;

-- ===================================================================
architecture behavior of dlx_pipe_ex is

  signal alu_out     : dlx_word; 
  signal alu_out_r : dlx_word;

begin
  ex_mem_alu_out <= alu_out_r;
 
  -- ================ Berechnen des ALU-Ergebnisses ==================
  ex_alu_calc : process( 
                         id_ex_a,
                         id_ex_b,
                         id_ex_imm,
                         id_ex_alu_opb_sel,
                         id_ex_alu_func,
                         id_ex_us_sel,
                         ex_alu_opa_sel, 
                         ex_alu_opb_sel,
                         mem_wb_data, 
                         alu_out_r
                       )

    subtype  shift_range is natural range 0 to 31; -- in revision 2.0 range 0 to 3
    constant ZERO_WORD_EXT : unsigned(0 to 32) := (others => '0');
    variable shift         : shift_range; 
    variable A_us          : dlx_word_us;
    variable B_us          : dlx_word_us;
    variable B_ext_us      : unsigned (0 to dlx_word'length);
    variable A_ext_us      : unsigned (0 to dlx_word'length); 

    variable alu_out_us    : dlx_word_us;
    variable sub_A_B       : unsigned (0 to dlx_word'length);
    variable zero_comp     : std_logic;

  begin
  
    -- Auswahl des ALU-Operanden A
    case ex_alu_opa_sel is
 
      when FWDSEL_MEM_WB_DATA     => A_us := unsigned(mem_wb_data);
      when FWDSEL_EX_MEM_ALU_OUT  => A_us := unsigned(alu_out_r);
      when others              => A_us := unsigned(id_ex_a);

    end case;
    
    -- Auswahl des ALU-Operanden B
    case ex_alu_opb_sel is

      when FWDSEL_MEM_WB_DATA     => B_us := unsigned(mem_wb_data);
      when FWDSEL_EX_MEM_ALU_OUT  => B_us := unsigned(alu_out_r);
      when others              =>
        if id_ex_alu_opb_sel = SEL_ID_EX_B then
          B_us := unsigned(id_ex_b);  
        else
          B_us(0  to 15) := (others => id_ex_imm( 0 ));
          B_us(16 to 31) := unsigned(id_ex_imm( 1 to 16 ));
        end if;

    end case;
    
    if id_ex_us_sel = SEL_SIGNED then 
      A_ext_us := A_us(0) & A_us;
      B_ext_us := B_us(0) & B_us;
    else 
      A_ext_us := '0' & A_us;
      B_ext_us := '0' & B_us;
    end if;  
   
    sub_A_B := A_ext_us - B_ext_us;
    if (sub_A_B  = ZERO_WORD_EXT) then zero_comp := '1';
                                  else zero_comp := '0';                                  
    end if;                               
    
    -- Schiebeoperationen komplett; in revision 2.0 shift := to_integer(B_us(30 to 31));
    shift := to_integer(B_us(27 to 31));    
    
    -- Berechne ALU Funktion
    case id_ex_alu_func is
      
      -- Pass
      when alu_a    => alu_out_us := A_us;
      when alu_b    => alu_out_us := B_us;
      
      -- Arithmetic
      when alu_add  => alu_out_us := A_us + B_us;
      when alu_sub  => alu_out_us := sub_A_B(1 to 32);
      
      -- Logical
      when alu_and  => alu_out_us := A_us and B_us;
      when alu_or   => alu_out_us := A_us or  B_us;
      when alu_xor  => alu_out_us := A_us xor B_us;
      
      -- Shift
      when alu_sll  => alu_out_us := A_us sll shift;
      when alu_srl  => alu_out_us := A_us srl shift;
      when alu_sra  => alu_out_us := shift_right(A_us, shift);
      
      -- Set
      when alu_slt  => -- A_s < B_s
        if (sub_A_B(0) = '1') then 
          alu_out_us := X"00_00_00_01"; 
        else 
          alu_out_us := X"00_00_00_00";
        end if;
        
      when alu_sgt  =>
        if (sub_A_B(0) = '0') and (zero_comp = '0') then 
          alu_out_us := X"00_00_00_01"; 
        else 
          alu_out_us := X"00_00_00_00";
      end if;

      when alu_sle  =>
        if (sub_A_B(0) = '1') or (zero_comp = '1') then 
          alu_out_us := X"00_00_00_01"; 
        else 
          alu_out_us := X"00_00_00_00";
        end if;
        
      when alu_sge  =>
        if sub_A_B(0) = '0' then 
          alu_out_us := X"00_00_00_01"; 
        else 
          alu_out_us := X"00_00_00_00";
        end if;
        
      when alu_seq  =>
        if zero_comp = '1' then 
          alu_out_us := X"00_00_00_01"; 
        else 
          alu_out_us := X"00_00_00_00";
        end if;
        
      when alu_sne  =>
        if zero_comp = '0' then 
          alu_out_us := X"00_00_00_01"; 
        else 
          alu_out_us := X"00_00_00_00";
        end if;
        
      when others   => alu_out_us := X"00_00_00_00"; -- to prevent latch
    end case;
    
    alu_out <= std_logic_vector(alu_out_us);

  end process ex_alu_calc;



  -- ========================== sequentieller Teil =============================
  ex_seq : process( clk )

  begin
  
    if clk'event and clk = '1' then
     
      if rst = '1' then
        ex_mem_dm_en <= '0';     
        ex_mem_reg_wen <= '0';       
        ex_mem_opcode_class <= NOFORW;
      else
        if dc_wait = '0' then
          case ex_dm_data_sel is
          
            when FWDSEL_MEM_WB_DATA     => ex_mem_dm_data <= mem_wb_data;
            when FWDSEL_EX_MEM_ALU_OUT  => ex_mem_dm_data <= alu_out_r;
            when others                 => ex_mem_dm_data <= id_ex_b;
          
          end case;
          alu_out_r           <= alu_out;
          ex_mem_dm_width     <= id_ex_dm_width;
          ex_mem_us_sel       <= id_ex_us_sel;
          ex_mem_dm_wen       <= id_ex_dm_wen;
          ex_mem_dm_en        <= id_ex_dm_en;
          ex_mem_data_sel     <= id_ex_data_sel;
          ex_mem_reg_rd       <= id_ex_reg_rd;
          ex_mem_reg_wen      <= id_ex_reg_wen;
          ex_mem_opcode_class <= id_ex_opcode_class;
        end if;
      end if;    
    end if;  

  end process ex_seq;
  

end behavior;
