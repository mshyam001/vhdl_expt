library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tt_um_PROJECT is
    port (
        ui_in   : in  std_logic_vector(7 downto 0);  -- Dedicated inputs
        uo_out  : out std_logic_vector(7 downto 0);  -- Dedicated outputs
        uio_in  : in  std_logic_vector(7 downto 0);  -- IOs: Input path
        uio_out : out std_logic_vector(7 downto 0);  -- IOs: Output path
        uio_oe  : out std_logic_vector(7 downto 0);  -- IOs: Enable path (1=output)
        ena     : in  std_logic;                     -- Always 1 when powered (unused)
        clk     : in  std_logic;                     -- Clock
        rst_n   : in  std_logic                      -- Active-low reset
    );
end entity tt_um_PROJECT;

architecture rtl of tt_um_PROJECT is
    -- Internal connections to PWM
    signal set_thres_s : unsigned(7 downto 0);
    signal clr_thres_s : unsigned(7 downto 0);
    signal reload_s    : unsigned(7 downto 0);
    signal pwm_s       : std_logic;
begin
    ----------------------------------------------------------------
    -- Input Mapping
    --   - Duty "set" threshold from ui_in
    --   - Duty "clear" threshold from uio_in
    --   - Period from a fixed value (0xFF => period = 256 counts)
    --     You can later expose this via pins if desired.
    ----------------------------------------------------------------
    set_thres_s <= unsigned(ui_in);
    clr_thres_s <= unsigned(uio_in);
    reload_s    <= x"FF";

    ----------------------------------------------------------------
    -- PWM instance
    ----------------------------------------------------------------
    u_pwm : entity work.tt_um_pwm
        port map (
            clk         => clk,
            res_ni      => rst_n,
            set_thres_i => set_thres_s,
            clr_thres_i => clr_thres_s,
            reload_i    => reload_s,
            pwm_o       => pwm_s
        );

    ----------------------------------------------------------------
    -- Output Mapping
    ----------------------------------------------------------------
    uo_out <= (0 => pwm_s, others => '0');  -- PWM on uo_out(0)

    -- Tri-state IOs not used: keep as inputs
    uio_out <= (others => '0');
    uio_oe  <= (others => '0');

    -- 'ena' is always 1 on silicon; design does not depend on it.
end architecture rtl;
