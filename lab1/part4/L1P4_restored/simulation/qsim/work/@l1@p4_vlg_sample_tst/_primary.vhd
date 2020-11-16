library verilog;
use verilog.vl_types.all;
entity L1P4_vlg_sample_tst is
    port(
        SW              : in     vl_logic_vector(9 downto 0);
        sampler_tx      : out    vl_logic
    );
end L1P4_vlg_sample_tst;
