
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
--use work.parameter_pk.all;
use work.support_pk.all;


entity generic_dual_port_dist_ram is
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
end generic_dual_port_dist_ram;

-- ===================================================================
architecture syn of generic_dual_port_dist_ram is

	type ram_type is array (nr_of_words-1 downto 0) of std_logic_vector (bitwidth-1 downto 0);
	signal RAM : ram_type := (others => (others => '0'));

begin

	process (clk)
	begin

		if (clk'event and clk =  '1' ) then
			if (wen_A =  '1' ) then
				RAM(conv_integer(a_A)) <= d_A;
			end if;
		end if;
	end process;

	q_A <= RAM(conv_integer(a_A));
	q_B <= RAM(conv_integer(a_B));

end syn;
