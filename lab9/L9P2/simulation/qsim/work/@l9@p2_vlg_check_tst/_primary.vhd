library verilog;
use verilog.vl_types.all;
entity L9P2_vlg_check_tst is
    port(
        LEDG            : in     vl_logic_vector(9 downto 0);
        sampler_rx      : in     vl_logic
    );
end L9P2_vlg_check_tst;
