--
-- user_app.vhd - user application code
--
-- This module is an implementation of the 'user_app' component that can be
-- commanded to perform a memory test of some or all of the memory banks.
--
-- SYNTHESIZABLE
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;

library work;
use work.memif.all;
use work.memory_common.all;
use work.user_defs.all;

entity user_app is
    port(
        rst           : in    std_logic;   -- Reset from memory clock domain
        clk           : in    std_logic;   -- Clock from memory clock domain
        -- To/from local bus interface
        reg_in        : in    std_logic_vector(31 downto 0);   -- Incoming register write values
        reg_wr        : in    std_logic_vector(255 downto 0);  -- Byte write enables for 'reg_in'
        reg_out       : out   std_logic_vector(2047 downto 0); -- Outgoing register values
        -- To/from memory banks
        valid         : in    control_vector_t(max_num_bank - 1 downto 0);
        q             : in    data_vector_t(max_num_bank - 1 downto 0);
        qtag          : in    tag_vector_t(max_num_bank - 1 downto 0);
        ready         : in    control_vector_t(max_num_bank - 1 downto 0);
        req           : out   control_vector_t(max_num_bank - 1 downto 0);
        ce            : out   control_vector_t(max_num_bank - 1 downto 0);
        w             : out   control_vector_t(max_num_bank - 1 downto 0);
        a             : out   address_vector_t(max_num_bank - 1 downto 0);
        tag           : out   tag_vector_t(max_num_bank - 1 downto 0);
        d             : out   data_vector_t(max_num_bank - 1 downto 0);
        be            : out   be_vector_t(max_num_bank - 1 downto 0));
end entity;

architecture mixed of user_app is

    type user_vector_t is array(0 to 63) of std_logic_vector(31 downto 0);
    signal user_out : user_vector_t;

    type user_wr_vector_t is array(0 to 63) of std_logic_vector(3 downto 0);
    signal user_wr : user_wr_vector_t;

    signal user_enable : std_logic;
    signal reflesh : std_logic;
    signal image_size : std_logic_vector(rd_width(0)- 1 downto 0);
    signal image_width : std_logic_vector(rd_width(0)- 1 downto 0);

    signal is_end : std_logic;

    constant user_bank_present : boolean_vector_t :=
        (0 => true, 1 => true, others => false);

    component filter
        generic(
            ADDRESS_WIDTH : natural;
            DATA_WIDTH : natural;
            TAG_WIDTH : natural);
        port(
            request0 : out std_logic;
            request1 : out std_logic;
            command_entry0 : out std_logic;
            command_entry1 : out std_logic;
            write_enable1 : out std_logic;
            address0 : out std_logic_vector(max_address_width - 1 downto 0);
            address1 : out std_logic_vector(max_address_width - 1 downto 0);
            tag0 : out std_logic_vector(tag_width - 1 downto 0);
            data_out1 : out std_logic_vector(bank_width(1) - 1 downto 0);
            is_end : out std_logic;

            valid0 : in std_logic;
            valid1 : in std_logic;
            query0 : in std_logic_vector(bank_width(0) - 1 downto 0);
            qtag0 : in std_logic_vector(tag_width - 1 downto 0);
            ready0 : in std_logic;
            ready1 : in std_logic;

            image_size : in std_logic_vector(32 - 1 downto 0);
            image_width : in std_logic_vector(32 - 1 downto 0);				

            reflesh : in std_logic;
            reset : in std_logic;
            clock : in std_logic);
    end component;
begin
    -- Divide 'reg_wr' into an array of 64 x 4-bit vectors for easy access
    gen_user_in : for i in 0 to 63 generate
        user_wr(i) <= reg_wr(4 * i + 3 downto 4 * i);
    end generate;

    -- Combine the 64 32-bit registers of 'user_out' into the vector 'reg_out'
    gen_reg_out : for i in 0 to 63 generate
        reg_out(32 * i + 31 downto 32 * i) <= user_out(i);
    end generate;

    set_reflesh: process(rst, clk) begin
        if rst = '1' then
            reflesh <= '0';
        elsif clk'event and clk = '1' then
            if user_wr(0)(0) = '1' then
                reflesh <= reg_in(0);
            end if;
        end if;
    end process;

    set_user_enable: process(rst, clk) begin
        if rst = '1' then
            user_enable <= '0';
        elsif clk'event and clk = '1' then
            if user_wr(1)(0) = '1' then
                user_enable <= reg_in(0);
            end if;
        end if;
    end process;

    set_image_size : process(rst, clk) begin
        if rst = '1' then
            image_size <= (others => '0');
        elsif clk'event and clk = '1' then
            for j in 0 to 3 loop
              if user_wr(2)(j) = '1' then
                image_size(8 * j + 7 downto 8 * j) <= reg_in(8 * j + 7 downto 8 * j);
              end if;
            end loop;
        end if;
    end process;
	 
	  set_image_width : process(rst, clk) begin
        if rst = '1' then
            image_width <= (others => '0');
        elsif clk'event and clk = '1' then
            for j in 0 to 3 loop
              if user_wr(3)(j) = '1' then
                image_width(8 * j + 7 downto 8 * j) <= reg_in(8 * j + 7 downto 8 * j);
              end if;
            end loop;
        end if;
    end process;

    user_out(0)(0) <= reflesh;
    user_out(0)(31 downto 1) <= (others => '0');
    user_out(1)(0) <= user_enable;
    user_out(1)(31 downto 1) <= (others => '0');
    user_out(2) <= image_size;
    user_out(3) <= image_width;
    user_out(32)(0) <= is_end;
    user_out(32)(31 downto 1) <= (others => '0');

    user_out(33)(0) <= reflesh;
    user_out(33)(31 downto 1) <= (others => '0');
    user_out(34)(0) <= user_enable;
    user_out(34)(31 downto 1) <= (others => '0');

    user_out(35) <= image_size;


    -- Unused regisers return undefined
    user_out(4 to 31) <= (others => (others => '-'));
--    user_out(33 to 61) <= (others => (others => '-'));
    user_out(36 to 61) <= (others => (others => '-'));

    w(0) <= '0';
    tag(1) <= (others => '0');
    d(0) <= (others => '0');
    d(1)(max_data_width - 1 downto bank_width(1)) <= (others => '0');
    be(0) <= (others => '1');
    be(1) <= (others => '1');

    filter0 : filter 
        generic map(
            ADDRESS_WIDTH => max_address_width,
            DATA_WIDTH => bank_width(0),
            TAG_WIDTH => tag_width)
        port map(
            request0 => req(0),
            request1 => req(1),
            command_entry0 => ce(0),
            command_entry1 => ce(1),
            write_enable1 => w(1),
            address0 => a(0),
            address1 => a(1),
            tag0 => tag(0),
            data_out1 => d(1)(bank_width(0) - 1 downto 0),
            is_end => is_end,

            valid0 => valid(0),
            valid1 => valid(1),
            query0 => q(0)(bank_width(0) - 1 downto 0),
            qtag0 => qtag(0),
            ready0 => ready(0),
            ready1 => ready(1),

            image_size => image_size,
            image_width => image_width,
            reflesh => reflesh,

            reset => rst,
            clock => clk);

    gen_memory_test : for i in 0 to max_num_bank - 1 generate
        -- Generate dummy code for nonexistent memory banks
        gen_dummy : if not user_bank_present(i) generate
            req(i) <= '0';
            ce(i) <= '0';
            w(i) <= '-';
            a(i) <= (others => '-');
            tag(i) <= (others => '-');
            d(i) <= (others => '-');
            be(i) <= (others => '-');
        end generate;
    end generate;

--    gen_memory_test : for i in 0 to max_num_bank - 1 generate
--      req(i) <= '0';
--      ce(i) <= '0';
--      w(i) <= '-';
--      a(i) <= (others => '-');
--      tag(i) <= (others => '-');
--      d(i) <= (others => '-');
--      be(i) <= (others => '-');
--    end generate;
end architecture;