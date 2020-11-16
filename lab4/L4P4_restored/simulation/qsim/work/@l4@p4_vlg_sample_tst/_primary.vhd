library verilog;
use verilog.vl_types.all;
entity L4P4_vlg_sample_tst is
    port(
        CLOCK_50        : in     vl_logic;
        KEY             : in     vl_logic_vector(0 to 2);
        sampler_tx      : out    vl_logic
    );
end L4P4_vlg_sample_tst;
