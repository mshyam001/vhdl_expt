library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pwm is
	port (
    	clk       : in std_ulogic;              -- Clock input
    	res_ni      : in std_ulogic;              -- Reset (active-low)
	set_thres_i : in unsigned(7 downto 0);   -- Asynchronous Set threshold
	clr_thres_i : in unsigned(7 downto 0);   -- Asynchronous Clear threshold
	reload_i    : in unsigned(7 downto 0);   -- Asynchronous Reload value
        pwm_o       : out std_ulogic             -- PWM output
	);
end entity pwm;

architecture rtl of pwm is
	-- Counter signal
	signal cnt : unsigned(7 downto 0) := (others => '0');

	-- Synchronized signals
	signal set_thres_sync   : unsigned(7 downto 0) := (others => '0');
	signal clr_thres_sync   : unsigned(7 downto 0) := (others => '0');
	signal reload_sync      : unsigned(7 downto 0) := (others => '0');
begin

	-- Synchronize inputs to the clock domain
	sync_proc : process (clk, res_ni) is
	begin
		if res_ni = '0' then
			set_thres_sync <= (others => '0');
			clr_thres_sync <= (others => '0');
			reload_sync    <= (others => '0');
		elsif rising_edge(clk) then
			set_thres_sync <= set_thres_i;
			clr_thres_sync <= clr_thres_i;
			reload_sync    <= reload_i;
		end if;
	end process sync_proc;

	-- Synchronous counter process
	cnt_proc : process (clk, res_ni) is
	begin
		if res_ni = '0' then
			cnt <= (others => '0'); -- Reset counter
		elsif rising_edge(clk) then
			if cnt = reload_sync then
				cnt <= (others => '0'); -- Reload counter synchronously
			else
				cnt <= cnt + 1; -- Increment counter
			end if;
		end if;
	end process cnt_proc;

	-- Set/Reset PWM output
	pwm_proc : process (clk, res_ni) is
	begin
		if res_ni = '0' then
			pwm_o <= '0'; -- Reset PWM output
		elsif rising_edge(clk) then
			if cnt = clr_thres_sync then
				pwm_o <= '0'; -- Clear PWM output
			elsif cnt = set_thres_sync then
				pwm_o <= '1'; -- Set PWM output
			end if;
		end if;
	end process pwm_proc;

end architecture rtl;
