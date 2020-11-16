library verilog;
use verilog.vl_types.all;
entity L1P4 is
    port(
        SW              : in     vl_logic_vector(9 downto 0);
        HEX0            : out    vl_logic_vector(6 downto 0)
    );
end L1P4;
