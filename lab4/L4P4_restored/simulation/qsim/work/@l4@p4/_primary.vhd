library verilog;
use verilog.vl_types.all;
entity L4P4 is
    port(
        CLOCK_50        : in     vl_logic;
        KEY             : in     vl_logic_vector(0 to 2);
        HEX0            : out    vl_logic_vector(0 to 6);
        HEX1            : out    vl_logic_vector(0 to 6);
        HEX2            : out    vl_logic_vector(0 to 6);
        HEX3            : out    vl_logic_vector(0 to 6)
    );
end L4P4;
