library ieee;
use ieee.std_logic_1164.all;

entity uart_tb is
end uart_tb;

architecture Behavioral of uart_tb is

component top is
    generic (
        CLKFREQ         : integer := 125E6; -- 125 Mhz clock
        BAUDRATE        : integer := 115200;
        UART_DATA_WIDTH     : integer := 8;
        AXI_FIFO_DATA_WIDTH : integer := 32;
        PARITY          : string  := "NONE"; -- NONE, EVEN, ODD
        STOP_WIDTH      : integer := 1
    );
    port (
        clk : in  std_logic;
        rst : in  std_logic;
        -- external interface signals
        rxd : in  std_logic;
        txd : out std_logic
    );
end component;

constant uart_baud_wait : time := 8680.555ns;
constant clk_period : time := 8ns;
signal sim_time : time := 0ns;
signal switch_inputs : time := 2000ns;

signal cmd0 : std_logic_vector(7 downto 0) := x"00";
signal cmd1 : std_logic_vector(7 downto 0) := x"00";
signal cmd2 : std_logic_vector(7 downto 0) := x"00";
signal cmd3 : std_logic_vector(7 downto 0) := x"01";

-- 136 bytes to write one message block
signal data0 : std_logic_vector(7 downto 0) := x"00";
signal data1 : std_logic_vector(7 downto 0) := x"FF";
signal data2 : std_logic_vector(7 downto 0) := x"00";
signal data3 : std_logic_vector(7 downto 0) := x"FF";

signal data4 : std_logic_vector(7 downto 0) := x"00";
signal data5 : std_logic_vector(7 downto 0) := x"FF";
signal data6 : std_logic_vector(7 downto 0) := x"00";
signal data7 : std_logic_vector(7 downto 0) := x"FF";

signal data8 : std_logic_vector(7 downto 0) := x"00";
signal data9 : std_logic_vector(7 downto 0) := x"FF";
signal data10 : std_logic_vector(7 downto 0) := x"00";
signal data11 : std_logic_vector(7 downto 0) := x"FF";

signal data12 : std_logic_vector(7 downto 0) := x"00";
signal data13 : std_logic_vector(7 downto 0) := x"FF";
signal data14 : std_logic_vector(7 downto 0) := x"00";
signal data15 : std_logic_vector(7 downto 0) := x"FF";

signal data16 : std_logic_vector(7 downto 0) := x"00";
signal data17 : std_logic_vector(7 downto 0) := x"FF";
signal data18 : std_logic_vector(7 downto 0) := x"00";
signal data19 : std_logic_vector(7 downto 0) := x"FF";

signal data20 : std_logic_vector(7 downto 0) := x"00";
signal data21 : std_logic_vector(7 downto 0) := x"FF";
signal data22 : std_logic_vector(7 downto 0) := x"00";
signal data23 : std_logic_vector(7 downto 0) := x"FF";

signal data24 : std_logic_vector(7 downto 0) := x"00";
signal data25 : std_logic_vector(7 downto 0) := x"FF";
signal data26 : std_logic_vector(7 downto 0) := x"00";
signal data27 : std_logic_vector(7 downto 0) := x"FF";

signal data28 : std_logic_vector(7 downto 0) := x"00";
signal data29 : std_logic_vector(7 downto 0) := x"FF";
signal data30 : std_logic_vector(7 downto 0) := x"00";
signal data31 : std_logic_vector(7 downto 0) := x"FF";

signal data32 : std_logic_vector(7 downto 0) := x"00";
signal data33 : std_logic_vector(7 downto 0) := x"FF";
signal data34 : std_logic_vector(7 downto 0) := x"00";
signal data35 : std_logic_vector(7 downto 0) := x"FF";

signal data36 : std_logic_vector(7 downto 0) := x"00";
signal data37 : std_logic_vector(7 downto 0) := x"FF";
signal data38 : std_logic_vector(7 downto 0) := x"00";
signal data39 : std_logic_vector(7 downto 0) := x"FF";

signal data40 : std_logic_vector(7 downto 0) := x"00";
signal data41 : std_logic_vector(7 downto 0) := x"00";
signal data42 : std_logic_vector(7 downto 0) := x"00";
signal data43 : std_logic_vector(7 downto 0) := x"00";

signal data44 : std_logic_vector(7 downto 0) := x"00";
signal data45 : std_logic_vector(7 downto 0) := x"00";
signal data46 : std_logic_vector(7 downto 0) := x"00";
signal data47 : std_logic_vector(7 downto 0) := x"00";

signal data48 : std_logic_vector(7 downto 0) := x"00";
signal data49 : std_logic_vector(7 downto 0) := x"00";
signal data50 : std_logic_vector(7 downto 0) := x"00";
signal data51 : std_logic_vector(7 downto 0) := x"00";

signal data52 : std_logic_vector(7 downto 0) := x"00";
signal data53 : std_logic_vector(7 downto 0) := x"00";
signal data54 : std_logic_vector(7 downto 0) := x"00";
signal data55 : std_logic_vector(7 downto 0) := x"00";

signal data56 : std_logic_vector(7 downto 0) := x"00";
signal data57 : std_logic_vector(7 downto 0) := x"00";
signal data58 : std_logic_vector(7 downto 0) := x"00";
signal data59 : std_logic_vector(7 downto 0) := x"00";

signal data60 : std_logic_vector(7 downto 0) := x"00";
signal data61 : std_logic_vector(7 downto 0) := x"00";
signal data62 : std_logic_vector(7 downto 0) := x"00";
signal data63 : std_logic_vector(7 downto 0) := x"00";

signal data64 : std_logic_vector(7 downto 0) := x"00";
signal data65 : std_logic_vector(7 downto 0) := x"00";
signal data66 : std_logic_vector(7 downto 0) := x"00";
signal data67 : std_logic_vector(7 downto 0) := x"00";

signal data68 : std_logic_vector(7 downto 0) := x"00";
signal data69 : std_logic_vector(7 downto 0) := x"00";
signal data70 : std_logic_vector(7 downto 0) := x"00";
signal data71 : std_logic_vector(7 downto 0) := x"00";

signal data72 : std_logic_vector(7 downto 0) := x"00";
signal data73 : std_logic_vector(7 downto 0) := x"00";
signal data74 : std_logic_vector(7 downto 0) := x"00";
signal data75 : std_logic_vector(7 downto 0) := x"00";

signal data76 : std_logic_vector(7 downto 0) := x"00";
signal data77 : std_logic_vector(7 downto 0) := x"00";
signal data78 : std_logic_vector(7 downto 0) := x"00";
signal data79 : std_logic_vector(7 downto 0) := x"00";

signal data80 : std_logic_vector(7 downto 0) := x"00";
signal data81 : std_logic_vector(7 downto 0) := x"00";
signal data82 : std_logic_vector(7 downto 0) := x"00";
signal data83 : std_logic_vector(7 downto 0) := x"00";

signal data84 : std_logic_vector(7 downto 0) := x"00";
signal data85 : std_logic_vector(7 downto 0) := x"00";
signal data86 : std_logic_vector(7 downto 0) := x"00";
signal data87 : std_logic_vector(7 downto 0) := x"00";

signal data88 : std_logic_vector(7 downto 0) := x"00";
signal data89 : std_logic_vector(7 downto 0) := x"00";
signal data90 : std_logic_vector(7 downto 0) := x"00";
signal data91 : std_logic_vector(7 downto 0) := x"00";

signal data92 : std_logic_vector(7 downto 0) := x"00";
signal data93 : std_logic_vector(7 downto 0) := x"00";
signal data94 : std_logic_vector(7 downto 0) := x"00";
signal data95 : std_logic_vector(7 downto 0) := x"00";

signal data96 : std_logic_vector(7 downto 0) := x"00";
signal data97 : std_logic_vector(7 downto 0) := x"00";
signal data98 : std_logic_vector(7 downto 0) := x"00";
signal data99 : std_logic_vector(7 downto 0) := x"00";

signal data100 : std_logic_vector(7 downto 0) := x"00";
signal data101 : std_logic_vector(7 downto 0) := x"00";
signal data102 : std_logic_vector(7 downto 0) := x"00";
signal data103 : std_logic_vector(7 downto 0) := x"00";

signal data104 : std_logic_vector(7 downto 0) := x"00";
signal data105 : std_logic_vector(7 downto 0) := x"00";
signal data106 : std_logic_vector(7 downto 0) := x"00";
signal data107 : std_logic_vector(7 downto 0) := x"00";

signal data108 : std_logic_vector(7 downto 0) := x"00";
signal data109 : std_logic_vector(7 downto 0) := x"00";
signal data110 : std_logic_vector(7 downto 0) := x"00";
signal data111 : std_logic_vector(7 downto 0) := x"00";

signal data112 : std_logic_vector(7 downto 0) := x"00";
signal data113 : std_logic_vector(7 downto 0) := x"00";
signal data114 : std_logic_vector(7 downto 0) := x"00";
signal data115 : std_logic_vector(7 downto 0) := x"00";

signal data116 : std_logic_vector(7 downto 0) := x"00";
signal data117 : std_logic_vector(7 downto 0) := x"00";
signal data118 : std_logic_vector(7 downto 0) := x"00";
signal data119 : std_logic_vector(7 downto 0) := x"00";

signal data120 : std_logic_vector(7 downto 0) := x"00";
signal data121 : std_logic_vector(7 downto 0) := x"00";
signal data122 : std_logic_vector(7 downto 0) := x"00";
signal data123 : std_logic_vector(7 downto 0) := x"00";

signal data124 : std_logic_vector(7 downto 0) := x"00";
signal data125 : std_logic_vector(7 downto 0) := x"00";
signal data126 : std_logic_vector(7 downto 0) := x"00";
signal data127 : std_logic_vector(7 downto 0) := x"00";

signal data128 : std_logic_vector(7 downto 0) := x"00";
signal data129 : std_logic_vector(7 downto 0) := x"00";
signal data130 : std_logic_vector(7 downto 0) := x"00";
signal data131 : std_logic_vector(7 downto 0) := x"00";

signal data132 : std_logic_vector(7 downto 0) := x"00";
signal data133 : std_logic_vector(7 downto 0) := x"00";
signal data134 : std_logic_vector(7 downto 0) := x"00";
signal data135 : std_logic_vector(7 downto 0) := x"00";

-- 32 bytes to read the message digest
signal data0_check : std_logic_vector(7 downto 0);
signal data1_check : std_logic_vector(7 downto 0);
signal data2_check : std_logic_vector(7 downto 0);
signal data3_check : std_logic_vector(7 downto 0);

signal data4_check : std_logic_vector(7 downto 0);
signal data5_check : std_logic_vector(7 downto 0);
signal data6_check : std_logic_vector(7 downto 0);
signal data7_check : std_logic_vector(7 downto 0);

signal data8_check : std_logic_vector(7 downto 0);
signal data9_check : std_logic_vector(7 downto 0);
signal data10_check : std_logic_vector(7 downto 0);
signal data11_check : std_logic_vector(7 downto 0);

signal data12_check : std_logic_vector(7 downto 0);
signal data13_check : std_logic_vector(7 downto 0);
signal data14_check : std_logic_vector(7 downto 0);
signal data15_check : std_logic_vector(7 downto 0);

signal data16_check : std_logic_vector(7 downto 0);
signal data17_check : std_logic_vector(7 downto 0);
signal data18_check : std_logic_vector(7 downto 0);
signal data19_check : std_logic_vector(7 downto 0);

signal data20_check : std_logic_vector(7 downto 0);
signal data21_check : std_logic_vector(7 downto 0);
signal data22_check : std_logic_vector(7 downto 0);
signal data23_check : std_logic_vector(7 downto 0);

signal data24_check : std_logic_vector(7 downto 0);
signal data25_check : std_logic_vector(7 downto 0);
signal data26_check : std_logic_vector(7 downto 0);
signal data27_check : std_logic_vector(7 downto 0);

signal data28_check : std_logic_vector(7 downto 0);
signal data29_check : std_logic_vector(7 downto 0);
signal data30_check : std_logic_vector(7 downto 0);
signal data31_check : std_logic_vector(7 downto 0);


signal clk         : std_logic;
signal rst         : std_logic;
 
-- UART rx port
signal rxd : std_logic;
 
-- UART tx port
signal txd : std_logic;

procedure uart_write (
    signal data : in std_logic_vector(7 downto 0);
    signal rxd : out std_logic ) is
begin
    rxd <= '0';
    
    wait for uart_baud_wait;

    for i in 0 to 7 loop
        rxd <= data(i);
        wait for uart_baud_wait;
    end loop;

    rxd <= '1';
    wait for uart_baud_wait;
end procedure;


procedure uart_read (
    signal data : out std_logic_vector(7 downto 0);
    signal txd : in std_logic ) is
begin
    -- wait for start bit
    wait until txd = '0';
    
    -- wait a bit more to be sure to sample a real data bit
    -- in a real UART implementation, it will sample multiple times to be more fault tolerante
    wait for uart_baud_wait/16;
    wait for uart_baud_wait;

    for i in 0 to 7 loop
        data(i) <= txd;
        wait for uart_baud_wait;
    end loop;

    -- stop bit
    assert(txd = '1');    
end procedure;
    
begin

rst_stimuli : process is
begin
    rst <= '1';
    
    wait for 100ns;
    
    rst <= '0';
    
    wait;
end process;

clk_stimuli : process is
begin
    clk <= '0';
    
    wait for clk_period/2;
    
    clk <= '1';
    
    wait for clk_period/2;
    
    sim_time <= sim_time + clk_period;
end process;

txd_stimuli : process is
begin
    rxd <= '1';
    
    wait until rst = '0';
    
    uart_write(cmd0, rxd);
    uart_write(cmd1, rxd);      
    uart_write(cmd2, rxd);     
    uart_write(cmd3, rxd);     
    
    uart_write(data0, rxd);        
    uart_write(data1, rxd);        
    uart_write(data2, rxd);        
    uart_write(data3, rxd);        
    
    uart_write(data4, rxd);        
    uart_write(data5, rxd);        
    uart_write(data6, rxd);        
    uart_write(data7, rxd);        
    
    uart_write(data8, rxd);       
    uart_write(data9, rxd);       
    uart_write(data10, rxd);       
    uart_write(data11, rxd);       
    
    uart_write(data12, rxd);       
    uart_write(data13, rxd);       
    uart_write(data14, rxd);       
    uart_write(data15, rxd);       

    uart_write(data16, rxd);       
    uart_write(data17, rxd);       
    uart_write(data18, rxd);       
    uart_write(data19, rxd);       

    uart_write(data20, rxd);       
    uart_write(data21, rxd);       
    uart_write(data22, rxd);       
    uart_write(data23, rxd);       

    uart_write(data24, rxd);       
    uart_write(data25, rxd);       
    uart_write(data26, rxd);       
    uart_write(data27, rxd);       

    uart_write(data28, rxd);       
    uart_write(data29, rxd);       
    uart_write(data30, rxd);       
    uart_write(data31, rxd);       

    uart_write(data32, rxd);       
    uart_write(data33, rxd);       
    uart_write(data34, rxd);       
    uart_write(data35, rxd);       

    uart_write(data36, rxd);       
    uart_write(data37, rxd);       
    uart_write(data38, rxd);       
    uart_write(data39, rxd);       

    uart_write(data40, rxd);       
    uart_write(data41, rxd);       
    uart_write(data42, rxd);       
    uart_write(data43, rxd);       

    uart_write(data44, rxd);       
    uart_write(data45, rxd);       
    uart_write(data46, rxd);       
    uart_write(data47, rxd);       

    uart_write(data48, rxd);       
    uart_write(data49, rxd);       
    uart_write(data50, rxd);       
    uart_write(data51, rxd);       

    uart_write(data52, rxd);       
    uart_write(data53, rxd);       
    uart_write(data54, rxd);       
    uart_write(data55, rxd);       

    uart_write(data56, rxd);       
    uart_write(data57, rxd);       
    uart_write(data58, rxd);       
    uart_write(data59, rxd);       

    uart_write(data60, rxd);       
    uart_write(data61, rxd);       
    uart_write(data62, rxd);       
    uart_write(data63, rxd);       

    uart_write(data64, rxd);       
    uart_write(data65, rxd);       
    uart_write(data66, rxd);       
    uart_write(data67, rxd);       

    uart_write(data68, rxd);       
    uart_write(data69, rxd);       
    uart_write(data70, rxd);       
    uart_write(data71, rxd);       

    uart_write(data72, rxd);       
    uart_write(data73, rxd);       
    uart_write(data74, rxd);       
    uart_write(data75, rxd);       

    uart_write(data76, rxd);       
    uart_write(data77, rxd);       
    uart_write(data78, rxd);       
    uart_write(data79, rxd);       

    uart_write(data80, rxd);       
    uart_write(data81, rxd);       
    uart_write(data82, rxd);       
    uart_write(data83, rxd);       

    uart_write(data84, rxd);       
    uart_write(data85, rxd);       
    uart_write(data86, rxd);       
    uart_write(data87, rxd);       

    uart_write(data88, rxd);       
    uart_write(data89, rxd);       
    uart_write(data90, rxd);       
    uart_write(data91, rxd);       

    uart_write(data92, rxd);       
    uart_write(data93, rxd);       
    uart_write(data94, rxd);       
    uart_write(data95, rxd);       

    uart_write(data96, rxd);       
    uart_write(data97, rxd);       
    uart_write(data98, rxd);       
    uart_write(data99, rxd);       

    uart_write(data100, rxd);       
    uart_write(data101, rxd);       
    uart_write(data102, rxd);       
    uart_write(data103, rxd);       

    uart_write(data104, rxd);       
    uart_write(data105, rxd);       
    uart_write(data106, rxd);       
    uart_write(data107, rxd);       

    uart_write(data108, rxd);       
    uart_write(data109, rxd);       
    uart_write(data110, rxd);       
    uart_write(data111, rxd);       

    uart_write(data112, rxd);       
    uart_write(data113, rxd);       
    uart_write(data114, rxd);       
    uart_write(data115, rxd);       

    uart_write(data116, rxd);       
    uart_write(data117, rxd);       
    uart_write(data118, rxd);       
    uart_write(data119, rxd);       

    uart_write(data120, rxd);       
    uart_write(data121, rxd);       
    uart_write(data122, rxd);       
    uart_write(data123, rxd);       

    uart_write(data124, rxd);       
    uart_write(data125, rxd);       
    uart_write(data126, rxd);       
    uart_write(data127, rxd);       

    uart_write(data128, rxd);       
    uart_write(data129, rxd);       
    uart_write(data130, rxd);       
    uart_write(data131, rxd);       

    uart_write(data132, rxd);       
    uart_write(data133, rxd);       
    uart_write(data134, rxd);       
    uart_write(data135, rxd);       
    
    wait;
end process;

rxd_check : process is
begin
    uart_read(data0_check, txd);
    uart_read(data1_check, txd);
    uart_read(data2_check, txd);
    uart_read(data3_check, txd);

    uart_read(data4_check, txd);
    uart_read(data5_check, txd);
    uart_read(data6_check, txd);
    uart_read(data7_check, txd);

    uart_read(data8_check, txd);
    uart_read(data9_check, txd);
    uart_read(data10_check, txd);
    uart_read(data11_check, txd);

    uart_read(data12_check, txd);
    uart_read(data13_check, txd);
    uart_read(data14_check, txd);
    uart_read(data15_check, txd);

    uart_read(data16_check, txd);
    uart_read(data17_check, txd);
    uart_read(data18_check, txd);
    uart_read(data19_check, txd);

    uart_read(data20_check, txd);
    uart_read(data21_check, txd);
    uart_read(data22_check, txd);
    uart_read(data23_check, txd);

    uart_read(data24_check, txd);
    uart_read(data25_check, txd);
    uart_read(data26_check, txd);
    uart_read(data27_check, txd);

    uart_read(data28_check, txd);
    uart_read(data29_check, txd);
    uart_read(data30_check, txd);
    uart_read(data31_check, txd);

end process;

top_inst : top
    port map ( clk => clk, 
               rst => rst, 
               rxd => rxd, 
               txd => txd);
               
end architecture;
