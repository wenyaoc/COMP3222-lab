library verilog;
use verilog.vl_types.all;
entity L3P1_vlg_sample_tst is
    port(
        Clk             : in     vl_logic;
        R               : in     vl_logic;
        S               : in     vl_logic;
        sampler_tx      : out    vl_logic
    );
end L3P1_vlg_sample_tst;
