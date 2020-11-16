library verilog;
use verilog.vl_types.all;
entity L3P3 is
    port(
        SW              : in     vl_logic_vector(9 downto 0);
        LEDG            : out    vl_logic_vector(9 downto 0)
    );
end L3P3;
