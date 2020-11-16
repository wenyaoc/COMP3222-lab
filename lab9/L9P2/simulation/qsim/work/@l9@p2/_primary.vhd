library verilog;
use verilog.vl_types.all;
entity L9P2 is
    port(
        KEY             : in     vl_logic_vector(2 downto 0);
        SW              : in     vl_logic_vector(9 downto 0);
        LEDG            : out    vl_logic_vector(9 downto 0)
    );
end L9P2;
