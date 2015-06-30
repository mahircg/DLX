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
      when op_j =>
		id_npc 					<= if_id_npc + imm26;
		id_cond					<= '1'; 
		id_opcode_class_int  <= NOFORW;
		
		when op_jal =>
		id_npc 					<= if_id_npc + imm26;
		id_cond					<= '1';
		id_opcode_class_int  <= NOFORW;
		
		when op_jalr =>
		id_npc					<= unsigned(id_a_fwd);
		id_cond					<= '1';
		id_opcode_class_int		<= BRANCH;
		
		when op_jr	=>
		id_npc					<= unsigned(id_a_fwd);
		id_cond					<= '1';
		id_opcode_class_int		<= BRANCH;
		
		when op_beqz =>
		id_opcode_class_int  <= BRANCH;
		if(id_a_fwd = X"00000000") then
			id_npc					<= if_id_npc + imm16;
			id_cond					<= '1';

		end if;
		
		when op_bnez =>
		id_opcode_class_int  <= BRANCH;
		if(id_a_fwd /= X"00000000") then
			id_npc					<= if_id_npc + imm16;
			id_cond					<= '1';

		end if;
		
		when op_trap =>
			id_opcode_class_int		<= NOFORW;
			--At this stage,traps are not handled.Therefore system is terminated whenever an exception occurs.
			--id_npc					<= if_id_npc  + std_logic_vector(resize(unsigned(imm26), id_npc'length));
			--id_cond					<= '1';
			id_halt <= '1';
		
		when op_special =>
			id_opcode_class_int		<= RR_ALU;
			
		when op_lb =>			
			id_opcode_class_int		<= LOAD;
			
		when op_lbu =>
			id_opcode_class_int		<= LOAD;
		
		when op_lh =>
			id_opcode_class_int		<= LOAD;
		
		when op_lhi =>
			id_opcode_class_int		<= LOAD;
		
		when op_lhu =>
			id_opcode_class_int		<= LOAD;
		
		when op_lw =>
			id_opcode_class_int		<= LOAD;
				
		when op_sb =>
			id_opcode_class_int		<= STORE;
			
		when op_sh =>
			id_opcode_class_int		<= STORE;

			
		when op_sw =>
			id_opcode_class_int		<= STORE;
			

		when op_addi =>
			id_opcode_class_int		<= IM_ALU;
			
		when op_addui =>
			id_opcode_class_int 		<= IM_ALU;
			
		when op_andi =>
			id_opcode_class_int		<= IM_ALU;
			
		when op_ori =>
			id_opcode_class_int		<= IM_ALU;
		
		when op_seqi =>
			id_opcode_class_int		<= IM_ALU;
		
		when op_sgei =>
			id_opcode_class_int		<= IM_ALU;
		
		when op_sgti =>
			id_opcode_class_int		<= IM_ALU;
		
		when op_slti =>
			id_opcode_class_int		<= IM_ALU;
		
		when op_snei =>
			id_opcode_class_int		<= IM_ALU;
		
		when op_srai =>
			id_opcode_class_int		<= IM_ALU;
		
		when op_srli =>
			id_opcode_class_int		<= IM_ALU;
			
		when op_slli =>
			id_opcode_class_int		<= IM_ALU;
		
		when op_subi =>
			id_opcode_class_int		<= IM_ALU;
			
		when op_subui =>
			id_opcode_class_int		<= IM_ALU;
		
		when op_xori =>
			id_opcode_class_int		<= IM_ALU;

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
              when op_j => 		NULL;
				  
				  when op_jal =>
					id_ex_reg_rd  		<= REG_31;
					id_ex_reg_wen		<= '1';
					id_ex_a				<= std_logic_vector(if_id_npc + unsigned("000000" & if_id_ir_imm26));
					id_ex_alu_func		<= alu_a;
					
					when op_jalr =>
					id_ex_reg_rd  		<= REG_31;
					id_ex_reg_wen		<= '1';
					id_ex_a				<= std_logic_vector(if_id_npc + unsigned("000000" & if_id_ir_imm26));
					id_ex_alu_func		<= alu_a;
					
					when op_jr	=>		NULL;
					
					when op_beqz =>	NULL;
					
					when op_bnez =>	NULL;
					
					when op_trap =>	NULL;
					
					when op_special =>
						--id_ex_alu_func 	<= if_id_ir_spfunc;
						id_ex_reg_rd		<=	if_id_ir_rd_rtype;
						id_ex_reg_wen		<= '1';
						case if_id_ir_spfunc is
							when sp_add  =>
								id_ex_alu_func		 <= alu_add;
							when sp_and  =>
								id_ex_alu_func		 <= alu_and;
							when sp_or =>
								id_ex_alu_func		 <= alu_or;
							when sp_seq =>
								id_ex_alu_func		 <= alu_seq;
							when sp_sge =>
								id_ex_alu_func		 <= alu_sge;
							when sp_sgt =>
								id_ex_alu_func		 <= alu_sgt;
							when sp_sle =>
								id_ex_alu_func		 <= alu_sle;
							when sp_slt =>
								id_ex_alu_func		 <= alu_slt;
							when sp_sne =>
								id_ex_alu_func		 <= alu_sne;
							when sp_sll =>
								id_ex_alu_func		 <= alu_sll;
							when sp_sra =>
								id_ex_alu_func		 <= alu_sra;
							when sp_srl =>
								id_ex_alu_func		 <= alu_srl;
							when sp_sub =>
								id_ex_alu_func		 <= alu_sub;
							when sp_xor =>
								id_ex_alu_func		 <= alu_xor;
							when sp_addu =>
								id_ex_alu_func		 <= alu_add;
								id_ex_us_sel       <= SEL_UNSIGNED;
							when sp_subu =>
								id_ex_alu_func		 <= alu_sub;
								id_ex_us_sel		 <= SEL_UNSIGNED;
							when others =>			 NULL;
						end case;
					
					when op_lb =>
						id_ex_data_sel			<= SEL_DM_OUT;
						id_ex_dm_en				<= '1';
						id_ex_reg_rd 			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_dm_width			<= MEM_WIDTH_BYTE;
						id_ex_us_sel       	<= SEL_SIGNED;
						id_ex_alu_func			<= alu_add;
						
					when op_lbu =>
						id_ex_data_sel			<= SEL_DM_OUT;
						id_ex_dm_en				<= '1';
						id_ex_reg_rd 			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_dm_width			<= MEM_WIDTH_BYTE;
						id_ex_us_sel       	<= SEL_SIGNED;
						id_ex_alu_func			<= alu_add;
					
					when op_lh =>
						id_ex_data_sel			<= SEL_DM_OUT;
						id_ex_dm_en				<= '1';
						id_ex_reg_rd 			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_dm_width			<= MEM_WIDTH_HALFWORD;
						id_ex_us_sel       	<= SEL_SIGNED;
						id_ex_alu_func			<= alu_add;
						
					when op_lhi =>
						
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_a					<= if_id_ir_imm16 & X"0000";
						id_ex_alu_func			<= alu_a;
						
					when op_lhu =>
						id_ex_data_sel			<= SEL_DM_OUT;
						id_ex_dm_en				<= '1';
						id_ex_reg_rd 			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_dm_width			<= MEM_WIDTH_HALFWORD;
						id_ex_us_sel       	<= SEL_SIGNED;
						id_ex_alu_func			<= alu_add;	
					
					when op_lw =>
						id_ex_data_sel			<= SEL_DM_OUT;
						id_ex_dm_en				<= '1';
						id_ex_reg_rd 			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_dm_width			<= MEM_WIDTH_WORD;
						id_ex_us_sel       	<= SEL_SIGNED;
						id_ex_alu_func			<= alu_add;	
						
					when op_sb =>
						id_ex_dm_en				<= '1';
						id_ex_dm_wen			<= '1';
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_dm_width			<= MEM_WIDTH_BYTE;
						id_ex_us_sel       	<= SEL_SIGNED;
						id_ex_alu_func			<= alu_add;	
						
					when op_sh =>
						id_ex_dm_en				<= '1';
						id_ex_dm_wen			<= '1';
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_dm_width			<= MEM_WIDTH_HALFWORD;
						id_ex_us_sel       	<= SEL_SIGNED;
						id_ex_alu_func			<= alu_add;	

					when op_sw =>
						id_ex_dm_en				<= '1';
						id_ex_dm_wen			<= '1';
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_dm_width			<= MEM_WIDTH_WORD;
						id_ex_us_sel       	<= SEL_SIGNED;
						id_ex_alu_func			<= alu_add;							
					
	
						
					when op_addi =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_SIGNED;
						id_ex_alu_func			<= alu_add;
						
					when op_addui =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_UNSIGNED;
						id_ex_alu_func			<= alu_add;
						id_ex_imm				<= '0' & if_id_ir_imm16;
						
					when op_andi =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_UNSIGNED;
						id_ex_alu_func			<= alu_and;
						id_ex_imm				<= '0' & if_id_ir_imm16;
						
					when op_ori =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_UNSIGNED;
						id_ex_alu_func			<= alu_or;
						id_ex_imm				<= '0' & if_id_ir_imm16;
						
						
					when op_seqi =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_UNSIGNED;
						id_ex_alu_func			<= alu_seq;
					
					when op_sgei =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_UNSIGNED;
						id_ex_alu_func			<= alu_sge;	
					
					when op_sgti =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_UNSIGNED;
						id_ex_alu_func			<= alu_sgt;	
						
					when op_slti =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_UNSIGNED;
						id_ex_alu_func			<= alu_slt;	
						
					when op_snei =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_UNSIGNED;
						id_ex_alu_func			<= alu_sne;	
					
					when op_srai =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_UNSIGNED;
						id_ex_alu_func			<= alu_sra;
						id_ex_imm				<= '0' & if_id_ir_imm16;
						
					when op_srli =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_UNSIGNED;
						id_ex_alu_func			<= alu_srl;
						id_ex_imm				<= '0' & if_id_ir_imm16; 
						
					when op_slli =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_SIGNED;
						id_ex_alu_func			<= alu_sll;
						id_ex_imm				<= if_id_ir_imm16(0) & if_id_ir_imm16;
					
					when op_subi =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_SIGNED;
						id_ex_alu_func			<= alu_sub;	
					
					when op_subui =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_UNSIGNED;
						id_ex_alu_func			<= alu_sub;
						id_ex_imm				<= '0' & if_id_ir_imm16;	
					
					when op_xori =>
						id_ex_alu_opb_sel 	<= SEL_ID_EX_IMM;
						id_ex_reg_rd			<= if_id_ir_rd_itype;
						id_ex_reg_wen			<= '1';
						id_ex_us_sel       	<= SEL_UNSIGNED;
						id_ex_alu_func			<= alu_xor;
						id_ex_imm				<= '0' & if_id_ir_imm16;

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
