library ieee;
use ieee.std_logic_1164.all;

package support_pk is

	function SIGNED_NUM_BITS   (ARG: INTEGER) return NATURAL;
	function UNSIGNED_NUM_BITS (ARG: NATURAL) return NATURAL;
	function UPPERGAUSS_DIV    (ARG1, ARG2 : NATURAL) return NATURAL;
	function MAX               (ARG1, ARG2 : INTEGER) return INTEGER;
  
end support_pk;


package body support_pk is

  function SIGNED_NUM_BITS (ARG: INTEGER) return NATURAL is
    variable NBITS: NATURAL;
    variable N: NATURAL;
  begin
    if ARG >= 0 then
      N := ARG;
    else
      N := -(ARG+1);
    end if;
    NBITS := 1;
    for i in 0 to 31 loop
      if N > 0 then
        NBITS := NBITS+1;
        N := N / 2;
      else
        exit;
      end if;
    end loop;
    return NBITS;
  end SIGNED_NUM_BITS;

  function UNSIGNED_NUM_BITS (ARG: NATURAL) return NATURAL is
    variable NBITS: NATURAL;
    variable N: NATURAL;
  begin
    N := ARG;
    NBITS := 1;
    for i in 0 to 31 loop
      if N > 1 then
        NBITS := NBITS+1;
        N := N / 2;
      else
        exit;
      end if;
    end loop;
    return NBITS;
  end UNSIGNED_NUM_BITS;

  function UPPERGAUSS_DIV (ARG1, ARG2 : NATURAL) return NATURAL IS
  begin
    if ARG1 MOD ARG2 = 0 then
      return ARG1 / ARG2;
    else
      return ARG1 / ARG2 + 1;
    end if;
  end UPPERGAUSS_DIV;

  function MAX (ARG1, ARG2 : INTEGER) return INTEGER IS
  begin
      if ARG1 > ARG2 then
	  return ARG1;
      else
	  return ARG2;
      end if;
  end MAX;
  
end support_pk;
